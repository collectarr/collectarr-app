import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/sync/collectarr_sync_client.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/core/sync/sync_service.dart';
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

    final serverTime = await SyncService(
      client: client,
      queue: SyncQueueRepository(db),
      ownedItems: OwnedItemsCacheRepository(db),
      wishlistItems: WishlistItemsCacheRepository(db),
    ).syncNow('android', since: since);

    final row = await db.select(db.ownedItemsCache).getSingle();
    expect(client.lastPullSince, since);
    expect(serverTime, DateTime.utc(2026, 5, 12, 9));
    expect(row.deletedAt?.toUtc(), DateTime.utc(2026, 5, 12, 8));
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
          'entity_type': 'owned_item',
          'entity_id': 'owned-1',
          'action': 'delete',
          'source_device_id': 'desktop',
          'client_changed_at': '2026-05-12T08:00:00.000Z',
          'changed_at': '2026-05-12T09:00:00.000Z',
          'payload': {'item_id': 'comic-1'},
        },
      ],
      'changes': [],
    };
  }
}
