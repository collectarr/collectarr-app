import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_entry_ref.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_snapshot_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_entry_repository.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/custom_episodes_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.g.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/collection/repositories/user_metadata_overrides_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/watch_sessions_repository.dart';
import 'package:uuid/uuid.dart';

class SyncRetryMapper {
  const SyncRetryMapper._();

  static Future<SyncChange?> localRetryChange(
    SyncRejectedChange change, {
    required LocalDatabase db,
    required DateTime changedAt,
    required Uuid uuid,
  }) async {
    switch (change.entityType) {
      case 'owned_item':
        final rawCatalogRef = change.localPayload?['catalog_ref'];
        if (rawCatalogRef is! Map) return null;
        final catalogRef = CatalogEntityRef.fromJson(
          Map<String, dynamic>.from(rawCatalogRef),
        );
        final typedItem = await collectarrFindTypedOwnedItemByRef(
          db,
          OwnedItemRef(
            kind: catalogRef.mediaKind,
            id: OwnedItemId(change.entityId),
          ),
        );
        if (typedItem == null) {
          return null;
        }
        final serialized = collectarrTypedOwnedItemSyncPayload(
          typedItem.$1,
          typedItem.$2,
        );
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
        final rawCatalogRef = trackingPayload?['catalog_ref'];
        if (rawCatalogRef is! Map) return null;
        final trackingCatalogRef = CatalogEntityRef.fromJson(
          Map<String, dynamic>.from(rawCatalogRef),
        );
        final item = await TrackingEntryRepository(
          db,
          codecs: collectarrTrackingEntryCodecs,
        ).findByRef(
          TrackingEntryRef(
            kind: trackingCatalogRef.mediaKind,
            id: change.entityId,
          ),
        );
        if (item == null) {
          return null;
        }
        return SyncChange(
          id: uuid.v4(),
          entityType: change.entityType,
          entityId: item.id,
          action: item.isDeleted ? 'delete' : 'upsert',
          payload: TrackingEntryRepository(
            db,
            codecs: collectarrTrackingEntryCodecs,
          ).toSyncPayload(item),
          clientChangedAt: changedAt,
        );
      case 'library_item_snapshot':
        final payload = change.localPayload ?? change.servicePayload;
        final rawKind = payload?['kind'];
        if (rawKind is! String || rawKind.trim().isEmpty) {
          return null;
        }
        final catalogRef = CatalogEntityRef(
          kind: catalogMediaKindFromApiValue(rawKind),
          entityType: const CatalogEntityTypeId('work'),
          id: change.entityId,
        );
        final item = await CatalogSnapshotRepository(db).findByRef(catalogRef);
        if (item == null) {
          return null;
        }
        return SyncChange(
          id: uuid.v4(),
          entityType: change.entityType,
          entityId: item.id,
          action: 'upsert',
          payload: item.toSyncPayload(),
          clientChangedAt: changedAt,
        );
      case 'watch_session':
        final session = await WatchSessionsRepository(
          db,
          codecs: collectarrWatchSessionCodecs,
        ).findById(change.entityId);
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
            codecs: collectarrWatchSessionCodecs,
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
        final episode = await CustomEpisodesRepository(
          db,
          codecs: collectarrCustomEpisodeCodecs,
        ).findById(change.entityId);
        if (episode == null) {
          return null;
        }
        return SyncChange(
          id: uuid.v4(),
          entityType: change.entityType,
          entityId: episode.id,
          action: episode.isDeleted ? 'delete' : 'upsert',
          payload: CustomEpisodesRepository(
            db,
            codecs: collectarrCustomEpisodeCodecs,
          ).toSyncPayload(episode),
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
}
