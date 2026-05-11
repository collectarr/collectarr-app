import 'package:collectarr_app/core/device/device_identity.dart';
import 'package:collectarr_app/core/sync/collectarr_sync_client.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/core/sync/sync_service.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/owned_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncState {
  const SyncState({
    this.pendingCount = 0,
    this.isSyncing = false,
    this.isOffline = false,
  });

  final int pendingCount;
  final bool isSyncing;
  final bool isOffline;

  SyncState copyWith({
    int? pendingCount,
    bool? isSyncing,
    bool? isOffline,
  }) {
    return SyncState(
      pendingCount: pendingCount ?? this.pendingCount,
      isSyncing: isSyncing ?? this.isSyncing,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}

final syncControllerProvider =
    StateNotifierProvider<SyncController, SyncState>((ref) {
  return SyncController(ref)..refreshPendingCount();
});

class SyncController extends StateNotifier<SyncState> {
  SyncController(this.ref) : super(const SyncState());

  final Ref ref;

  Future<void> refreshPendingCount() async {
    final count = await _queue().pendingCount();
    state = state.copyWith(pendingCount: count);
  }

  Future<void> syncNow() async {
    state = state.copyWith(isSyncing: true, isOffline: false);
    try {
      final deviceId = await DeviceIdentity().getOrCreate();
      final db = ref.read(localDatabaseProvider);
      await SyncService(
        client: CollectarrSyncClient(),
        queue: SyncQueueRepository(db),
        ownedItems: OwnedItemsCacheRepository(db),
        wishlistItems: WishlistItemsCacheRepository(db),
      ).syncNow(deviceId);
      ref.invalidate(collectionProvider);
      ref.invalidate(wishlistIdsProvider);
      final count = await _queue().pendingCount();
      state = SyncState(pendingCount: count);
    } catch (_) {
      final count = await _queue().pendingCount();
      state = SyncState(pendingCount: count, isOffline: true);
    }
  }

  SyncQueueRepository _queue() {
    return SyncQueueRepository(ref.read(localDatabaseProvider));
  }
}
