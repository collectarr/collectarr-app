import 'package:collectarr_app/features/library/entries/library_entry_record.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/core/models/user_folder.dart';
import 'package:collectarr_app/core/models/user_external_link.dart';
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
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/collection/repositories/item_image_repository.dart';
import 'package:collectarr_app/features/collection/repositories/loan_repository.dart';
import 'package:collectarr_app/features/collection/repositories/reading_queue_repository.dart';
import 'package:collectarr_app/features/collection/repositories/user_folder_repository.dart';
import 'package:collectarr_app/features/collection/repositories/user_external_links_cache_repository.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_repository.dart';
import 'package:collectarr_app/features/library/tracking/tracking_unit_storage_repository.dart';
import 'package:collectarr_app/features/library/tracking/tracking_unit_storage_codec.dart';
import 'package:collectarr_app/features/collection/repositories/user_metadata_overrides_cache_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_entry_persistence.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_listening_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_listening.dart';
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
    required this.entryPersistence,
    required this.trackingRecords,
    required this.wishlistItems,
    LocationRepository? locations,
  }) : locations = locations ?? LocationRepository(db);

  final CollectarrSyncClient client;
  final LocalDatabase db;
  final SyncQueueRepository queue;
  final CollectarrLibraryEntryPersistence entryPersistence;
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
    final userFolderUpserts = <UserFolder>[];
    final userFolderDeletes = <String>[];
    final entryPayloads = <_EntrySyncPayload>[];
    final tracking = <TrackingStorageSyncInput>[];
    final trackingUnits = <TrackingUnitSummary>[];
    final wishlist = <WishlistItem>[];
    final watchSessions = <WatchSession>[];
    final musicListenEvents = <MusicListenEvent>[];
    final metadataOverrides = <UserMetadataOverride>[];
    final entryImages = <({LibraryEntryRef ref, List<ItemImage> images})>[];
    final entryCustomFields =
        <({LibraryEntryRef ref, List<CustomFieldValue> values})>[];
    final entryExternalLinks =
        <({LibraryEntryRef ref, List<UserExternalLink> links})>[];
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
      if (type == 'user_folder') {
        if (entity['action'] == 'delete') {
          userFolderDeletes.add(entity['entity_id'] as String);
        } else {
          userFolderUpserts.add(_userFolderFromEntity(entity));
        }
      }
      if (type == 'library_entry') {
        final payload = _entryPayloadFromEntity(entity);
        entryPayloads.add(payload.entry);
        entryImages.add((ref: payload.entry.ref, images: payload.images));
        entryCustomFields
            .add((ref: payload.entry.ref, values: payload.customFields));
        entryExternalLinks
            .add((ref: payload.entry.ref, links: payload.externalLinks));
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
      if (type == 'music_listen_event') {
        musicListenEvents.add(_musicListenEventFromEntity(entity));
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
      final folderRepository = UserFolderRepository(db);
      for (final folder in userFolderUpserts) {
        await folderRepository.applySyncedUpsert(folder);
      }
      for (final item in entryPayloads) {
        await entryPersistence.replaceFromPayload(item.kind, item.payload);
      }
      final loanRepository = LoanRepository(db);
      final readingQueueRepository = ReadingQueueRepository(db);
      for (final entry in entryPayloads) {
        await loanRepository.replaceForLibraryEntry(entry.ref, entry.loans);
        await folderRepository.replaceMembershipsForItem(
          entry.ref,
          entry.folderMemberships,
        );
        await readingQueueRepository.applySyncedPosition(
          entry.ref,
          entry.readingQueuePosition,
        );
      }
      final imageRepository = ItemImageRepository(db);
      for (final entry in entryImages) {
        await imageRepository.deleteAllForLibraryEntryRef(entry.ref);
        for (final image in entry.images) {
          await imageRepository.add(image);
        }
      }
      final customFieldRepository = CustomFieldRepository(db);
      for (final entry in entryCustomFields) {
        await customFieldRepository.deleteValuesForTarget(
          targetId: entry.ref.key,
          targetScope: CustomFieldTargetScope.libraryEntry,
        );
        await customFieldRepository.upsertValues(entry.values);
      }
      final externalLinksRepository = UserExternalLinksCacheRepository(db);
      for (final entry in entryExternalLinks) {
        await externalLinksRepository.replaceSyncedForLibraryEntry(
          entry.ref,
          entry.links,
        );
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
      if (musicListenEvents.isNotEmpty) {
        await MusicListeningRepository(db).upsertAll(musicListenEvents);
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
      for (final folderId in userFolderDeletes) {
        await folderRepository.applySyncedDelete(folderId);
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

  _EntrySyncPayloadWithAttachments _entryPayloadFromEntity(
    JsonMap entity,
  ) {
    final type = entity['entity_type'] as String;
    final action = entity['action'] as String;
    final payload = _payload(entity);
    if (type != 'library_entry') {
      throw FormatException('Expected library_entry entity, got $type');
    }
    final entityId = entity['entity_id'];
    if (entityId is! String || entityId.trim().isEmpty) {
      throw const FormatException('Sync library_entry is missing entity_id');
    }
    final payloadId = payload['id'];
    if (payloadId is String && payloadId != entityId) {
      throw const FormatException(
        'Sync library_entry payload id does not match entity_id',
      );
    }
    final changedAt = entity['client_changed_at'];
    if (changedAt is! String) {
      throw const FormatException(
        'Sync library_entry is missing client_changed_at',
      );
    }
    final isDelete = action == 'delete';
    final rawPersonalData = payload['personal_data'];
    if (rawPersonalData is! Map) {
      throw const FormatException(
          'Sync library_entry is missing personal_data');
    }
    final personalData = Map<String, dynamic>.from(rawPersonalData);
    final rawImages = _syncAttachmentRows(
      personalData.remove(libraryEntrySyncImagesKey),
      libraryEntrySyncImagesKey,
    );
    final rawCustomFields = _syncAttachmentRows(
      personalData.remove(libraryEntrySyncCustomFieldsKey),
      libraryEntrySyncCustomFieldsKey,
    );
    final rawExternalLinks = _syncAttachmentRows(
      personalData.remove(libraryEntrySyncExternalLinksKey),
      libraryEntrySyncExternalLinksKey,
    );
    final rawLoans = _syncAttachmentRows(
      personalData.remove(libraryEntrySyncLoansKey),
      libraryEntrySyncLoansKey,
    );
    final rawFolderMemberships = _syncAttachmentRows(
      personalData.remove(libraryEntrySyncFolderMembershipsKey),
      libraryEntrySyncFolderMembershipsKey,
    );
    final readingQueuePosition =
        personalData.remove(libraryEntrySyncReadingQueuePositionKey);
    if (readingQueuePosition != null && readingQueuePosition is! int) {
      throw const FormatException(
        'Sync library_entry reading queue position must be an integer or null.',
      );
    }
    final normalizedPayload = {
      ...payload,
      'id': entityId,
      'personal_data': personalData,
      'updated_at': payload['updated_at'] ?? changedAt,
      'deleted_at':
          isDelete ? payload['deleted_at'] ?? changedAt : payload['deleted_at'],
    };
    final record = LibraryEntryRecord.fromJson(normalizedPayload);
    final ref =
        LibraryEntryRef(kind: record.kind, id: LibraryEntryId(record.id));
    final images = <ItemImage>[
      for (final value in rawImages)
        ItemImage.fromJson({...value, 'library_entry_ref': ref.toJson()}),
    ];
    final loans = <Loan>[
      for (final value in rawLoans)
        Loan.fromJson({...value, 'library_entry_ref': ref.toJson()}),
    ];
    final folderMemberships = <({String folderId, int sortOrder})>[
      for (final value in rawFolderMemberships)
        _folderMembershipFromJson(value),
    ];
    final customFields = <CustomFieldValue>[
      for (final value in rawCustomFields)
        CustomFieldValue(
          id: value['id'] as String,
          targetId: ref.key,
          targetScope: CustomFieldTargetScope.libraryEntry,
          fieldDefinitionId: value['field_definition_id'] as String,
          value: value['value'] as String?,
          updatedAt: DateTime.parse(
            value['updated_at'] as String? ?? changedAt,
          ),
        ),
    ];
    final externalLinks = <UserExternalLink>[
      if (!isDelete)
        for (final value in rawExternalLinks)
          UserExternalLink.fromJson({
            ...value,
            'library_entry_ref': ref.toJson(),
          }),
    ];
    return (
      entry: (
        kind: record.kind,
        ref: ref,
        payload: normalizedPayload,
        loans: isDelete ? const [] : loans,
        folderMemberships: isDelete ? const [] : folderMemberships,
        readingQueuePosition: isDelete ? null : readingQueuePosition as int?,
      ),
      images: images,
      customFields: customFields,
      externalLinks: isDelete ? const [] : externalLinks,
    );
  }

  UserFolder _userFolderFromEntity(JsonMap entity) {
    final payload = _payload(entity);
    return UserFolder.fromJson({
      ...payload,
      'id': entity['entity_id'],
    });
  }

  ({String folderId, int sortOrder}) _folderMembershipFromJson(
    Map<String, Object?> json,
  ) {
    final folderId = json['folder_id'];
    final sortOrder = json['sort_order'];
    if (folderId is! String ||
        folderId.trim().isEmpty ||
        (sortOrder != null && sortOrder is! int)) {
      throw const FormatException('Invalid library entry folder membership.');
    }
    return (folderId: folderId, sortOrder: sortOrder as int? ?? 0);
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
    final rawRef = payload['library_entry_ref'];
    if (rawRef is! Map) {
      throw const FormatException(
        'Tracking entry sync payload is missing library_entry_ref',
      );
    }
    final libraryEntryRef = LibraryEntryRef.fromJson(
      Map<String, Object?>.from(rawRef),
    );
    return TrackingStorageSyncInput(
      ref: TrackingStateRef(
        kind: libraryEntryRef.kind,
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
    final rawRef = payload['library_entry_ref'];
    if (rawRef is! Map) {
      throw const FormatException(
        'Tracking unit sync payload is missing library_entry_ref',
      );
    }
    final libraryEntryRef = LibraryEntryRef.fromJson(
      Map<String, Object?>.from(rawRef),
    );
    final codec =
        libraryTrackingUnitCodecs.cast<TrackingUnitStorageCodec?>().firstWhere(
              (candidate) => candidate?.kind == libraryEntryRef.kind,
              orElse: () => null,
            );
    if (codec == null) {
      throw UnsupportedError(
        'No tracking-unit codec is registered for ${libraryEntryRef.kind.apiValue}',
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
    final rawRef = payload['library_entry_ref'];
    final kind = rawRef is Map
        ? LibraryEntryRef.fromJson(Map<String, Object?>.from(rawRef)).kind
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
      'No kind-entry watch-session codec is registered for ${kind.apiValue}',
    );
  }

  MusicListenEvent _musicListenEventFromEntity(JsonMap entity) {
    final type = entity['entity_type'] as String;
    if (type != 'music_listen_event') {
      throw FormatException('Expected music_listen_event entity, got $type');
    }
    final action = entity['action'] as String;
    final payload = _payload(entity);
    final changedAt = entity['client_changed_at'] as String;
    return MusicListenEvent.fromJson({
      ...payload,
      'id': entity['entity_id'],
      'updated_at': payload['updated_at'] ?? changedAt,
      'deleted_at': action == 'delete' ? changedAt : payload['deleted_at'],
    });
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
    final rawRef = payload['library_entry_ref'];
    final kind = rawRef is Map
        ? LibraryEntryRef.fromJson(Map<String, Object?>.from(rawRef)).kind
        : CatalogMediaKind.unknown;
    for (final codec in libraryCustomEpisodeCodecs) {
      if (codec.kind == kind) return codec;
    }
    throw UnsupportedError(
      'No kind-entry custom-episode codec is registered for ${kind.apiValue}',
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

List<Map<String, Object?>> _syncAttachmentRows(Object? raw, String name) {
  if (raw == null) return const [];
  if (raw is! List) {
    throw FormatException('Sync library_entry $name must be a list.');
  }
  final rows = <Map<String, Object?>>[];
  for (final value in raw) {
    if (value is! Map) {
      throw FormatException('Sync library_entry $name has an invalid row.');
    }
    rows.add(Map<String, Object?>.from(value));
  }
  return rows;
}

typedef _EntrySyncPayload = ({
  CatalogMediaKind kind,
  LibraryEntryRef ref,
  JsonMap payload,
  List<Loan> loans,
  List<({String folderId, int sortOrder})> folderMemberships,
  int? readingQueuePosition,
});

typedef _EntrySyncPayloadWithAttachments = ({
  _EntrySyncPayload entry,
  List<ItemImage> images,
  List<CustomFieldValue> customFields,
  List<UserExternalLink> externalLinks,
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
