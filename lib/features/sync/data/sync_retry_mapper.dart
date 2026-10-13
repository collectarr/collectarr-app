import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/tracking_state_ref.dart';
import 'package:collectarr_app/core/models/tracking_unit_ref.dart';
import 'package:collectarr_app/core/models/watch_session_ref.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_repository.dart';
import 'package:collectarr_app/features/library/tracking/tracking_unit_storage_repository.dart';
import 'package:collectarr_app/features/library/tracking/library_tracking_registry.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/features/library/tracking/custom_episode_codec.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_entry_persistence.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/collection/repositories/user_folder_repository.dart';
import 'package:collectarr_app/features/collection/repositories/user_metadata_overrides_cache_repository.dart';
import 'package:collectarr_app/features/library/tracking/watch_sessions_repository.dart';
import 'package:uuid/uuid.dart';

class SyncRetryMapper {
  const SyncRetryMapper._();

  static Future<SyncChange?> localRetryChange(
    SyncRejectedChange change, {
    required LocalDatabase db,
    required DateTime changedAt,
    required Uuid uuid,
  }) async {
    for (final codec in libraryKindSyncEntityCodecs) {
      if (codec.entityType == change.entityType) {
        return codec.retryRejected(
          change,
          db: db,
          changedAt: changedAt,
          uuid: uuid,
        );
      }
    }

    switch (change.entityType) {
      case 'library_entry':
        final payload = change.localPayload ?? change.servicePayload;
        final kind = catalogMediaKindFromApiValue(payload?['kind'] as String?);
        if (kind.isUnknown) return null;
        final libraryEntryRef =
            LibraryEntryRef(kind: kind, id: LibraryEntryId(change.entityId));
        final serialized = await CollectarrLibraryEntryPersistence(db)
            .syncPayloadByRef(libraryEntryRef);
        if (serialized == null) {
          return null;
        }
        return SyncChange(
          id: uuid.v4(),
          entityType: change.entityType,
          entityId: change.entityId,
          action: serialized.isDeleted ? 'delete' : 'upsert',
          payload: serialized.payload,
          clientChangedAt: changedAt,
        );
      case 'wishlist_item':
        final item = await WishlistItemsCacheRepository(db).findById(
          change.entityId,
        );
        if (item == null) {
          return null;
        }
        return SyncChange(
          id: uuid.v4(),
          entityType: change.entityType,
          entityId: item.id,
          action: item.isDeleted ? 'delete' : 'upsert',
          payload: item.toSyncPayload(),
          clientChangedAt: changedAt,
        );
      case 'tracking_entry':
        final trackingPayload = change.localPayload ?? change.servicePayload;
        final rawEntryRef = trackingPayload?['library_entry_ref'];
        if (rawEntryRef is! Map) return null;
        final trackingEntryRef = LibraryEntryRef.fromJson(
          Map<String, Object?>.from(rawEntryRef),
        );
        final tracking = await TrackingStorageRepository(
          db,
          codecs: libraryTrackingStorageCodecs,
        ).syncPayloadByRef(
          TrackingStateRef(
            kind: trackingEntryRef.kind,
            id: change.entityId,
          ),
        );
        if (tracking == null) {
          return null;
        }
        return SyncChange(
          id: uuid.v4(),
          entityType: change.entityType,
          entityId: tracking.ref.id,
          action: tracking.isDeleted ? 'delete' : 'upsert',
          payload: tracking.payload,
          clientChangedAt: changedAt,
        );
      case 'tracking_unit':
        final unitPayload = change.localPayload ?? change.servicePayload;
        final rawEntryRef = unitPayload?['library_entry_ref'];
        if (rawEntryRef is! Map) return null;
        final entryRef = LibraryEntryRef.fromJson(
          Map<String, Object?>.from(rawEntryRef),
        );
        final unit = await TrackingUnitStorageRepository(
          db,
          codecs: libraryTrackingUnitCodecs,
        ).findByRef(
          TrackingUnitRef(
            kind: entryRef.kind,
            id: change.entityId,
          ),
        );
        if (unit == null) return null;
        return SyncChange(
          id: uuid.v4(),
          entityType: change.entityType,
          entityId: unit.id,
          action: unit.isDeleted ? 'delete' : 'upsert',
          payload: unit.toSyncPayload(),
          clientChangedAt: changedAt,
        );
      case 'watch_session':
        final watchSessionPayload =
            change.localPayload ?? change.servicePayload;
        final rawEntryRef = watchSessionPayload?['library_entry_ref'];
        if (rawEntryRef is! Map) return null;
        final entryRef = LibraryEntryRef.fromJson(
          Map<String, Object?>.from(rawEntryRef),
        );
        final session = await WatchSessionsRepository(
          db,
          codecs: libraryWatchSessionCodecs,
        ).findByRef(
          WatchSessionRef(
            kind: entryRef.kind,
            id: change.entityId,
          ),
        );
        if (session == null) {
          return null;
        }
        return SyncChange(
          id: uuid.v4(),
          entityType: change.entityType,
          entityId: session.id,
          action: session.isDeleted ? 'delete' : 'upsert',
          payload: WatchSessionsRepository(
            db,
            codecs: libraryWatchSessionCodecs,
          ).toSyncPayload(session),
          clientChangedAt: changedAt,
        );
      case 'metadata_override':
        final override =
            await UserMetadataOverridesCacheRepository(db).findById(
          change.entityId,
        );
        if (override == null) {
          return null;
        }
        return SyncChange(
          id: uuid.v4(),
          entityType: change.entityType,
          entityId: override.id,
          action: override.isDeleted ? 'delete' : 'upsert',
          payload: override.toSyncPayload(),
          clientChangedAt: changedAt,
        );
      case 'custom_episode':
        final customEpisodePayload =
            change.localPayload ?? change.servicePayload;
        final rawSeriesRef = customEpisodePayload?['library_entry_ref'];
        if (rawSeriesRef is! Map) return null;
        final seriesRef = LibraryEntryRef.fromJson(
          Map<String, Object?>.from(rawSeriesRef),
        );
        final codec = _customEpisodeCodecFor(seriesRef.kind);
        final record = await codec.readSyncRecord(db, change.entityId);
        if (record == null) {
          return null;
        }
        return SyncChange(
          id: uuid.v4(),
          entityType: change.entityType,
          entityId: change.entityId,
          action: record.isDeleted ? 'delete' : 'upsert',
          payload: record.payload,
          clientChangedAt: changedAt,
        );
      case 'location':
        final repo = LocationRepository(db);
        final location = await repo.getById(change.entityId);
        if (location != null) {
          return SyncChange(
            id: uuid.v4(),
            entityType: change.entityType,
            entityId: location.id,
            action: 'upsert',
            payload: location.toSyncPayload(),
            clientChangedAt: changedAt,
          );
        }
        if (change.localAction == 'delete') {
          return SyncChange(
            id: uuid.v4(),
            entityType: change.entityType,
            entityId: change.entityId,
            action: 'delete',
            payload: change.localPayload ?? const {},
            clientChangedAt: changedAt,
          );
        }
        return null;
      case 'user_folder':
        final folder = await UserFolderRepository(db).findById(change.entityId);
        if (folder != null) {
          return SyncChange(
            id: uuid.v4(),
            entityType: change.entityType,
            entityId: folder.id,
            action: 'upsert',
            payload: folder.toSyncPayload(),
            clientChangedAt: changedAt,
          );
        }
        if (change.localAction == 'delete') {
          return SyncChange(
            id: uuid.v4(),
            entityType: change.entityType,
            entityId: change.entityId,
            action: 'delete',
            payload: const {},
            clientChangedAt: changedAt,
          );
        }
        return null;
      case 'pick_list_value':
        final row = await (db.select(db.pickListValuesCache)
              ..where((t) => t.id.equals(change.entityId)))
            .getSingleOrNull();
        if (row != null) {
          return SyncChange(
            id: uuid.v4(),
            entityType: change.entityType,
            entityId: row.id,
            action: 'upsert',
            payload: {
              'list_name': row.listName,
              'media_kind': row.mediaKind,
              'value': row.value,
              'sort_order': row.sortOrder,
            },
            clientChangedAt: changedAt,
          );
        }
        if (change.localAction == 'delete') {
          return SyncChange(
            id: uuid.v4(),
            entityType: change.entityType,
            entityId: change.entityId,
            action: 'delete',
            payload: change.localPayload ?? const {},
            clientChangedAt: changedAt,
          );
        }
        return null;
      default:
        return null;
    }
  }

  static CustomEpisodeSyncCodec _customEpisodeCodecFor(
    CatalogMediaKind kind,
  ) {
    for (final codec in libraryCustomEpisodeCodecs) {
      if (codec.kind == kind) return codec;
    }
    throw UnsupportedError(
      'No kind-entry custom-episode codec is registered for ${kind.apiValue}',
    );
  }
}
