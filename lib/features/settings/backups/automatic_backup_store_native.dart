import 'dart:io';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/platform/app_data_directory_native.dart';
import 'package:collectarr_app/features/settings/backups/automatic_backup.dart';
import 'package:collectarr_app/features/settings/database_backup.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

AutomaticBackupStore createAutomaticBackupStore() => FileAutomaticBackupStore(
    () async => Directory(p.join((await appDataDirectory()).path, 'backups')));

/// Backups as SQLite files in a folder next to the database.
final class FileAutomaticBackupStore implements AutomaticBackupStore {
  FileAutomaticBackupStore(this._directory);

  final Future<Directory> Function() _directory;

  @override
  bool get isSupported => true;

  @override
  Future<String> folderPath() async => (await _directory()).path;

  @override
  Future<List<AutomaticBackup>> list() async {
    final directory = await _directory();
    if (!await directory.exists()) return const [];
    final backups = <AutomaticBackup>[];
    await for (final entity in directory.list()) {
      if (entity is! File) continue;
      final parsed = AutomaticBackup.parse(p.basename(entity.path));
      if (parsed == null) continue;
      backups.add(AutomaticBackup(
        path: entity.path,
        createdAt: parsed.createdAt,
        sizeBytes: await entity.length(),
        reason: parsed.reason,
      ));
    }
    return backups..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<AutomaticBackup> create(
    LocalDatabase db, {
    required AutomaticBackupReason reason,
    required DateTime now,
  }) async {
    final directory = await _directory();
    await directory.create(recursive: true);
    final target =
        File(p.join(directory.path, AutomaticBackup.fileName(now, reason)));
    // VACUUM INTO writes a consistent, compacted copy without touching the
    // live file; the copy only takes its final name once it is complete.
    final partial = File('${target.path}.partial');
    if (await partial.exists()) await partial.delete();
    await db
        .customStatement("VACUUM INTO '${partial.path.replaceAll("'", "''")}'");
    // A second backup within the same second replaces the first.
    if (await target.exists()) await target.delete();
    await partial.rename(target.path);
    return AutomaticBackup(
      path: target.path,
      createdAt: AutomaticBackup.parse(p.basename(target.path))!.createdAt,
      sizeBytes: await target.length(),
      reason: reason,
    );
  }

  @override
  Future<int> prune({required int keepDays, required DateTime now}) async {
    final backups = await list();
    final cutoff = now.subtract(Duration(days: keepDays));
    var deleted = 0;
    for (final backup in backups.skip(1)) {
      if (!backup.createdAt.isBefore(cutoff)) continue;
      await File(backup.path).delete();
      deleted++;
    }
    return deleted;
  }

  @override
  Future<Map<String, dynamic>> read(AutomaticBackup backup) async {
    final scratch =
        await Directory.systemTemp.createTemp('collectarr-backup-restore-');
    try {
      final copy =
          await File(backup.path).copy(p.join(scratch.path, 'backup.sqlite'));
      final db = LocalDatabase(NativeDatabase(copy));
      try {
        return await DatabaseBackup(db).export();
      } finally {
        await db.close();
      }
    } finally {
      await scratch.delete(recursive: true);
    }
  }
}
