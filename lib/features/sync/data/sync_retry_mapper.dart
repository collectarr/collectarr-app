import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/features/catalog/library_catalog_repository.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_entries_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/custom_episodes_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_custom_episode_codecs.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_tracking_entry_codecs.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_watch_session_codecs.dart';
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
        final item = await OwnedItemsCacheRepository(db).findById(
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
        final item = await TrackingEntriesCacheRepository(
          db,
          codecs: collectarrTrackingEntryCodecs,
        ).findById(change.entityId);
        if (item == null) {
          return null;
        }
        return SyncChange(
          id: uuid.v4(),
          entityType: change.entityType,
          entityId: item.id,
          action: item.isDeleted ? 'delete' : 'upsert',
          payload: TrackingEntriesCacheRepository(
            db,
            codecs: collectarrTrackingEntryCodecs,
          ).toSyncPayload(item),
          clientChangedAt: changedAt,
        );
      case 'library_item_snapshot':
        final item =
            await LibraryCatalogRepository(db).findById(change.entityId);
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
