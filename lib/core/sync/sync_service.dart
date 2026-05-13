import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/sync/collectarr_sync_client.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/collection/owned_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/wishlist_items_cache_repository.dart';

class SyncService {
  const SyncService({
    required this.client,
    required this.db,
    required this.queue,
    required this.ownedItems,
    required this.wishlistItems,
  });

  final CollectarrSyncClient client;
  final LocalDatabase db;
  final SyncQueueRepository queue;
  final OwnedItemsCacheRepository ownedItems;
  final WishlistItemsCacheRepository wishlistItems;

  Future<SyncResult> syncNow(String deviceId, {DateTime? since}) async {
    var rejectedChanges = const <SyncRejectedChange>[];
    final pending = await queue.listPending();
    if (pending.isNotEmpty) {
      final response = await client.push(deviceId: deviceId, changes: pending);
      final acceptedIds = _acceptedKeys(response);
      rejectedChanges = _rejectedChanges(response);
      final completedKeys = {
        ...acceptedIds,
        for (final rejected in rejectedChanges) rejected.key,
      };
      await queue.deleteMany(
        pending
            .where((change) => completedKeys.contains(_changeKey(change)))
            .map((change) => change.id),
      );
    }

    final pull = await client.pull(since: since);
    await _applyEntities(_entities(pull));
    return SyncResult(
      serverTime: _serverTime(pull),
      rejectedChanges: rejectedChanges,
    );
  }

  Future<void> _applyEntities(List<Map<String, dynamic>> entities) async {
    final owned = <OwnedItem>[];
    final wishlist = <WishlistItem>[];
    for (final entity in entities) {
      final type = entity['entity_type'] as String;
      if (type == 'owned_item') {
        owned.add(_ownedItemFromEntity(entity));
      }
      if (type == 'wishlist_item') {
        wishlist.add(_wishlistItemFromEntity(entity));
      }
    }
    await db.transaction(() async {
      await ownedItems.upsertAll(owned);
      await wishlistItems.upsertAll(wishlist);
    });
  }

  OwnedItem _ownedItemFromEntity(Map<String, dynamic> entity) {
    final type = entity['entity_type'] as String;
    final action = entity['action'] as String;
    final payload = _payload(entity);
    final deletedAt = action == 'delete' ? entity['client_changed_at'] : null;
    if (type != 'owned_item') {
      throw FormatException('Expected owned_item entity, got $type');
    }
    return OwnedItem.fromJson({
      ...payload,
      'id': entity['entity_id'],
      'updated_at': entity['client_changed_at'],
      'deleted_at': deletedAt,
    });
  }

  WishlistItem _wishlistItemFromEntity(Map<String, dynamic> entity) {
    final type = entity['entity_type'] as String;
    final action = entity['action'] as String;
    final payload = _payload(entity);
    final deletedAt = action == 'delete' ? entity['client_changed_at'] : null;
    if (type != 'wishlist_item') {
      throw FormatException('Expected wishlist_item entity, got $type');
    }
    return WishlistItem.fromJson({
      ...payload,
      'id': entity['entity_id'],
      'created_at': payload['created_at'] ?? entity['client_changed_at'],
      'updated_at': entity['client_changed_at'],
      'deleted_at': deletedAt,
    });
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

  List<SyncRejectedChange> _rejectedChanges(Map<String, dynamic> response) {
    final rejected = response['rejected'];
    if (rejected == null) {
      return const [];
    }
    if (rejected is! List) {
      throw const FormatException(
        'Sync push response has invalid rejected changes',
      );
    }
    return rejected
        .whereType<Map>()
        .map((item) => SyncRejectedChange.fromJson(
              item.cast<String, dynamic>(),
            ))
        .toList(growable: false);
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

  String _changeKey(SyncChange change) {
    return '${change.entityType}:${change.entityId}';
  }
}

class SyncResult {
  const SyncResult({
    required this.serverTime,
    this.rejectedChanges = const [],
  });

  final DateTime serverTime;
  final List<SyncRejectedChange> rejectedChanges;

  int get rejectedCount => rejectedChanges.length;

  bool get hasRejectedChanges => rejectedChanges.isNotEmpty;
}

class SyncRejectedChange {
  const SyncRejectedChange({
    required this.entityType,
    required this.entityId,
    required this.reason,
    this.currentClientChangedAt,
  });

  final String entityType;
  final String entityId;
  final String reason;
  final DateTime? currentClientChangedAt;

  String get key => '$entityType:$entityId';

  factory SyncRejectedChange.fromJson(Map<String, dynamic> json) {
    final currentClientChangedAt = json['current_client_changed_at'];
    return SyncRejectedChange(
      entityType: json['entity_type'] as String,
      entityId: json['entity_id'] as String,
      reason: json['reason'] as String? ?? 'rejected',
      currentClientChangedAt: currentClientChangedAt is String
          ? DateTime.parse(currentClientChangedAt).toUtc()
          : null,
    );
  }
}
