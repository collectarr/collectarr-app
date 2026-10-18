import 'package:collectarr_app/core/db/local_database.dart';

/// Why an automatic backup was taken; the reason is part of its file name.
enum AutomaticBackupReason {
  /// The daily backup taken at startup, or one taken from Settings.
  scheduled(null, 'Backup'),
  beforeRestore('before-restore', 'Before restore'),
  beforeClear('before-clear', 'Before clearing');

  const AutomaticBackupReason(this.fileSuffix, this.label);

  final String? fileSuffix;
  final String label;
}

/// One time-stamped copy of the local database in the backups folder.
final class AutomaticBackup {
  const AutomaticBackup({
    required this.path,
    required this.createdAt,
    required this.sizeBytes,
    required this.reason,
  });

  final String path;
  final DateTime createdAt;
  final int sizeBytes;
  final AutomaticBackupReason reason;

  static final _name = RegExp(
    r'^collectarr-backup-(\d{4})-(\d{2})-(\d{2})_(\d{2})-(\d{2})-(\d{2})'
    r'(?:-(before-restore|before-clear))?\.sqlite$',
  );

  static String two(int value) => value.toString().padLeft(2, '0');

  /// "collectarr-backup-2026-10-18_23-15-00.sqlite", local time.
  static String fileName(DateTime at, AutomaticBackupReason reason) =>
      'collectarr-backup-${at.year}-${two(at.month)}-${two(at.day)}'
      '_${two(at.hour)}-${two(at.minute)}-${two(at.second)}'
      '${reason.fileSuffix == null ? '' : '-${reason.fileSuffix}'}.sqlite';

  /// The time and reason encoded in a backup file name, or null for any file
  /// the backups folder holds that Collectarr did not write.
  static ({DateTime createdAt, AutomaticBackupReason reason})? parse(
      String fileName) {
    final match = _name.firstMatch(fileName);
    if (match == null) return null;
    int part(int group) => int.parse(match.group(group)!);
    return (
      createdAt: DateTime(part(1), part(2), part(3), part(4), part(5), part(6)),
      reason: AutomaticBackupReason.values
          .firstWhere((reason) => reason.fileSuffix == match.group(7)),
    );
  }
}

/// Where automatic backups live. Only platforms with a file system have one.
abstract interface class AutomaticBackupStore {
  bool get isSupported;

  /// The folder the backups are written to.
  Future<String> folderPath();

  /// Every backup in the folder, newest first.
  Future<List<AutomaticBackup>> list();

  /// Copies [db] into a new time-stamped file.
  Future<AutomaticBackup> create(
    LocalDatabase db, {
    required AutomaticBackupReason reason,
    required DateTime now,
  });

  /// Deletes backups older than [keepDays] days, always keeping the newest.
  Future<int> prune({required int keepDays, required DateTime now});

  /// The backup's data in the format of [DatabaseBackup.export]. The file is
  /// read from a temporary copy, which is brought up to the current schema,
  /// so the backup itself is never changed and older backups still restore.
  Future<Map<String, dynamic>> read(AutomaticBackup backup);
}
