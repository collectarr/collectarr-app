import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/sync/collectarr_sync_client.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/core/sync/sync_service.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_entries_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sync pull uses since and applies delete tombstones', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final client = _FakeSyncClient();
    final since = DateTime.utc(2026, 5, 11);

    final result = await SyncService(
      client: client,
      db: db,
      queue: SyncQueueRepository(db),
      catalog: CatalogCacheRepository(db),
      ownedItems: OwnedItemsCacheRepository(db),
      trackingEntries: TrackingEntriesCacheRepository(db),
      wishlistItems: WishlistItemsCacheRepository(db),
    ).syncNow('android', since: since);

    final row = await db.select(db.ownedItemsCache).getSingle();
    final trackingRow = await db.select(db.trackingEntriesCache).getSingle();
    final wishlistRow = await db.select(db.wishlistItemsCache).getSingle();
    final catalogRow = await db.select(db.catalogCache).getSingle();
    final locations = await LocationRepository(db).getAll();
    expect(client.lastPullSince, since);
    expect(result.serverTime, DateTime.utc(2026, 5, 12, 9));
    expect(result.rejectedCount, 0);
    expect(row.deletedAt?.toUtc(), DateTime.utc(2026, 5, 12, 8));
    expect(trackingRow.status, 'Completed');
    expect(trackingRow.rating, 9);
    expect(wishlistRow.deletedAt?.toUtc(), DateTime.utc(2026, 5, 12, 8, 30));
    expect(catalogRow.title, 'Absolute Batman');
    expect(catalogRow.coverImageUrl, 'https://cdn.example/absolute.jpg');
    expect(
        catalogRow.thumbnailImageUrl, 'https://cdn.example/absolute-thumb.jpg');
    expect(locations.map((location) => location.id), ['room']);
    expect(locations.single.name, 'Office');
  });

  test('sync removes rejected stale changes and applies server state',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final queue = SyncQueueRepository(db);
    await queue.enqueue(
      SyncChange(
        id: 'sync-1',
        entityType: 'owned_item',
        entityId: 'owned-1',
        action: 'upsert',
        payload: const {'item_id': 'comic-1', 'grade': '7.5'},
        clientChangedAt: DateTime.utc(2026, 5, 12, 8),
      ),
    );

    final result = await SyncService(
      client: _RejectedSyncClient(),
      db: db,
      queue: queue,
      catalog: CatalogCacheRepository(db),
      ownedItems: OwnedItemsCacheRepository(db),
      trackingEntries: TrackingEntriesCacheRepository(db),
      wishlistItems: WishlistItemsCacheRepository(db),
    ).syncNow('android', since: DateTime.utc(2026, 5, 11));

    final row = await db.select(db.ownedItemsCache).getSingle();
    expect(result.rejectedCount, 1);
    expect(result.rejectedChanges.single.entityId, 'owned-1');
    expect(await queue.pendingCount(), 0);
    expect(row.grade, '9.8');
    expect(row.updatedAt.toUtc(), DateTime.utc(2026, 5, 12, 9));
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
          'owned_item_id': 'owned-1',
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

    final result = await SyncService(
      client: client,
      db: db,
      queue: queue,
      catalog: CatalogCacheRepository(db),
      ownedItems: OwnedItemsCacheRepository(db),
      trackingEntries: TrackingEntriesCacheRepository(db),
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
        'owned_item_id': 'owned-1',
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
      'rejected': [],
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
          'entity_type': 'library_item_snapshot',
          'entity_id': 'comic-1',
          'action': 'upsert',
          'source_device_id': 'desktop',
          'client_changed_at': '2026-05-12T07:30:00.000Z',
          'changed_at': '2026-05-12T09:00:00.000Z',
          'payload': {
            'kind': 'comic',
            'title': 'Absolute Batman',
            'item_number': '1',
            'cover_image_url': 'https://cdn.example/absolute.jpg',
            'thumbnail_image_url': 'https://cdn.example/absolute-thumb.jpg',
            'publisher': 'DC',
            'release_year': 2024,
          },
        },
        {
          'entity_type': 'owned_item',
          'entity_id': 'owned-1',
          'action': 'delete',
          'source_device_id': 'desktop',
          'client_changed_at': '2026-05-12T08:00:00.000Z',
          'changed_at': '2026-05-12T09:00:00.000Z',
          'payload': {'item_id': 'comic-1'},
        },
        {
          'entity_type': 'tracking_entry',
          'entity_id': 'tracking-1',
          'action': 'upsert',
          'source_device_id': 'desktop',
          'client_changed_at': '2026-05-12T08:10:00.000Z',
          'changed_at': '2026-05-12T09:00:00.000Z',
          'payload': {
            'item_id': 'comic-1',
            'owned_item_id': 'owned-1',
            'source_type': 'physical',
            'status': 'Completed',
            'rating': 9,
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
          'payload': {'item_id': 'comic-2'},
        },
      ],
      'changes': [],
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
      'accepted': [],
      'rejected': [
        {
          'entity_type': 'owned_item',
          'entity_id': 'owned-1',
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
          'entity_type': 'owned_item',
          'entity_id': 'owned-1',
          'action': 'upsert',
          'source_device_id': 'desktop',
          'client_changed_at': '2026-05-12T09:00:00.000Z',
          'changed_at': '2026-05-12T09:05:00.000Z',
          'payload': {'item_id': 'comic-1', 'grade': '9.8'},
        },
      ],
      'changes': [],
    };
  }
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
      'rejected': [],
    };
  }

  @override
  Future<Map<String, dynamic>> pull({DateTime? since}) async {
    return {
      'server_time': '2026-05-12T09:00:00.000Z',
      'entities': const [],
      'changes': const [],
    };
  }
}
