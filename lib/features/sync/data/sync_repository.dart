import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/sync/collectarr_sync_client.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_cursor_store.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/library_catalog_repository.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_entries_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_tracking_entry_codecs.dart';
import 'package:collectarr_app/features/sync/data/sync_apply_service.dart';
import 'package:collectarr_app/features/sync/data/sync_retry_mapper.dart';
import 'package:collectarr_app/core/settings/connection_settings.dart';
import 'package:collectarr_app/state/connection_settings_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class SyncRepository {
  SyncRepository(this.ref);
  final Ref ref;

  late final LocalDatabase _db = ref.read(localDatabaseProvider);

  Future<int> getPendingCount() async {
    return SyncQueueRepository(_db).pendingCount();
  }

  Future<DateTime?> getLastSyncedAt() async {
    return SyncCursorStore().read();
  }

  Future<void> saveLastSyncedAt(DateTime timestamp) async {
    await SyncCursorStore().write(timestamp);
  }

  Future<SyncResult> performSync(String deviceId, DateTime? since) async {
    final settings = ref.mounted
        ? ref.read(connectionSettingsProvider)
        : ConnectionSettings();

    return SyncApplyService(
      client: CollectarrSyncClient(
        baseUrl: settings.syncBaseUrl,
        syncKey: settings.syncKey,
      ),
      db: _db,
      queue: SyncQueueRepository(_db),
      catalog: LibraryCatalogRepository(_db),
      ownedItems: OwnedItemsRepository(_db),
      trackingEntries: TrackingEntriesCacheRepository(
        _db,
        codecs: collectarrTrackingEntryCodecs,
      ),
      wishlistItems: WishlistItemsCacheRepository(_db),
    ).syncNow(deviceId, since: since);
  }

  Future<bool> keepLocalRejectedChange(SyncRejectedChange change) async {
    final queue = SyncQueueRepository(_db);
    return queue.enqueueLocalRetry(
      change,
      db: _db,
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
    final syncChange = await SyncRetryMapper.localRetryChange(
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
}
