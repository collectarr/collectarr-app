import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/sync/collectarr_sync_client.dart';
import 'package:collectarr_app/core/sync/sync_account.dart';
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
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/state/connection_settings_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:dio/dio.dart';
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

  Future<SyncResult> performSync(String deviceId) async {
    final settings = ref.mounted
        ? ref.read(connectionSettingsProvider)
        : ConnectionSettings();
    final auth = ref.mounted ? ref.read(authControllerProvider) : null;

    try {
      final client = await _openAccountClient(settings, auth);
      final since = await getLastSyncedAt();
      return await SyncApplyService(
        client: client,
        db: _db,
        queue: SyncQueueRepository(_db),
        entryPersistence: CollectarrLibraryEntryPersistence(_db),
        trackingRecords: TrackingStorageRepository(
          _db,
          codecs: libraryTrackingStorageCodecs,
        ),
        wishlistItems: WishlistItemsCacheRepository(_db),
      ).syncNow(deviceId, since: since);
    } on DioException catch (error) {
      if (error.response?.statusCode == 401 && auth?.accountId != null) {
        throw const SyncAccountException(
          'The sync server did not accept your account. Sign in again.',
        );
      }
      rethrow;
    }
  }

  Future<CollectarrSyncClient> _openAccountClient(
    ConnectionSettings settings,
    AuthState? auth,
  ) async {
    final sharedKeyClient = CollectarrSyncClient(
      baseUrl: settings.syncBaseUrl,
      syncKey: settings.syncKey,
    );
    final health = await sharedKeyClient.health();
    final access = resolveSyncAccountAccess(
      serverHasAccounts: health['account_auth'] == true,
      accountId: auth?.accountId,
      linkedAccountId: await SyncAccountStore().read(),
    );
    if (access == SyncAccountAccess.sharedKey) return sharedKeyClient;

    final accountClient = CollectarrSyncClient(
      baseUrl: settings.syncBaseUrl,
      syncKey: settings.syncKey,
      accountToken: auth!.accountToken,
    );
    if (access == SyncAccountAccess.linkAccount) {
      await accountClient.claimSharedLibrary();
      // The account's partition has its own history: read all of it once.
      await SyncCursorStore().clear();
      await SyncAccountStore().write(auth.accountId!);
    }
    return accountClient;
  }

  /// A linked library waits for its account instead of reporting a failure on
  /// every automatic sync.
  Future<bool> isWaitingForSignIn() async {
    final linked = await SyncAccountStore().read();
    return linked != null && ref.read(authControllerProvider).accountId == null;
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
