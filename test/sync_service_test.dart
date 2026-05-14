import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/sync/collectarr_sync_client.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/core/sync/sync_service.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/owned_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/wishlist_items_cache_repository.dart';
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
      wishlistItems: WishlistItemsCacheRepository(db),
    ).syncNow('android', since: since);

    final row = await db.select(db.ownedItemsCache).getSingle();
    final wishlistRow = await db.select(db.wishlistItemsCache).getSingle();
    final catalogRow = await db.select(db.catalogCache).getSingle();
    expect(client.lastPullSince, since);
    expect(result.serverTime, DateTime.utc(2026, 5, 12, 9));
    expect(result.rejectedCount, 0);
    expect(row.deletedAt?.toUtc(), DateTime.utc(2026, 5, 12, 8));
    expect(wishlistRow.deletedAt?.toUtc(), DateTime.utc(2026, 5, 12, 8, 30));
    expect(catalogRow.title, 'Absolute Batman');
    expect(catalogRow.coverImageUrl, 'https://cdn.example/absolute.jpg');
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
      wishlistItems: WishlistItemsCacheRepository(db),
    ).syncNow('android', since: DateTime.utc(2026, 5, 11));

    final row = await db.select(db.ownedItemsCache).getSingle();
    expect(result.rejectedCount, 1);
    expect(result.rejectedChanges.single.entityId, 'owned-1');
    expect(await queue.pendingCount(), 0);
    expect(row.grade, '9.8');
    expect(row.updatedAt.toUtc(), DateTime.utc(2026, 5, 12, 9));
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
