import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/sync/collectarr_sync_client.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/collection/owned_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/wishlist_items_cache_repository.dart';

class SyncService {
  const SyncService({
    required this.client,
    required this.queue,
    required this.ownedItems,
    required this.wishlistItems,
  });

  final CollectarrSyncClient client;
  final SyncQueueRepository queue;
  final OwnedItemsCacheRepository ownedItems;
  final WishlistItemsCacheRepository wishlistItems;

  Future<void> syncNow(String deviceId) async {
    final pending = await queue.listPending();
    if (pending.isNotEmpty) {
      final response = await client.push(deviceId: deviceId, changes: pending);
      final acceptedIds = (response['accepted'] as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .map((item) => '${item['entity_type']}:${item['entity_id']}')
          .toSet();
      await queue.deleteMany(
        pending
            .where((change) =>
                acceptedIds.contains('${change.entityType}:${change.entityId}'))
            .map((change) => change.id),
      );
    }

    final pull = await client.pull();
    for (final entity in pull['entities'] as List<dynamic>) {
      await _applyEntity((entity as Map).cast<String, dynamic>());
    }
  }

  Future<void> _applyEntity(Map<String, dynamic> entity) async {
    final type = entity['entity_type'] as String;
    final action = entity['action'] as String;
    final payload = (entity['payload'] as Map).cast<String, dynamic>();
    if (type == 'owned_item') {
      final item = OwnedItem.fromJson({
        ...payload,
        'id': entity['entity_id'],
        'updated_at': entity['client_changed_at'],
        'deleted_at': action == 'delete' ? entity['deleted_at'] : null,
      });
      await ownedItems.upsert(item);
    }
    if (type == 'wishlist_item') {
      final item = WishlistItem.fromJson({
        ...payload,
        'id': entity['entity_id'],
        'updated_at': entity['client_changed_at'],
        'deleted_at': action == 'delete' ? entity['deleted_at'] : null,
      });
      await wishlistItems.upsert(item);
    }
  }
}
