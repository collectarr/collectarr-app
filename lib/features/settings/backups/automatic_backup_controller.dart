import 'package:collectarr_app/features/settings/backups/automatic_backup.dart';
import 'package:collectarr_app/features/settings/backups/automatic_backup_store.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// How long backups are kept; 0 keeps them all.
const automaticBackupKeepDaysOptions = [7, 14, 30, 90, 365, 0];

final automaticBackupStoreProvider =
    Provider<AutomaticBackupStore>((ref) => createAutomaticBackupStore());

/// The clock backups are stamped and pruned with; tests replace it.
final automaticBackupClockProvider =
    Provider<DateTime Function()>((ref) => DateTime.now);

final class AutomaticBackupState {
  const AutomaticBackupState({
    this.enabled = true,
    this.keepDays = 30,
    this.backups = const [],
    this.busy = false,
  });

  /// Take a backup at startup when the newest one is a day old.
  final bool enabled;
  final int keepDays;

  /// Newest first.
  final List<AutomaticBackup> backups;
  final bool busy;

  AutomaticBackupState copyWith({
    bool? enabled,
    int? keepDays,
    List<AutomaticBackup>? backups,
    bool? busy,
  }) =>
      AutomaticBackupState(
        enabled: enabled ?? this.enabled,
        keepDays: keepDays ?? this.keepDays,
        backups: backups ?? this.backups,
        busy: busy ?? this.busy,
      );
}

final automaticBackupProvider =
    NotifierProvider<AutomaticBackupController, AutomaticBackupState>(
        AutomaticBackupController.new);

/// Keeps time-stamped copies of the local database: one a day at startup,
/// one on request, and one before a restore or a clear replaces the data.
class AutomaticBackupController extends Notifier<AutomaticBackupState> {
  static const _enabledKey = 'collectarr.backups.automatic';
  static const _keepDaysKey = 'collectarr.backups.keep_days';
  static const interval = Duration(days: 1);

  AutomaticBackupStore get _store => ref.read(automaticBackupStoreProvider);
  DateTime _now() => ref.read(automaticBackupClockProvider)();

  bool get isSupported => _store.isSupported;

  @override
  AutomaticBackupState build() => const AutomaticBackupState();

  /// Reads the settings and the backups folder.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      enabled: prefs.getBool(_enabledKey) ?? true,
      keepDays: prefs.getInt(_keepDaysKey) ?? 30,
      backups: await _store.list(),
    );
  }

  /// Takes the daily backup when automatic backups are on and the newest one
  /// is older than [interval]. Failures are left for the next start.
  Future<void> backUpIfDue() async {
    if (!isSupported) return;
    try {
      await load();
      if (!state.enabled) return;
      final newest = state.backups.firstOrNull;
      if (newest != null && _now().difference(newest.createdAt) < interval) {
        return;
      }
      await backUp();
    } catch (_) {
      // A missed daily backup must not stop the app from starting.
    }
  }

  /// Copies the database now, then removes backups past the kept period.
  Future<AutomaticBackup> backUp({
    AutomaticBackupReason reason = AutomaticBackupReason.scheduled,
  }) async {
    state = state.copyWith(busy: true);
    try {
      final now = _now();
      final backup = await _store.create(ref.read(localDatabaseProvider),
          reason: reason, now: now);
      if (state.keepDays > 0) {
        await _store.prune(keepDays: state.keepDays, now: now);
      }
      state = state.copyWith(backups: await _store.list());
      return backup;
    } finally {
      state = state.copyWith(busy: false);
    }
  }

  /// The backup's data, ready for [LocalDatabaseMaintenanceCoordinator].
  Future<Map<String, dynamic>> read(AutomaticBackup backup) =>
      _store.read(backup);

  Future<String> folderPath() => _store.folderPath();

  Future<void> setEnabled(bool enabled) async {
    state = state.copyWith(enabled: enabled);
    await (await SharedPreferences.getInstance()).setBool(_enabledKey, enabled);
  }

  Future<void> setKeepDays(int keepDays) async {
    state = state.copyWith(keepDays: keepDays);
    await (await SharedPreferences.getInstance())
        .setInt(_keepDaysKey, keepDays);
    if (keepDays > 0 && isSupported) {
      await _store.prune(keepDays: keepDays, now: _now());
      state = state.copyWith(backups: await _store.list());
    }
  }
}
