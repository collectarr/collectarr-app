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

  Future<DateTime> syncNow(String deviceId, {DateTime? since}) async {
    final pending = await queue.listPending();
    if (pending.isNotEmpty) {
      final response = await client.push(deviceId: deviceId, changes: pending);
      final acceptedIds = _acceptedKeys(response);
      await queue.deleteMany(
        pending
            .where((change) =>
                acceptedIds.contains('${change.entityType}:${change.entityId}'))
            .map((change) => change.id),
      );
    }

    final pull = await client.pull(since: since);
    for (final entity in _entities(pull)) {
      await _applyEntity(entity);
    }
    return _serverTime(pull);
  }

  Future<void> _applyEntity(Map<String, dynamic> entity) async {
    final type = entity['entity_type'] as String;
    final action = entity['action'] as String;
    final payload = _payload(entity);
    final deletedAt = action == 'delete' ? entity['client_changed_at'] : null;
    if (type == 'owned_item') {
      final item = OwnedItem.fromJson({
        ...payload,
        'id': entity['entity_id'],
        'updated_at': entity['client_changed_at'],
        'deleted_at': deletedAt,
      });
      await ownedItems.upsert(item);
    }
    if (type == 'wishlist_item') {
      final item = WishlistItem.fromJson({
        ...payload,
        'id': entity['entity_id'],
        'updated_at': entity['client_changed_at'],
        'deleted_at': deletedAt,
      });
      await wishlistItems.upsert(item);
    }
  }

  Set<String> _acceptedKeys(Map<String, dynamic> response) {
    final accepted = response['accepted'];
    if (accepted is! List) {
      throw const FormatException(
        'Sync push response is missing accepted changes',
      );
    }
    return accepted
        .whereType<Map>()
        .map((item) => item.cast<String, dynamic>())
        .where(
          (item) =>
              item['entity_type'] is String && item['entity_id'] is String,
        )
        .map((item) => '${item['entity_type']}:${item['entity_id']}')
        .toSet();
  }

  List<Map<String, dynamic>> _entities(Map<String, dynamic> response) {
    final entities = response['entities'];
    if (entities is! List) {
      throw const FormatException('Sync pull response is missing entities');
    }
    return entities
        .whereType<Map>()
        .map((item) => item.cast<String, dynamic>())
        .toList(growable: false);
  }

  Map<String, dynamic> _payload(Map<String, dynamic> entity) {
    final payload = entity['payload'];
    if (payload is! Map) {
      throw const FormatException('Sync entity is missing payload');
    }
    return payload.cast<String, dynamic>();
  }

  DateTime _serverTime(Map<String, dynamic> response) {
    final value = response['server_time'];
    if (value is! String) {
      throw const FormatException('Sync response is missing server_time');
    }
    return DateTime.parse(value).toUtc();
  }
}
