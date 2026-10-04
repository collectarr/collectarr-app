import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/library/entries/library_entry_record.dart';
import 'package:collectarr_app/features/library/entries/library_entry_store.dart';
import 'package:collectarr_app/core/sync/collectarr_sync_client.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/sync/data/sync_apply_service.dart';

import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/collection/repositories/item_image_repository.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_tracking_repository.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_entry_persistence.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import '../helpers/tracking_state_test_helpers.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sync pull uses since and applies delete tombstones', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final client = _FakeSyncClient();
    final since = DateTime.utc(2026, 5, 11);

    final result = await SyncApplyService(
      client: client,
      db: db,
      queue: SyncQueueRepository(db),
      entryPersistence: CollectarrLibraryEntryPersistence(db),
      trackingRecords: TrackingStorageRepository(
        db,
        codecs: libraryTrackingStorageCodecs,
      ),
      wishlistItems: WishlistItemsCacheRepository(db),
    ).syncNow('android', since: since);

    final entry = await ComicEntryRepository(db)
        .findById(const LibraryEntryId('entry-1'));
    final storedEntry = await LibraryEntryStore(db).find(
      CatalogMediaKind.comic,
      'entry-1',
    );
    final trackingRow = await readSingleTrackingState(db);
    final wishlistRow = await db.select(db.wishlistItemsCache).getSingle();
    final locations = await LocationRepository(db).getAll();
    final customEpisode = await TvTrackingRepository(db)
        .findCustomEpisodeById(const TvEpisodeId('custom-tv-1'));
    expect(client.lastPullSince, since);
    expect(result.serverTime, DateTime.utc(2026, 5, 12, 9));
    expect(result.rejectedCount, 0);
    expect(entry?.deletedAt?.toUtc(), DateTime.utc(2026, 5, 12, 8));
    expect(storedEntry?.deletedAt?.toUtc(), DateTime.utc(2026, 5, 12, 8));
    expect(trackingRow.statusStorageValue, 'Completed');
    expect(trackingRow.rating, 9);
    expect(wishlistRow.deletedAt?.toUtc(), DateTime.utc(2026, 5, 12, 8, 30));
    expect(locations.map((location) => location.id), ['room']);
    expect(locations.single.name, 'Office');
    expect(customEpisode?.seriesId.value, 'tv-series-1');
    expect(customEpisode?.seasonNumber, 2);
    expect(customEpisode?.episodeNumber, 4);
    expect(customEpisode?.title, 'The Missing Cut');
  });

  test('sync removes rejected stale changes and applies server state',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final queue = SyncQueueRepository(db);
    await queue.enqueue(
      SyncChange(
        id: 'sync-1',
        entityType: 'library_entry',
        entityId: 'entry-1',
        action: 'upsert',
        payload: const {
          'id': 'entry-1',
          'kind': 'comic',
          'catalog_data': {'title': 'Test Comic'},
          'personal_data': {'grade': '7.5'},
          'source_catalog_ref': {'kind': 'comic', 'id': 'comic-1'},
          'updated_at': '2026-05-12T08:00:00.000Z',
        },
        clientChangedAt: DateTime.utc(2026, 5, 12, 8),
      ),
    );

    final result = await SyncApplyService(
      client: _RejectedSyncClient(),
      db: db,
      queue: queue,
      entryPersistence: CollectarrLibraryEntryPersistence(db),
      trackingRecords: TrackingStorageRepository(
        db,
        codecs: libraryTrackingStorageCodecs,
      ),
      wishlistItems: WishlistItemsCacheRepository(db),
    ).syncNow('android', since: DateTime.utc(2026, 5, 11));

    final entry = await ComicEntryRepository(db)
        .findById(const LibraryEntryId('entry-1'));
    expect(result.rejectedCount, 1);
    expect(result.rejectedChanges.single.entityId, 'entry-1');
    expect(await queue.pendingCount(), 0);
    expect(entry?.grade, '9.8');
    expect(entry?.updatedAt.toUtc(), DateTime.utc(2026, 5, 12, 9));
  });

  test('sync push preserves tracking entry wire payload shape', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final queue = SyncQueueRepository(db);
    final client = _CapturingSyncClient();
    await queue.enqueue(
      SyncChange(
        id: 'sync-tracking-1',
        entityType: 'tracking_entry',
        entityId: 'tracking-1',
        action: 'upsert',
        payload: const {
          'item_id': 'movie-1',
          'catalog_ref': {'kind': 'movie', 'id': 'movie-1'},
          'library_entry_ref': {'kind': 'movie', 'id': 'entry-1'},
          'edition_id': 'edition-stream',
          'variant_id': 'variant-4k',
          'source_type': 'digital',
          'status': 'Watching',
          'rating': 8,
          'progress_current': 45,
          'progress_total': 100,
          'times_completed': 2,
          'notes': 'Second rewatch',
          'season_number': 1,
          'episode_number': 3,
        },
        clientChangedAt: DateTime.utc(2026, 5, 12, 8),
      ),
    );

    final result = await SyncApplyService(
      client: client,
      db: db,
      queue: queue,
      entryPersistence: CollectarrLibraryEntryPersistence(db),
      trackingRecords: TrackingStorageRepository(
        db,
        codecs: libraryTrackingStorageCodecs,
      ),
      wishlistItems: WishlistItemsCacheRepository(db),
    ).syncNow('desktop');

    expect(result.rejectedCount, 0);
    expect(client.lastDeviceId, 'desktop');
    expect(client.lastPushedChanges, hasLength(1));
    final pushed = client.lastPushedChanges.single.toWireJson();
    expect(pushed['entity_type'], 'tracking_entry');
    expect(pushed['entity_id'], 'tracking-1');
    expect(pushed['action'], 'upsert');
    expect(
      pushed['client_changed_at'],
      DateTime.utc(2026, 5, 12, 8).toIso8601String(),
    );
    expect(
      pushed['payload'],
      {
        'item_id': 'movie-1',
        'catalog_ref': {'kind': 'movie', 'id': 'movie-1'},
        'library_entry_ref': {'kind': 'movie', 'id': 'entry-1'},
        'edition_id': 'edition-stream',
        'variant_id': 'variant-4k',
        'source_type': 'digital',
        'status': 'Watching',
        'rating': 8,
        'progress_current': 45,
        'progress_total': 100,
        'times_completed': 2,
        'notes': 'Second rewatch',
        'season_number': 1,
        'episode_number': 3,
      },
    );
    expect(await queue.pendingCount(), 0);
  });

  test('sync pull applies complete entry images and custom fields', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final ref = LibraryEntryRef(
      kind: CatalogMediaKind.comic,
      id: const LibraryEntryId('entry-with-assets'),
    );
    await SyncApplyService(
      client: _EntryAssetsSyncClient(),
      db: db,
      queue: SyncQueueRepository(db),
      entryPersistence: CollectarrLibraryEntryPersistence(db),
      trackingRecords: TrackingStorageRepository(
        db,
        codecs: libraryTrackingStorageCodecs,
      ),
      wishlistItems: WishlistItemsCacheRepository(db),
    ).syncNow('desktop');

    final images = await ItemImageRepository(db).listForLibraryEntryRef(ref);
    final fields = await CustomFieldRepository(db).listValuesForTarget(
      targetId: ref.key,
      targetScope: CustomFieldTargetScope.libraryEntry,
    );
    expect(images, hasLength(1));
    expect(images.single.id, 'image-1');
    expect(images.single.imageData, [1, 2, 3]);
    expect(fields, hasLength(1));
    expect(fields.single.fieldDefinitionId, 'field-1');
    expect(fields.single.value, 'signed');
  });
}

class _FakeSyncClient extends CollectarrSyncClient {
  _FakeSyncClient() : super(baseUrl: 'http://unused', syncKey: 'test');

  DateTime? lastPullSince;

  @override
  Future<Map<String, dynamic>> push({
    required String deviceId,
    required List<SyncChange> changes,
  }) async {
    return {
      'server_time': '2026-05-12T09:00:00.000Z',
      'accepted': [
        for (final change in changes)
          {
            'entity_type': change.entityType,
            'entity_id': change.entityId,
          },
      ],
      'rejected': <dynamic>[],
    };
  }

  @override
  Future<Map<String, dynamic>> pull({DateTime? since}) async {
    lastPullSince = since;
    return {
      'server_time': '2026-05-12T09:00:00.000Z',
      'entities': [
        {
          'entity_type': 'location',
          'entity_id': 'room',
          'action': 'upsert',
          'source_device_id': 'desktop',
          'client_changed_at': '2026-05-12T07:15:00.000Z',
          'changed_at': '2026-05-12T09:00:00.000Z',
          'payload': {
            'name': 'Office',
            'description': 'Main room',
            'sort_order': 1,
          },
        },
        {
          'entity_type': 'library_entry',
          'entity_id': 'entry-1',
          'action': 'delete',
          'source_device_id': 'desktop',
          'client_changed_at': '2026-05-12T08:00:00.000Z',
          'changed_at': '2026-05-12T09:00:00.000Z',
          'payload': {
            'id': 'entry-1',
            'kind': 'comic',
            'catalog_data': {'title': 'Test Comic'},
            'personal_data': {},
            'source_catalog_ref': {'kind': 'comic', 'id': 'comic-1'},
            'updated_at': '2026-05-12T08:00:00.000Z',
            'deleted_at': '2026-05-12T08:00:00.000Z',
          },
        },
        {
          'entity_type': 'tracking_entry',
          'entity_id': 'tracking-1',
          'action': 'upsert',
          'source_device_id': 'desktop',
          'client_changed_at': '2026-05-12T08:10:00.000Z',
          'changed_at': '2026-05-12T09:00:00.000Z',
          'payload': {
            'catalog_ref': {
              'kind': 'comic',
              'id': 'comic-1',
            },
            'library_entry_ref': {'kind': 'comic', 'id': 'entry-1'},
            'source_type': 'physical',
            'status': 'Completed',
            'rating': 9,
          },
        },
        {
          'entity_type': 'custom_episode',
          'entity_id': 'custom-tv-1',
          'action': 'upsert',
          'source_device_id': 'desktop',
          'client_changed_at': '2026-05-12T08:12:00.000Z',
          'changed_at': '2026-05-12T09:00:00.000Z',
          'payload': {
            'catalog_ref': {
              'kind': 'tv',
              'id': 'tv-series-1',
            },
            'season_number': 2,
            'episode_number': 4,
            'title': 'The Missing Cut',
            'overview': 'A locally authored episode',
            'runtime_minutes': 47,
          },
        },
        {
          'entity_type': 'location',
          'entity_id': 'closet',
          'action': 'delete',
          'source_device_id': 'desktop',
          'client_changed_at': '2026-05-12T08:45:00.000Z',
          'changed_at': '2026-05-12T09:00:00.000Z',
          'payload': {
            'name': 'Closet',
            'sort_order': 2,
          },
        },
        {
          'entity_type': 'wishlist_item',
          'entity_id': 'wish-1',
          'action': 'delete',
          'source_device_id': 'desktop',
          'client_changed_at': '2026-05-12T08:30:00.000Z',
          'changed_at': '2026-05-12T09:00:00.000Z',
          'payload': {
            'catalog_ref': {
              'kind': 'comic',
              'id': 'comic-2',
            },
          },
        },
      ],
      'changes': <dynamic>[],
    };
  }
}

class _RejectedSyncClient extends CollectarrSyncClient {
  _RejectedSyncClient() : super(baseUrl: 'http://unused', syncKey: 'test');

  @override
  Future<Map<String, dynamic>> push({
    required String deviceId,
    required List<SyncChange> changes,
  }) async {
    return {
      'server_time': '2026-05-12T09:00:00.000Z',
      'accepted': <dynamic>[],
      'rejected': [
        {
          'entity_type': 'library_entry',
          'entity_id': 'entry-1',
          'reason': 'server_has_newer_client_change',
          'current_client_changed_at': '2026-05-12T09:00:00.000Z',
        },
      ],
    };
  }

  @override
  Future<Map<String, dynamic>> pull({DateTime? since}) async {
    return {
      'server_time': '2026-05-12T09:05:00.000Z',
      'entities': [
        {
          'entity_type': 'library_entry',
          'entity_id': 'entry-1',
          'action': 'upsert',
          'source_device_id': 'desktop',
          'client_changed_at': '2026-05-12T09:00:00.000Z',
          'changed_at': '2026-05-12T09:05:00.000Z',
          'payload': {
            'id': 'entry-1',
            'kind': 'comic',
            'catalog_data': {'title': 'Test Comic'},
            'personal_data': {'grade': '9.8'},
            'source_catalog_ref': {'kind': 'comic', 'id': 'comic-1'},
            'updated_at': '2026-05-12T09:00:00.000Z',
          },
        },
      ],
      'changes': <dynamic>[],
    };
  }
}

class _EntryAssetsSyncClient extends CollectarrSyncClient {
  _EntryAssetsSyncClient() : super(baseUrl: 'http://unused', syncKey: 'test');

  @override
  Future<Map<String, dynamic>> push({
    required String deviceId,
    required List<SyncChange> changes,
  }) async =>
      {
        'server_time': '2026-05-12T09:00:00.000Z',
        'accepted': <dynamic>[],
        'rejected': <dynamic>[],
      };

  @override
  Future<Map<String, dynamic>> pull({DateTime? since}) async => {
        'server_time': '2026-05-12T09:00:00.000Z',
        'entities': [
          {
            'entity_type': 'library_entry',
            'entity_id': 'entry-with-assets',
            'action': 'upsert',
            'source_device_id': 'phone',
            'client_changed_at': '2026-05-12T08:00:00.000Z',
            'changed_at': '2026-05-12T09:00:00.000Z',
            'payload': {
              'id': 'entry-with-assets',
              'kind': 'comic',
              'catalog_data': {'title': 'Local Issue'},
              'personal_data': {
                libraryEntrySyncImagesKey: [
                  {
                    'id': 'image-1',
                    'image_type': 'front_cover',
                    'image_data': 'AQID',
                    'caption': 'Cover',
                    'sort_order': 0,
                    'created_at': '2026-05-12T08:00:00.000Z',
                  },
                ],
                libraryEntrySyncCustomFieldsKey: [
                  {
                    'id': 'custom-1',
                    'field_definition_id': 'field-1',
                    'value': 'signed',
                    'updated_at': '2026-05-12T08:00:00.000Z',
                  },
                ],
              },
              'source_catalog_ref': {'kind': 'comic', 'id': 'comic-source'},
              'updated_at': '2026-05-12T08:00:00.000Z',
            },
          },
        ],
        'changes': <dynamic>[],
      };
}

class _CapturingSyncClient extends CollectarrSyncClient {
  _CapturingSyncClient() : super(baseUrl: 'http://unused', syncKey: 'test');

  String? lastDeviceId;
  List<SyncChange> lastPushedChanges = const [];

  @override
  Future<Map<String, dynamic>> push({
    required String deviceId,
    required List<SyncChange> changes,
  }) async {
    lastDeviceId = deviceId;
    lastPushedChanges = List<SyncChange>.from(changes);
    return {
      'server_time': '2026-05-12T09:00:00.000Z',
      'accepted': [
        for (final change in changes)
          {
            'entity_type': change.entityType,
            'entity_id': change.entityId,
          },
      ],
      'rejected': <dynamic>[],
    };
  }

  @override
  Future<Map<String, dynamic>> pull({DateTime? since}) async {
    return {
      'server_time': '2026-05-12T09:00:00.000Z',
      'entities': const <dynamic>[],
      'changes': const <dynamic>[],
    };
  }
}
