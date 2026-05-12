import 'dart:developer' as developer;

import 'package:collectarr_app/core/device/device_identity.dart';
import 'package:collectarr_app/core/sync/collectarr_sync_client.dart';
import 'package:collectarr_app/core/sync/sync_cursor_store.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/core/sync/sync_service.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/owned_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/state/connection_settings_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncState {
  const SyncState({
    this.pendingCount = 0,
    this.isSyncing = false,
    this.isOffline = false,
    this.lastSyncedAt,
    this.errorMessage,
  });

  final int pendingCount;
  final bool isSyncing;
  final bool isOffline;
  final DateTime? lastSyncedAt;
  final String? errorMessage;

  SyncState copyWith({
    int? pendingCount,
    bool? isSyncing,
    bool? isOffline,
    DateTime? lastSyncedAt,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SyncState(
      pendingCount: pendingCount ?? this.pendingCount,
      isSyncing: isSyncing ?? this.isSyncing,
      isOffline: isOffline ?? this.isOffline,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
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
    final lastSyncedAt = await _readLastSyncedAt();
    state = state.copyWith(pendingCount: count, lastSyncedAt: lastSyncedAt);
  }

  Future<void> syncNow() async {
    state = state.copyWith(isSyncing: true, isOffline: false, clearError: true);
    try {
      final deviceId = await DeviceIdentity().getOrCreate();
      final cursor = SyncCursorStore();
      final since = await cursor.read();
      final db = ref.read(localDatabaseProvider);
      final settings = ref.read(connectionSettingsProvider);
      final serverTime = await SyncService(
        client: CollectarrSyncClient(
          baseUrl: settings.syncBaseUrl,
          syncKey: settings.syncKey,
        ),
        db: db,
        queue: SyncQueueRepository(db),
        ownedItems: OwnedItemsCacheRepository(db),
        wishlistItems: WishlistItemsCacheRepository(db),
      ).syncNow(deviceId, since: since);
      await cursor.write(serverTime);
      ref.invalidate(collectionProvider);
      ref.invalidate(wishlistIdsProvider);
      ref.invalidate(wishlistProvider);
      final count = await _queue().pendingCount();
      state = SyncState(pendingCount: count, lastSyncedAt: serverTime);
    } catch (error, stackTrace) {
      developer.log(
        'Collectarr personal sync failed',
        name: 'collectarr.sync',
        error: error,
        stackTrace: stackTrace,
      );
      final count = await _queue().pendingCount();
      state = SyncState(
        pendingCount: count,
        isOffline: true,
        lastSyncedAt: state.lastSyncedAt,
        errorMessage: error.toString(),
      );
    }
  }

  SyncQueueRepository _queue() {
    return SyncQueueRepository(ref.read(localDatabaseProvider));
  }

  Future<DateTime?> _readLastSyncedAt() async {
    try {
      return await SyncCursorStore().read();
    } catch (error, stackTrace) {
      developer.log(
        'Collectarr sync cursor read failed',
        name: 'collectarr.sync',
        error: error,
        stackTrace: stackTrace,
      );
      return state.lastSyncedAt;
    }
  }
}
