import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/custom_episode.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle.dart';
import 'package:collectarr_app/core/models/user_metadata_override.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/sync/collectarr_sync_client.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_import_snapshot.dart';
import 'package:collectarr_app/features/collection/repositories/item_images_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_lifecycle_repository.dart';
import 'package:collectarr_app/features/collection/repositories/user_metadata_overrides_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/custom_episodes_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.g.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_owned_item_persistence.dart';
import 'package:collectarr_app/features/library/tracking/watch_session_codec.dart';
import 'package:collectarr_app/features/library/tracking/tracking_lifecycle_codec.dart';
import 'package:collectarr_app/features/library/tracking/custom_episode_codec.dart';
import 'package:collectarr_app/features/collection/repositories/watch_sessions_repository.dart';
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
    required this.ownedPersistence,
    required this.trackingLifecycles,
    required this.wishlistItems,
    LocationRepository? locations,
  }) : locations = locations ?? LocationRepository(db);

  final CollectarrSyncClient client;
  final LocalDatabase db;
  final SyncQueueRepository queue;
  final CatalogTransportRepository catalog;
  final CollectarrOwnedItemPersistence ownedPersistence;
  final TrackingLifecycleRepository trackingLifecycles;
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
    final catalogSnapshots = <CatalogImportSnapshot>[];
    final locationUpserts = <StorageLocation>[];
    final locationDeletes = <String>[];
    final ownedPayloads = <_OwnedSyncPayload>[];
    final tracking = <TrackingLifecycle>[];
    final wishlist = <WishlistItem>[];
    final watchSessions = <WatchSession>[];
    final metadataOverrides = <UserMetadataOverride>[];
    final customEpisodes = <CustomEpisode>[];
    final pickListUpserts = <Map<String, dynamic>>[];
    final pickListDeletes = <String>[];
    // Collect image data from snapshots keyed by the complete catalog ref.
    // Equal IDs are valid across kinds and must never overwrite one another.
    final imageDataByCatalogRef = <CatalogEntityRef, String>{};
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
        final snapshot = _catalogSnapshotFromEntity(entity);
        catalogSnapshots.add(snapshot);
        if (snapshot.coverImageData != null) {
          imageDataByCatalogRef[snapshot.catalogRef] = snapshot.coverImageData!;
        }
      }
      if (type == 'owned_item') {
        ownedPayloads.add(_ownedPayloadFromEntity(entity));
      }
      if (type == 'tracking_entry') {
        tracking.add(_trackingLifecycleFromEntity(entity));
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
      await catalog.upsertImportSnapshots(catalogSnapshots);
      for (final location in locationUpserts) {
        await locations.applySyncedUpsert(location);
      }
      for (final item in ownedPayloads) {
        await ownedPersistence.replaceFromPayload(item.kind, item.payload);
      }
      await trackingLifecycles.upsertAll(tracking);
      await wishlistItems.upsertAll(wishlist);
      if (watchSessions.isNotEmpty) {
        await WatchSessionsRepository(
          db,
          codecs: collectarrWatchSessionCodecs,
        ).upsertAll(watchSessions);
      }
      if (metadataOverrides.isNotEmpty) {
        await UserMetadataOverridesCacheRepository(db)
            .upsertAll(metadataOverrides);
      }
      if (customEpisodes.isNotEmpty) {
        await CustomEpisodesRepository(
          db,
          codecs: collectarrCustomEpisodeCodecs,
        ).upsertAll(customEpisodes);
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
    if (imageDataByCatalogRef.isNotEmpty && ownedPayloads.isNotEmpty) {
      final imagesRepo = ItemImagesCacheRepository(db);
      final ownedByCatalogRef = <CatalogEntityRef, OwnedItemRef>{};
      for (final item in ownedPayloads) {
        final rawCatalogRef = item.payload['catalog_ref'];
        if (rawCatalogRef is! Map) continue;
        final catalogRef = CatalogEntityRef.fromJson(
          Map<String, dynamic>.from(rawCatalogRef),
        );
        ownedByCatalogRef[catalogRef] = item.ref;
      }
      for (final entry in imageDataByCatalogRef.entries) {
        final ownedRef = ownedByCatalogRef[entry.key];
        if (ownedRef == null) continue;
        final deterministicId =
            _uuid.v5(Namespace.url.value, '${ownedRef.key}:front_cover');
        await imagesRepo.upsert(
          id: deterministicId,
          ownedRef: ownedRef,
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

  CatalogImportSnapshot _catalogSnapshotFromEntity(
    Map<String, dynamic> entity,
  ) {
    final type = entity['entity_type'] as String;
    if (type != 'library_item_snapshot') {
      throw FormatException('Expected library_item_snapshot entity, got $type');
    }
    return catalog.snapshotFromSyncPayload(
      id: entity['entity_id'] as String,
      payload: _payload(entity),
    );
  }

  _OwnedSyncPayload _ownedPayloadFromEntity(
    Map<String, dynamic> entity,
  ) {
    final type = entity['entity_type'] as String;
    final action = entity['action'] as String;
    final payload = _payload(entity);
    final deletedAt = action == 'delete' ? entity['client_changed_at'] : null;
    if (type != 'owned_item') {
      throw FormatException('Expected owned_item entity, got $type');
    }
    final rawCatalogRef = payload['catalog_ref'];
    if (rawCatalogRef is! Map) {
      throw const FormatException(
        'Owned item sync payload is missing catalog_ref',
      );
    }
    final catalogRef = CatalogEntityRef.fromJson(
      Map<String, dynamic>.from(rawCatalogRef),
    );
    final kind = catalogRef.mediaKind;
    final normalizedPayload = {
      ...payload,
      'id': entity['entity_id'],
      'created_at': payload['created_at'] ?? entity['client_changed_at'],
      'updated_at': entity['client_changed_at'],
      'deleted_at': deletedAt,
    };
    return (
      kind: kind,
      ref: OwnedItemRef.fromJson({
        'kind': kind.apiValue,
        'id': entity['entity_id'],
      }),
      payload: normalizedPayload,
    );
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

  TrackingLifecycle _trackingLifecycleFromEntity(Map<String, dynamic> entity) {
    final type = entity['entity_type'] as String;
    final action = entity['action'] as String;
    final payload = _payload(entity);
    final deletedAt = action == 'delete' ? entity['client_changed_at'] : null;
    if (type != 'tracking_entry') {
      throw FormatException('Expected tracking_entry entity, got $type');
    }
    final rawRef = payload['target_ref'] ?? payload['catalog_ref'];
    final kind = rawRef is Map
        ? catalogMediaKindFromValue(rawRef['kind'])
        : CatalogMediaKind.unknown;
    final codec = kind.isUnknown
        ? null
        : collectarrTrackingLifecycleCodecs
            .cast<TrackingLifecycleCodec?>()
            .firstWhere(
              (candidate) => candidate?.kind == kind,
              orElse: () => null,
            );
    if (codec != null) {
      return codec.fromSyncPayload(
        payload: payload,
        id: entity['entity_id'] as String,
        updatedAt: DateTime.parse(entity['client_changed_at'] as String),
        deletedAt:
            deletedAt == null ? null : DateTime.parse(deletedAt as String),
      );
    }
    throw UnsupportedError(
      'No kind-owned tracking-entry codec is registered for '
      '${kind.apiValue}',
    );
  }

  WatchSession _watchSessionFromEntity(Map<String, dynamic> entity) {
    final type = entity['entity_type'] as String;
    final action = entity['action'] as String;
    final payload = _payload(entity);
    final deletedAt = action == 'delete' ? entity['client_changed_at'] : null;
    if (type != 'watch_session') {
      throw FormatException('Expected watch_session entity, got $type');
    }
    final rawRef = payload['target_ref'] ?? payload['catalog_ref'];
    final kind = rawRef is Map
        ? catalogMediaKindFromValue(rawRef['kind'])
        : CatalogMediaKind.unknown;
    final codec = kind.isUnknown
        ? null
        : collectarrWatchSessionCodecs.cast<WatchSessionCodec?>().firstWhere(
              (candidate) => candidate?.kind == kind,
              orElse: () => null,
            );
    if (codec != null) {
      return codec.fromSyncPayload(
        payload: payload,
        id: entity['entity_id'] as String,
        updatedAt: DateTime.parse(entity['client_changed_at'] as String),
        deletedAt:
            deletedAt == null ? null : DateTime.parse(deletedAt as String),
      );
    }
    throw UnsupportedError(
      'No kind-owned watch-session codec is registered for ${kind.apiValue}',
    );
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
    final rawRef = payload['catalog_ref'];
    final kind = rawRef is Map
        ? catalogMediaKindFromValue(rawRef['kind'])
        : CatalogMediaKind.unknown;
    final codec = kind.isUnknown
        ? null
        : collectarrCustomEpisodeCodecs.cast<CustomEpisodeCodec?>().firstWhere(
              (candidate) => candidate?.kind == kind,
              orElse: () => null,
            );
    if (codec != null) {
      return codec.fromSyncPayload(
        payload: payload,
        id: entity['entity_id'] as String,
        updatedAt: DateTime.parse(entity['client_changed_at'] as String),
        deletedAt:
            deletedAt == null ? null : DateTime.parse(deletedAt as String),
      );
    }
    throw UnsupportedError(
      'No kind-owned custom-episode codec is registered for ${kind.apiValue}',
    );
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

typedef _OwnedSyncPayload = ({
  CatalogMediaKind kind,
  OwnedItemRef ref,
  JsonMap payload,
});
