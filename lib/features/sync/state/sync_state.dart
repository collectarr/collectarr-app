import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_service.dart';

class SyncLogEntry {
  const SyncLogEntry({
    required this.timestamp,
    required this.success,
    this.pushed = 0,
    this.pulled = 0,
    this.rejected = 0,
    this.errorMessage,
  });

  final DateTime timestamp;
  final bool success;
  final int pushed;
  final int pulled;
  final int rejected;
  final String? errorMessage;
}

sealed class SyncState {
  const SyncState._({
    this.pendingCount = 0,
    this.isOffline = false,
    this.lastSyncedAt,
    this.errorMessage,
    this.warningMessage,
    this.rejectedChanges = const [],
    this.syncLog = const [],
  });

  const factory SyncState({
    int pendingCount,
    bool isOffline,
    DateTime? lastSyncedAt,
    String? warningMessage,
    List<SyncRejectedChange> rejectedChanges,
    List<SyncLogEntry> syncLog,
  }) = SyncIdle;

  final int pendingCount;
  final bool isOffline;
  final DateTime? lastSyncedAt;
  final String? errorMessage;
  final String? warningMessage;
  final List<SyncRejectedChange> rejectedChanges;
  final List<SyncLogEntry> syncLog;

  bool get isSyncing => this is SyncInProgress;

  SyncState copyWith({
    int? pendingCount,
    bool? isSyncing,
    bool? isOffline,
    DateTime? lastSyncedAt,
    String? errorMessage,
    String? warningMessage,
    List<SyncRejectedChange>? rejectedChanges,
    List<SyncLogEntry>? syncLog,
    bool clearError = false,
    bool clearWarning = false,
    bool clearRejectedChanges = false,
  }) {
    final nextPendingCount = pendingCount ?? this.pendingCount;
    final nextIsOffline = isOffline ?? this.isOffline;
    final nextLastSyncedAt = lastSyncedAt ?? this.lastSyncedAt;
    final nextErrorMessage = clearError ? null : errorMessage ?? this.errorMessage;
    final nextWarningMessage = clearWarning ? null : warningMessage ?? this.warningMessage;
    final nextRejectedChanges = clearRejectedChanges ? const <SyncRejectedChange>[] : rejectedChanges ?? this.rejectedChanges;
    final nextSyncLog = syncLog ?? this.syncLog;

    final nextIsSyncing = isSyncing ?? (this is SyncInProgress);

    if (nextIsSyncing) {
      return SyncInProgress(
        pendingCount: nextPendingCount,
        isOffline: nextIsOffline,
        lastSyncedAt: nextLastSyncedAt,
        warningMessage: nextWarningMessage,
        rejectedChanges: nextRejectedChanges,
        syncLog: nextSyncLog,
      );
    } else if (nextErrorMessage != null) {
      return SyncFailure(
        errorMessage: nextErrorMessage,
        pendingCount: nextPendingCount,
        isOffline: nextIsOffline,
        lastSyncedAt: nextLastSyncedAt,
        warningMessage: nextWarningMessage,
        rejectedChanges: nextRejectedChanges,
        syncLog: nextSyncLog,
      );
    } else {
      return SyncIdle(
        pendingCount: nextPendingCount,
        isOffline: nextIsOffline,
        lastSyncedAt: nextLastSyncedAt,
        warningMessage: nextWarningMessage,
        rejectedChanges: nextRejectedChanges,
        syncLog: nextSyncLog,
      );
    }
  }
}

class SyncIdle extends SyncState {
  const SyncIdle({
    super.pendingCount = 0,
    super.isOffline = false,
    super.lastSyncedAt,
    super.warningMessage,
    super.rejectedChanges = const [],
    super.syncLog = const [],
  }) : super._(
         errorMessage: null,
       );
}

class SyncInProgress extends SyncState {
  const SyncInProgress({
    super.pendingCount = 0,
    super.isOffline = false,
    super.lastSyncedAt,
    super.warningMessage,
    super.rejectedChanges = const [],
    super.syncLog = const [],
  }) : super._(
         errorMessage: null,
       );
}

class SyncFailure extends SyncState {
  const SyncFailure({
    required String errorMessage,
    super.pendingCount = 0,
    super.isOffline = false,
    super.lastSyncedAt,
    super.warningMessage,
    super.rejectedChanges = const [],
    super.syncLog = const [],
  }) : super._(
         errorMessage: errorMessage,
       );
}
