import 'dart:async';
import 'dart:developer' as developer;

import 'package:collectarr_app/core/device/device_identity.dart';
import 'package:collectarr_app/core/logging/app_log.dart';
import 'package:collectarr_app/core/settings/connection_settings.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_retry.dart';
import 'package:collectarr_app/core/sync/sync_service.dart';
import 'package:collectarr_app/core/sync/sync_warning_formatter.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/sync/data/sync_repository.dart';
import 'package:collectarr_app/features/sync/state/sync_state.dart';
import 'package:collectarr_app/state/connection_settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final syncControllerProvider =
    StateNotifierProvider<SyncController, SyncState>((ref) {
  return SyncController(ref)..refreshPendingCount();
});

class SyncController extends StateNotifier<SyncState> {
  SyncController(this.ref) : super(const SyncIdle());

  final Ref ref;
  bool _onlineFirstSyncQueued = false;

  SyncRepository get _repo => ref.read(syncRepositoryProvider);

  Future<void> refreshPendingCount() async {
    final count = await _repo.getPendingCount();
    final lastSynced = await _readLastSyncedAt();
    state = state.copyWith(pendingCount: count, lastSyncedAt: lastSynced);
  }

  static const _maxLogEntries = 20;

  Future<void> syncNow() async {
    if (state.isSyncing) {
      return;
    }
    final preSyncPending = state.pendingCount;
    state = state.copyWith(
      isSyncing: true,
      isOffline: false,
      clearError: true,
      clearWarning: true,
      clearRejectedChanges: true,
    );
    try {
      final deviceId = await DeviceIdentity().getOrCreate();
      final since = await _repo.getLastSyncedAt();
      final result = await _repo.performSync(deviceId, since);
      await _repo.saveLastSyncedAt(result.serverTime);
      ref.invalidate(collectionProvider);
      ref.invalidate(trackingEntriesProvider);
      ref.invalidate(trackingEntriesByCatalogItemProvider);
      ref.invalidate(wishlistIdsProvider);
      ref.invalidate(wishlistProvider);
      ref.invalidate(shelfProvider);
      final count = await _repo.getPendingCount();
      final log = _appendLog(SyncLogEntry(
        timestamp: result.serverTime,
        success: true,
        pushed: preSyncPending,
        rejected: result.rejectedCount,
      ));
      state = SyncIdle(
        pendingCount: count,
        lastSyncedAt: result.serverTime,
        warningMessage: SyncWarningFormatter.rejectedChanges(result.rejectedChanges),
        rejectedChanges: result.rejectedChanges,
        syncLog: log,
      );
    } catch (error, stackTrace) {
      developer.log(
        'Collectarr personal sync failed',
        name: 'collectarr.sync',
        error: error,
        stackTrace: stackTrace,
      );
      ref.read(appLogProvider.notifier).error(
            'sync',
            'Sync failed: $error',
            detail: stackTrace.toString(),
          );
      final count = await _repo.getPendingCount();
      final log = _appendLog(SyncLogEntry(
        timestamp: DateTime.now().toUtc(),
        success: false,
        pushed: preSyncPending,
        errorMessage: error.toString(),
      ));
      state = SyncFailure(
        errorMessage: error.toString(),
        pendingCount: count,
        isOffline: isOfflineSyncError(error),
        lastSyncedAt: state.lastSyncedAt,
        rejectedChanges: state.rejectedChanges,
        syncLog: log,
      );
    }
  }

  Future<void> syncOnlineFirstIfEnabled() async {
    if (!_shouldUseOnlineFirstSync(ref.read(connectionSettingsProvider))) {
      return;
    }
    _onlineFirstSyncQueued = true;
    if (state.isSyncing) {
      return;
    }
    while (_onlineFirstSyncQueued) {
      _onlineFirstSyncQueued = false;
      await syncNow();
      if (!_shouldUseOnlineFirstSync(ref.read(connectionSettingsProvider))) {
        _onlineFirstSyncQueued = false;
      }
    }
  }

  void dismissError() {
    state = state.copyWith(clearError: true);
  }

  void dismissRejectedChange(String key) {
    final rejectedChanges = state.rejectedChanges
        .where((change) => change.key != key)
        .toList(growable: false);
    state = state.copyWith(
      rejectedChanges: rejectedChanges,
      warningMessage: SyncWarningFormatter.rejectedChanges(rejectedChanges),
      clearWarning: rejectedChanges.isEmpty,
    );
  }

  void dismissAllRejectedChanges() {
    state = state.copyWith(
      rejectedChanges: const [],
      clearRejectedChanges: true,
      clearWarning: true,
    );
  }

  Future<bool> keepLocalRejectedChange(SyncRejectedChange change) async {
    final queued = await _repo.keepLocalRejectedChange(change);
    if (!queued) {
      return false;
    }
    dismissRejectedChange(change.key);
    await refreshPendingCount();
    return true;
  }

  List<SyncLogEntry> _appendLog(SyncLogEntry entry) {
    final log = [...state.syncLog, entry];
    if (log.length > _maxLogEntries) {
      return log.sublist(log.length - _maxLogEntries);
    }
    return log;
  }

  Future<DateTime?> _readLastSyncedAt() async {
    try {
      return await _repo.getLastSyncedAt();
    } catch (error, stackTrace) {
      developer.log(
        'Collectarr sync cursor read failed',
        name: 'collectarr.sync',
        error: error,
        stackTrace: stackTrace,
      );
      ref.read(appLogProvider.notifier).error(
            'sync',
            'Sync cursor read failed: $error',
            detail: stackTrace.toString(),
          );
      return state.lastSyncedAt;
    }
  }

  bool _shouldUseOnlineFirstSync(ConnectionSettings settings) {
    if (!settings.preferOnlineFirstSync) {
      return false;
    }
    return settings.syncBaseUrl.trim().isNotEmpty &&
        settings.syncKey.trim().isNotEmpty;
  }
}
