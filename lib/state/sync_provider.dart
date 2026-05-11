import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/core/sync/sync_service.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/device_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncState {
  const SyncState({
    this.isSyncing = false,
    this.isOffline = false,
    this.pendingCount = 0,
    this.error,
  });

  final bool isSyncing;
  final bool isOffline;
  final int pendingCount;
  final String? error;

  SyncState copyWith({
    bool? isSyncing,
    bool? isOffline,
    int? pendingCount,
    String? error,
  }) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      isOffline: isOffline ?? this.isOffline,
      pendingCount: pendingCount ?? this.pendingCount,
      error: error,
    );
  }
}

class SyncController extends StateNotifier<SyncState> {
  SyncController(this.ref) : super(const SyncState()) {
    refreshPendingCount();
  }

  final Ref ref;

  Future<void> refreshPendingCount() async {
    final db = ref.read(localDatabaseProvider);
    final pending = await SyncQueueRepository(db).pending();
    state = state.copyWith(pendingCount: pending.length);
  }

  Future<void> syncNow() async {
    state = state.copyWith(isSyncing: true, error: null);
    try {
      final db = ref.read(localDatabaseProvider);
      final queue = SyncQueueRepository(db);
      final pending = await queue.pending();
      final deviceId = await ref.read(deviceIdProvider.future);
      final service = SyncService(ref.read(apiClientProvider), deviceId: deviceId);
      if (pending.isNotEmpty) {
        await service.pushPending(pending);
        await queue.clear();
      }
      await service.pull();
      state = const SyncState(isOffline: false, pendingCount: 0);
    } catch (error) {
      state = state.copyWith(isSyncing: false, isOffline: true, error: error.toString());
    }
  }
}

final syncControllerProvider = StateNotifierProvider<SyncController, SyncState>((ref) {
  return SyncController(ref);
});

