import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/sync/collectarr_sync_client.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/item_images_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_entries_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class SyncService {
  SyncService({
    required this.client,
    required this.db,
    required this.queue,
    required this.catalog,
    required this.ownedItems,
    required this.trackingEntries,
    required this.wishlistItems,
    LocationRepository? locations,
  }) : locations = locations ?? LocationRepository(db);

  final CollectarrSyncClient client;
  final LocalDatabase db;
  final SyncQueueRepository queue;
  final CatalogCacheRepository catalog;
  final OwnedItemsCacheRepository ownedItems;
  final TrackingEntriesCacheRepository trackingEntries;
  final WishlistItemsCacheRepository wishlistItems;
  final LocationRepository locations;

  Future<SyncResult> syncNow(String deviceId, {DateTime? since}) async {
    var rejectedChanges = const <SyncRejectedChange>[];
    final pending = await queue.listPending();
    if (pending.isNotEmpty) {
      final response = await client.push(deviceId: deviceId, changes: pending);
      final acceptedIds = _acceptedKeys(response);
      rejectedChanges = _rejectedChanges(response, pending);
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
    final catalogSnapshots = <CatalogItem>[];
    final locationUpserts = <StorageLocation>[];
    final locationDeletes = <String>[];
    final owned = <OwnedItem>[];
    final tracking = <TrackingEntry>[];
    final wishlist = <WishlistItem>[];
    // Collect image data from snapshots keyed by item ID.
    final imageDataByItemId = <String, String>{};
    for (final entity in entities) {
      final type = entity['entity_type'] as String;
      if (type == 'location') {
        if (entity['action'] == 'delete') {
          locationDeletes.add(entity['entity_id'] as String);
        } else {
          locationUpserts.add(_locationFromEntity(entity));
        }
      }
      if (type == 'library_item_snapshot' && entity['action'] == 'upsert') {
        final item = _catalogItemFromEntity(entity);
        catalogSnapshots.add(item);
        if (item.coverImageData != null) {
          imageDataByItemId[item.id] = item.coverImageData!;
        }
      }
      if (type == 'owned_item') {
        owned.add(_ownedItemFromEntity(entity));
      }
      if (type == 'tracking_entry') {
        tracking.add(_trackingEntryFromEntity(entity));
      }
      if (type == 'wishlist_item') {
        wishlist.add(_wishlistItemFromEntity(entity));
      }
    }
    await db.transaction(() async {
      await catalog.upsertAll(catalogSnapshots);
      for (final location in locationUpserts) {
        await locations.applySyncedUpsert(location);
      }
      await ownedItems.upsertAll(owned);
      await trackingEntries.upsertAll(tracking);
      await wishlistItems.upsertAll(wishlist);
      for (final locationId in locationDeletes) {
        await locations.applySyncedDelete(locationId);
      }
      // Store image bytes locally for any snapshots that carried them.
      if (imageDataByItemId.isNotEmpty && owned.isNotEmpty) {
        final imagesRepo = ItemImagesCacheRepository(db);
        final ownedByItemId = <String, String>{};
        for (final item in owned) {
          ownedByItemId[item.itemId] = item.id;
        }
        for (final entry in imageDataByItemId.entries) {
          final ownedItemId = ownedByItemId[entry.key];
          if (ownedItemId == null) continue;
          // Deterministic ID so re-syncing the same image is an update, not a
          // duplicate insert.
            final deterministicId =
              _uuid.v5(Namespace.url.value, '$ownedItemId:front_cover');
          await imagesRepo.upsert(
            id: deterministicId,
            ownedItemId: ownedItemId,
            imageType: 'front_cover',
            imageData: entry.value,
          );
        }
      }
    });
  }

  CatalogItem _catalogItemFromEntity(Map<String, dynamic> entity) {
    final type = entity['entity_type'] as String;
    if (type != 'library_item_snapshot') {
      throw FormatException('Expected library_item_snapshot entity, got $type');
    }
    return CatalogItem.fromJson({
      ..._payload(entity),
      'id': entity['entity_id'],
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

  TrackingEntry _trackingEntryFromEntity(Map<String, dynamic> entity) {
    final type = entity['entity_type'] as String;
    final action = entity['action'] as String;
    final payload = _payload(entity);
    final deletedAt = action == 'delete' ? entity['client_changed_at'] : null;
    if (type != 'tracking_entry') {
      throw FormatException('Expected tracking_entry entity, got $type');
    }
    return TrackingEntry.fromJson({
      ...payload,
      'id': entity['entity_id'],
      'updated_at': entity['client_changed_at'],
      'deleted_at': deletedAt,
    });
  }

  StorageLocation _locationFromEntity(Map<String, dynamic> entity) {
    final type = entity['entity_type'] as String;
    if (type != 'location') {
      throw FormatException('Expected location entity, got $type');
    }
    return StorageLocation.fromSyncPayload(
      entity['entity_id'] as String,
      _payload(entity),
    );
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

  List<SyncRejectedChange> _rejectedChanges(
    Map<String, dynamic> response,
    List<SyncChange> pending,
  ) {
    final rejected = response['rejected'];
    if (rejected == null) {
      return const [];
    }
    if (rejected is! List) {
      throw const FormatException(
        'Sync push response has invalid rejected changes',
      );
    }
    final pendingByKey = {
      for (final change in pending) _changeKey(change): change,
    };
    return rejected.whereType<Map>().map((item) {
      final json = item.cast<String, dynamic>();
      final key = '${json['entity_type']}:${json['entity_id']}';
      return SyncRejectedChange.fromJson(
        json,
        localChange: pendingByKey[key],
      );
    }).toList(growable: false);
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
    this.serviceAction,
    this.servicePayload,
    this.localAction,
    this.localPayload,
    this.localClientChangedAt,
  });

  final String entityType;
  final String entityId;
  final String reason;
  final DateTime? currentClientChangedAt;
  final String? serviceAction;
  final Map<String, dynamic>? servicePayload;
  final String? localAction;
  final Map<String, dynamic>? localPayload;
  final DateTime? localClientChangedAt;

  String get key => '$entityType:$entityId';

  bool get hasDiffPayload => servicePayload != null || localPayload != null;

  factory SyncRejectedChange.fromJson(
    Map<String, dynamic> json, {
    SyncChange? localChange,
  }) {
    final currentClientChangedAt = json['current_client_changed_at'];
    final currentPayload = json['current_payload'];
    return SyncRejectedChange(
      entityType: json['entity_type'] as String,
      entityId: json['entity_id'] as String,
      reason: json['reason'] as String? ?? 'rejected',
      currentClientChangedAt: currentClientChangedAt is String
          ? DateTime.parse(currentClientChangedAt).toUtc()
          : null,
      serviceAction: json['current_action'] as String?,
      servicePayload:
          currentPayload is Map ? currentPayload.cast<String, dynamic>() : null,
      localAction: localChange?.action,
      localPayload: localChange?.payload,
      localClientChangedAt: localChange?.clientChangedAt,
    );
  }
}
