import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/sync/collectarr_sync_client.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_conflict_store.dart';
import 'package:collectarr_app/core/sync/sync_cursor_store.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/library/tracking/storage_repository.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_entry_persistence.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/sync/data/sync_apply_service.dart';
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
      entryPersistence: CollectarrLibraryEntryPersistence(_db),
      trackingRecords: TrackingStorageRepository(
        _db,
        codecs: libraryTrackingStorageCodecs,
      ),
      wishlistItems: WishlistItemsCacheRepository(_db),
    ).syncNow(deviceId, since: since);
  }

  Future<List<SyncRejectedChange>> readConflicts() {
    return SyncConflictStore().read();
  }

  Future<void> saveConflicts(List<SyncRejectedChange> conflicts) {
    return SyncConflictStore().write(conflicts);
  }

  /// Queues the rejected version itself: the pull that followed the rejection
  /// already replaced the local row with the service's version.
  Future<bool> keepLocalRejectedChange(SyncRejectedChange change) async {
    if (!change.canKeepLocal) return false;
    final queue = SyncQueueRepository(_db);
    // An edit made since the conflict is newer than this version and wins.
    final pending = await queue.listPending();
    if (pending.any((queued) =>
        queued.entityType == change.entityType &&
        queued.entityId == change.entityId)) {
      return true;
    }
    await queue.enqueue(
      SyncChange(
        id: const Uuid().v4(),
        entityType: change.entityType,
        entityId: change.entityId,
        action: change.localAction!,
        payload: change.localPayload!,
        clientChangedAt: _afterServiceVersion(change),
      ),
    );
    return true;
  }

  /// A clock behind the other device's must not get this choice rejected again.
  DateTime _afterServiceVersion(SyncRejectedChange change) {
    final now = DateTime.now().toUtc();
    final service = change.currentClientChangedAt;
    if (service == null || now.isAfter(service)) return now;
    return service.add(const Duration(seconds: 1));
  }
}

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  return SyncRepository(ref);
});
