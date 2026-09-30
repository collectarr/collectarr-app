import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/owned_copy_projection.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/core/models/tracking_state_ref.dart';
import 'package:collectarr_app/core/models/tracking_unit_summary.dart';
import 'package:collectarr_app/core/models/user_metadata_override.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/sync/collectarr_sync_client.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_repository.dart';
import 'package:collectarr_app/features/library/tracking/tracking_unit_storage_repository.dart';
import 'package:collectarr_app/features/library/tracking/tracking_unit_storage_codec.dart';
import 'package:collectarr_app/features/collection/repositories/user_metadata_overrides_cache_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_owned_item_persistence.dart';
import 'package:collectarr_app/features/library/tracking/watch_session_codec.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_codec.dart';
import 'package:collectarr_app/features/library/tracking/custom_episode_codec.dart';
import 'package:collectarr_app/features/library/tracking/watch_sessions_repository.dart';
import 'package:collectarr_app/features/library/tracking/library_tracking_registry.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:drift/drift.dart';

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
    required this.ownedPersistence,
    required this.trackingRecords,
    required this.wishlistItems,
    LocationRepository? locations,
  }) : locations = locations ?? LocationRepository(db);

  final CollectarrSyncClient client;
  final LocalDatabase db;
  final SyncQueueRepository queue;
  final CollectarrOwnedItemPersistence ownedPersistence;
  final TrackingStorageRepository trackingRecords;
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

  Future<void> _applyEntities(List<JsonMap> entities) async {
    final locationUpserts = <StorageLocation>[];
    final locationDeletes = <String>[];
    final ownedPayloads = <_OwnedSyncPayload>[];
    final tracking = <TrackingStorageSyncInput>[];
    final trackingUnits = <TrackingUnitSummary>[];
    final wishlist = <WishlistItem>[];
    final watchSessions = <WatchSession>[];
    final metadataOverrides = <UserMetadataOverride>[];
    final customEpisodes = <_CustomEpisodeSyncInput>[];
    final pickListUpserts = <JsonMap>[];
    final pickListDeletes = <String>[];
    for (final entity in entities) {
      final type = entity['entity_type'] as String;
      if (type == 'location') {
        if (entity['action'] == 'delete') {
          locationDeletes.add(entity['entity_id'] as String);
        } else {
          locationUpserts.add(_locationFromEntity(entity));
        }
      }
      if (type == 'owned_copy') {
        ownedPayloads.add(_ownedPayloadFromEntity(entity));
      }
      if (type == 'tracking_entry') {
        tracking.add(_trackingRecordFromEntity(entity));
      }
      if (type == 'tracking_unit') {
        trackingUnits.add(_trackingUnitFromEntity(entity));
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
        customEpisodes.add(_customEpisodeSyncInputFromEntity(entity));
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
      for (final location in locationUpserts) {
        await locations.applySyncedUpsert(location);
      }
      for (final item in ownedPayloads) {
        await ownedPersistence.replaceFromPayload(item.kind, item.payload);
      }
      await trackingRecords.upsertSyncPayloads(tracking);
      if (trackingUnits.isNotEmpty) {
        await TrackingUnitStorageRepository(
          db,
          codecs: libraryTrackingUnitCodecs,
        ).upsertAll(trackingUnits);
      }
      await wishlistItems.upsertAll(wishlist);
      if (watchSessions.isNotEmpty) {
        await WatchSessionsRepository(
          db,
          codecs: libraryWatchSessionCodecs,
        ).upsertAll(watchSessions);
      }
      if (metadataOverrides.isNotEmpty) {
        await UserMetadataOverridesCacheRepository(db)
            .upsertAll(metadataOverrides);
      }
      for (final customEpisode in customEpisodes) {
        final codec = _customEpisodeCodecFor(customEpisode.payload);
        await codec.applySyncPayload(
          db,
          payload: customEpisode.payload,
          id: customEpisode.id,
          updatedAt: customEpisode.updatedAt,
          deletedAt: customEpisode.deletedAt,
        );
      }
      if (pickListUpserts.isNotEmpty || pickListDeletes.isNotEmpty) {
        await _applyPickListValues(pickListUpserts, pickListDeletes);
      }
      for (final locationId in locationDeletes) {
        await locations.applySyncedDelete(locationId);
      }
    });
  }

  Future<void> _applyPickListValues(
    List<JsonMap> upserts,
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

  _OwnedSyncPayload _ownedPayloadFromEntity(
    JsonMap entity,
  ) {
    final type = entity['entity_type'] as String;
    final action = entity['action'] as String;
    final payload = _payload(entity);
    final deletedAt = action == 'delete' ? entity['client_changed_at'] : null;
    if (type != 'owned_copy') {
      throw FormatException('Expected owned_copy entity, got $type');
    }
    final rawCatalogRef = payload['catalog_ref'];
    if (rawCatalogRef is! Map) {
      throw const FormatException(
        'Owned copy sync payload is missing catalog_ref',
      );
    }
    final catalogRef = CatalogEntityRef.fromJson(
      JsonMap.from(rawCatalogRef),
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
      ref: OwnedCopyRef.fromJson({
        'kind': kind.apiValue,
        'id': entity['entity_id'],
      }),
      payload: normalizedPayload,
    );
  }

  WishlistItem _wishlistItemFromEntity(JsonMap entity) {
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

  TrackingStorageSyncInput _trackingRecordFromEntity(JsonMap entity) {
    final type = entity['entity_type'] as String;
    final action = entity['action'] as String;
    final payload = _payload(entity);
    final deletedAt = action == 'delete' ? entity['client_changed_at'] : null;
    if (type != 'tracking_entry') {
      throw FormatException('Expected tracking_entry entity, got $type');
    }
    final rawRef = payload['target_ref'] ?? payload['catalog_ref'];
    if (rawRef is! Map) {
      throw const FormatException(
        'Tracking entry sync payload is missing catalog_ref',
      );
    }
    final catalogRef = CatalogEntityRef.fromJson(JsonMap.from(rawRef));
    return TrackingStorageSyncInput(
      ref: TrackingStateRef(
        kind: catalogRef.mediaKind,
        id: entity['entity_id'] as String,
      ),
      payload: payload,
      updatedAt: DateTime.parse(entity['client_changed_at'] as String),
      deletedAt: deletedAt == null ? null : DateTime.parse(deletedAt as String),
    );
  }

  TrackingUnitSummary _trackingUnitFromEntity(JsonMap entity) {
    final type = entity['entity_type'] as String;
    if (type != 'tracking_unit') {
      throw FormatException('Expected tracking_unit entity, got $type');
    }
    final payload = _payload(entity);
    final rawRef = payload['catalog_ref'] ?? payload['target_ref'];
    if (rawRef is! Map) {
      throw const FormatException(
        'Tracking unit sync payload is missing catalog_ref',
      );
    }
    final catalogRef = CatalogEntityRef.fromJson(JsonMap.from(rawRef));
    final codec =
        libraryTrackingUnitCodecs.cast<TrackingUnitStorageCodec?>().firstWhere(
              (candidate) => candidate?.kind == catalogRef.mediaKind,
              orElse: () => null,
            );
    if (codec == null) {
      throw UnsupportedError(
        'No tracking-unit codec is registered for ${catalogRef.mediaKind.apiValue}',
      );
    }
    final action = entity['action'] as String;
    final changedAt = DateTime.parse(entity['client_changed_at'] as String);
    return codec.fromSyncPayload(
      id: entity['entity_id'] as String,
      payload: payload,
      updatedAt: changedAt,
      deletedAt: action == 'delete' ? changedAt : null,
    );
  }

  WatchSession _watchSessionFromEntity(JsonMap entity) {
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
        : libraryWatchSessionCodecs.cast<WatchSessionCodec?>().firstWhere(
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
    JsonMap entity,
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

  _CustomEpisodeSyncInput _customEpisodeSyncInputFromEntity(
    JsonMap entity,
  ) {
    final type = entity['entity_type'] as String;
    final action = entity['action'] as String;
    final payload = _payload(entity);
    final deletedAt = action == 'delete' ? entity['client_changed_at'] : null;
    if (type != 'custom_episode') {
      throw FormatException('Expected custom_episode entity, got $type');
    }
    return _CustomEpisodeSyncInput(
      id: entity['entity_id'] as String,
      payload: payload,
      updatedAt: DateTime.parse(entity['client_changed_at'] as String),
      deletedAt: deletedAt == null ? null : DateTime.parse(deletedAt as String),
    );
  }

  CustomEpisodeSyncCodec _customEpisodeCodecFor(JsonMap payload) {
    final rawRef = payload['catalog_ref'];
    final kind = rawRef is Map
        ? catalogMediaKindFromValue(rawRef['kind'])
        : CatalogMediaKind.unknown;
    for (final codec in libraryCustomEpisodeCodecs) {
      if (codec.kind == kind) return codec;
    }
    throw UnsupportedError(
      'No kind-owned custom-episode codec is registered for ${kind.apiValue}',
    );
  }

  StorageLocation _locationFromEntity(JsonMap entity) {
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

  Set<String> _acceptedKeys(JsonMap response) {
    final accepted = response['accepted'];
    if (accepted is! List) {
      throw const FormatException(
        'Sync push response is missing accepted changes',
      );
    }
    return accepted
        .whereType<Map<Object?, Object?>>()
        .map((item) => JsonMap.from(item.cast<String, Object?>()))
        .where(
          (item) =>
              item['entity_type'] is String && item['entity_id'] is String,
        )
        .map((item) => '${item['entity_type']}:${item['entity_id']}')
        .toSet();
  }

  List<SyncRejectedChange> _rejectedChanges(
    JsonMap response,
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
    return rejected.whereType<Map<Object?, Object?>>().map((item) {
      final json = JsonMap.from(item.cast<String, Object?>());
      final key = '${json['entity_type']}:${json['entity_id']}';
      return SyncRejectedChange.fromJson(
        json,
        localChange: pendingByKey[key],
      );
    }).toList(growable: false);
  }

  List<JsonMap> _entities(JsonMap response) {
    final entities = response['entities'];
    if (entities is! List) {
      throw const FormatException('Sync pull response is missing entities');
    }
    return entities
        .whereType<Map<Object?, Object?>>()
        .map((item) => JsonMap.from(item.cast<String, Object?>()))
        .toList(growable: false);
  }

  JsonMap _payload(JsonMap entity) {
    final payload = entity['payload'];
    if (payload is! Map) {
      throw const FormatException('Sync entity is missing payload');
    }
    return JsonMap.from(payload.cast<String, Object?>());
  }

  DateTime _serverTime(JsonMap response) {
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
  OwnedCopyRef ref,
  JsonMap payload,
});

final class _CustomEpisodeSyncInput {
  const _CustomEpisodeSyncInput({
    required this.id,
    required this.payload,
    required this.updatedAt,
    required this.deletedAt,
  });

  final String id;
  final JsonMap payload;
  final DateTime updatedAt;
  final DateTime? deletedAt;
}
