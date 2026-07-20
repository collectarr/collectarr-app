import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/custom_episode.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/user_metadata_override.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/sync/collectarr_sync_client.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/item_images_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_entries_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/user_metadata_overrides_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/custom_episodes_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/watch_sessions_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Orchestrates a full sync round-trip: push pending changes → pull server
/// entities → apply them to the local cache.
///
/// Lives in features/sync/ (not core/sync/) so it may freely import
/// feature-layer repositories (catalog, collection, etc.).
/// core/sync/ contains only protocol primitives and the HTTP client.
class SyncApplyService {
  SyncApplyService({
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
    final watchSessions = <WatchSession>[];
    final metadataOverrides = <UserMetadataOverride>[];
    final customEpisodes = <CustomEpisode>[];
    final pickListUpserts = <Map<String, dynamic>>[];
    final pickListDeletes = <String>[];
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
      if (type == 'watch_session') {
        watchSessions.add(_watchSessionFromEntity(entity));
      }
      if (type == 'metadata_override') {
        metadataOverrides.add(_metadataOverrideFromEntity(entity));
      }
      if (type == 'custom_episode') {
        customEpisodes.add(_customEpisodeFromEntity(entity));
      }
      if (type == 'pick_list_value') {
        if (entity['action'] == 'delete') {
          pickListDeletes.add(entity['entity_id'] as String);
        } else {
          pickListUpserts.add({
            'id': entity['entity_id'] as String,
            ..._payload(entity),
          });
        }
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
      if (watchSessions.isNotEmpty) {
        await WatchSessionsCacheRepository(db).upsertAll(watchSessions);
      }
      if (metadataOverrides.isNotEmpty) {
        await UserMetadataOverridesCacheRepository(db)
            .upsertAll(metadataOverrides);
      }
      if (customEpisodes.isNotEmpty) {
        await CustomEpisodesCacheRepository(db).upsertAll(customEpisodes);
      }
      if (pickListUpserts.isNotEmpty || pickListDeletes.isNotEmpty) {
        await _applyPickListValues(pickListUpserts, pickListDeletes);
      }
      for (final locationId in locationDeletes) {
        await locations.applySyncedDelete(locationId);
      }
    });

    // Store image bytes outside the main transaction so data sync completes
    // first and images are processed in the background.
    if (imageDataByItemId.isNotEmpty && owned.isNotEmpty) {
      final imagesRepo = ItemImagesCacheRepository(db);
      final ownedByItemId = <String, String>{};
      for (final item in owned) {
        ownedByItemId[item.itemId] = item.id;
      }
      for (final entry in imageDataByItemId.entries) {
        final ownedItemId = ownedByItemId[entry.key];
        if (ownedItemId == null) continue;
        final deterministicId =
            _uuid.v5(Namespace.url.value, '$ownedItemId:front_cover');
        await imagesRepo.upsert(
          id: deterministicId,
          ownedItemId: ownedItemId,
          imageType: 'front_cover',
          imageData: base64Decode(entry.value),
        );
      }
    }
  }

  Future<void> _applyPickListValues(
    List<Map<String, dynamic>> upserts,
    List<String> deletes,
  ) async {
    if (upserts.isNotEmpty) {
      await db.batch((batch) {
        for (final data in upserts) {
          batch.insert(
            db.pickListValuesCache,
            PickListValuesCacheCompanion.insert(
              id: data['id'] as String,
              listName: data['list_name'] as String,
              mediaKind: Value(data['media_kind'] as String?),
              value: data['value'] as String,
              sortOrder: Value(data['sort_order'] as int? ?? 0),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    }
    if (deletes.isNotEmpty) {
      await (db.delete(db.pickListValuesCache)
            ..where((t) => t.id.isIn(deletes)))
          .go();
    }
  }

  // ---------------------------------------------------------------------------
  // Entity deserializers
  // ---------------------------------------------------------------------------

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
      'created_at': payload['created_at'] ?? entity['client_changed_at'],
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

  WatchSession _watchSessionFromEntity(Map<String, dynamic> entity) {
    final type = entity['entity_type'] as String;
    final action = entity['action'] as String;
    final payload = _payload(entity);
    final deletedAt = action == 'delete' ? entity['client_changed_at'] : null;
    if (type != 'watch_session') {
      throw FormatException('Expected watch_session entity, got $type');
    }
    return WatchSession.fromJson({
      ...payload,
      'id': entity['entity_id'],
      'updated_at': entity['client_changed_at'],
      'deleted_at': deletedAt,
    });
  }

  UserMetadataOverride _metadataOverrideFromEntity(
    Map<String, dynamic> entity,
  ) {
    final type = entity['entity_type'] as String;
    final action = entity['action'] as String;
    final payload = _payload(entity);
    final deletedAt = action == 'delete' ? entity['client_changed_at'] : null;
    if (type != 'metadata_override') {
      throw FormatException('Expected metadata_override entity, got $type');
    }
    return UserMetadataOverride.fromJson({
      ...payload,
      'id': entity['entity_id'],
      'updated_at': entity['client_changed_at'],
      'deleted_at': deletedAt,
    });
  }

  CustomEpisode _customEpisodeFromEntity(Map<String, dynamic> entity) {
    final type = entity['entity_type'] as String;
    final action = entity['action'] as String;
    final payload = _payload(entity);
    final deletedAt = action == 'delete' ? entity['client_changed_at'] : null;
    if (type != 'custom_episode') {
      throw FormatException('Expected custom_episode entity, got $type');
    }
    return CustomEpisode.fromJson({
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

  // ---------------------------------------------------------------------------
  // Response parsing helpers
  // ---------------------------------------------------------------------------

  Set<String> _acceptedKeys(Map<String, dynamic> response) {
    final accepted = response['accepted'];
    if (accepted is! List) {
      throw const FormatException(
        'Sync push response is missing accepted changes',
      );
    }
    return accepted
        .whereType<Map<dynamic, dynamic>>()
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
    return rejected.whereType<Map<dynamic, dynamic>>().map((item) {
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
        .whereType<Map<dynamic, dynamic>>()
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
