import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/settings/connection_settings.dart';
import 'package:collectarr_app/core/sync/collectarr_sync_client.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_cursor_store.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:drift/drift.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_entries_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/custom_episodes_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/collection/repositories/user_metadata_overrides_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/watch_sessions_cache_repository.dart';
import 'package:collectarr_app/features/sync/data/sync_apply_service.dart';
import 'package:collectarr_app/state/connection_settings_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class SyncRepository {
  SyncRepository(this.ref);
  final Ref ref;

  Future<int> getPendingCount() async {
    final db = ref.read(localDatabaseProvider);
    return SyncQueueRepository(db).pendingCount();
  }

  Future<DateTime?> getLastSyncedAt() async {
    return SyncCursorStore().read();
  }

  Future<void> saveLastSyncedAt(DateTime timestamp) async {
    await SyncCursorStore().write(timestamp);
  }

  Future<SyncResult> performSync(String deviceId, DateTime? since) async {
    final db = ref.read(localDatabaseProvider);
    final settings = ref.read(connectionSettingsProvider);

    return SyncApplyService(
      client: CollectarrSyncClient(
        baseUrl: settings.syncBaseUrl,
        syncKey: settings.syncKey,
      ),
      db: db,
      queue: SyncQueueRepository(db),
      catalog: CatalogCacheRepository(db),
      ownedItems: OwnedItemsCacheRepository(db),
      trackingEntries: TrackingEntriesCacheRepository(db),
      wishlistItems: WishlistItemsCacheRepository(db),
    ).syncNow(deviceId, since: since);
  }

  Future<bool> keepLocalRejectedChange(SyncRejectedChange change) async {
    final db = ref.read(localDatabaseProvider);
    final queue = SyncQueueRepository(db);
    return queue.enqueueLocalRetry(
      change,
      db: db,
      changedAt: DateTime.now().toUtc(),
      uuid: const Uuid(),
    );
  }
}

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  return SyncRepository(ref);
});

extension on SyncQueueRepository {
  Future<bool> enqueueLocalRetry(
    SyncRejectedChange change, {
    required LocalDatabase db,
    required DateTime changedAt,
    required Uuid uuid,
  }) async {
    final syncChange = await _localRetryChange(
      change,
      db: db,
      changedAt: changedAt,
      uuid: uuid,
    );
    if (syncChange == null) {
      return false;
    }
    await enqueue(syncChange);
    return true;
  }

  Future<SyncChange?> _localRetryChange(
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
        final item = await TrackingEntriesCacheRepository(db).findById(
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
      case 'library_item_snapshot':
        final item = await CatalogCacheRepository(db).findById(change.entityId);
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
        final session = await WatchSessionsCacheRepository(db).findById(
          change.entityId,
        );
        if (session == null) {
          return null;
        }
        return SyncChange(
          id: uuid.v4(),
          entityType: change.entityType,
          entityId: session.id,
          action: session.isDeleted ? 'delete' : 'upsert',
          payload: session.toSyncPayload(),
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
        final episode = await CustomEpisodesCacheRepository(db).findById(
          change.entityId,
        );
        if (episode == null) {
          return null;
        }
        return SyncChange(
          id: uuid.v4(),
          entityType: change.entityType,
          entityId: episode.id,
          action: episode.isDeleted ? 'delete' : 'upsert',
          payload: episode.toSyncPayload(),
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
