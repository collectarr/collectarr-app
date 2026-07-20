import 'package:collectarr_app/core/sync/sync_change.dart';

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

/// A value object that carries the shared context across all sync states.
///
/// Use this to pass consistent state when constructing a new [SyncState]
/// subclass rather than calling the old [copyWith] with flags.
class SyncSnapshot {
  const SyncSnapshot({
    this.pendingCount = 0,
    this.isOffline = false,
    this.lastSyncedAt,
    this.warningMessage,
    this.rejectedChanges = const [],
    this.syncLog = const [],
  });

  final int pendingCount;
  final bool isOffline;
  final DateTime? lastSyncedAt;
  final String? warningMessage;
  final List<SyncRejectedChange> rejectedChanges;
  final List<SyncLogEntry> syncLog;

  SyncSnapshot copyWith({
    int? pendingCount,
    bool? isOffline,
    DateTime? lastSyncedAt,
    String? warningMessage,
    List<SyncRejectedChange>? rejectedChanges,
    List<SyncLogEntry>? syncLog,
    bool clearWarning = false,
    bool clearRejectedChanges = false,
  }) {
    return SyncSnapshot(
      pendingCount: pendingCount ?? this.pendingCount,
      isOffline: isOffline ?? this.isOffline,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      warningMessage: clearWarning ? null : warningMessage ?? this.warningMessage,
      rejectedChanges: clearRejectedChanges
          ? const []
          : rejectedChanges ?? this.rejectedChanges,
      syncLog: syncLog ?? this.syncLog,
    );
  }
}

/// Sealed sync state hierarchy.
///
/// Transitions:
///  - Controller emits [SyncInProgress] when a sync starts.
///  - Controller emits [SyncIdle] on success.
///  - Controller emits [SyncFailure] on error.
///
/// There is no [copyWith] that accepts a boolean `isSyncing` flag.
/// Instead the controller explicitly constructs the target state.
sealed class SyncState {
  const SyncState._({required this.snapshot});

  /// Shorthand factory that creates an initial [SyncIdle] with default values.
  const factory SyncState({
    int pendingCount,
    bool isOffline,
    DateTime? lastSyncedAt,
    String? warningMessage,
    List<SyncRejectedChange> rejectedChanges,
    List<SyncLogEntry> syncLog,
  }) = SyncIdle;

  final SyncSnapshot snapshot;

  // Convenience accessors forwarded from snapshot.
  int get pendingCount => snapshot.pendingCount;
  bool get isOffline => snapshot.isOffline;
  DateTime? get lastSyncedAt => snapshot.lastSyncedAt;
  String? get warningMessage => snapshot.warningMessage;
  List<SyncRejectedChange> get rejectedChanges => snapshot.rejectedChanges;
  List<SyncLogEntry> get syncLog => snapshot.syncLog;

  /// Null except in [SyncFailure].
  String? get errorMessage => null;

  bool get isSyncing => this is SyncInProgress;
}

class SyncIdle extends SyncState {
  const SyncIdle({
    int pendingCount = 0,
    bool isOffline = false,
    DateTime? lastSyncedAt,
    String? warningMessage,
    List<SyncRejectedChange> rejectedChanges = const [],
    List<SyncLogEntry> syncLog = const [],
  }) : super._(
          snapshot: SyncSnapshot(
            pendingCount: pendingCount,
            isOffline: isOffline,
            lastSyncedAt: lastSyncedAt,
            warningMessage: warningMessage,
            rejectedChanges: rejectedChanges,
            syncLog: syncLog,
          ),
        );

  const SyncIdle.fromSnapshot(SyncSnapshot s)
      : super._(snapshot: s);
}

class SyncInProgress extends SyncState {
  const SyncInProgress({
    int pendingCount = 0,
    bool isOffline = false,
    DateTime? lastSyncedAt,
    String? warningMessage,
    List<SyncRejectedChange> rejectedChanges = const [],
    List<SyncLogEntry> syncLog = const [],
  }) : super._(
          snapshot: SyncSnapshot(
            pendingCount: pendingCount,
            isOffline: isOffline,
            lastSyncedAt: lastSyncedAt,
            warningMessage: warningMessage,
            rejectedChanges: rejectedChanges,
            syncLog: syncLog,
          ),
        );

  const SyncInProgress.fromSnapshot(SyncSnapshot s)
      : super._(snapshot: s);
}

class SyncFailure extends SyncState {
  const SyncFailure({
    required this.errorMessage,
    int pendingCount = 0,
    bool isOffline = false,
    DateTime? lastSyncedAt,
    String? warningMessage,
    List<SyncRejectedChange> rejectedChanges = const [],
    List<SyncLogEntry> syncLog = const [],
  }) : super._(
          snapshot: SyncSnapshot(
            pendingCount: pendingCount,
            isOffline: isOffline,
            lastSyncedAt: lastSyncedAt,
            warningMessage: warningMessage,
            rejectedChanges: rejectedChanges,
            syncLog: syncLog,
          ),
        );

  const SyncFailure.fromSnapshot(SyncSnapshot s, {required this.errorMessage})
      : super._(snapshot: s);

  @override
  final String errorMessage;
}
