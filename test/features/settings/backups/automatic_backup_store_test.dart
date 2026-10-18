import 'dart:io';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';
import 'package:collectarr_app/features/settings/backups/automatic_backup.dart';
import 'package:collectarr_app/features/settings/backups/automatic_backup_store_native.dart';
import 'package:collectarr_app/features/settings/database_backup.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory folder;
  late LocalDatabase db;
  late FileAutomaticBackupStore store;

  setUp(() async {
    folder = await Directory.systemTemp.createTemp('collectarr-backups-test-');
    db = LocalDatabase(NativeDatabase.memory());
    store = FileAutomaticBackupStore(() async => folder);
    await PickListRepository(db).addValue('locations', 'Record Cabinet');
  });

  tearDown(() async {
    await db.close();
    await folder.delete(recursive: true);
  });

  test('a backup is a time-stamped copy that restores the same data', () async {
    final backup = await store.create(db,
        reason: AutomaticBackupReason.scheduled,
        now: DateTime(2026, 10, 18, 23, 15, 7));

    expect(p.basename(backup.path),
        'collectarr-backup-2026-10-18_23-15-07.sqlite');
    expect(backup.sizeBytes, greaterThan(0));
    final before = await File(backup.path).readAsBytes();

    final data = await store.read(backup);
    final live = await DatabaseBackup(db).export();
    expect(data['pick_list_values_cache'], live['pick_list_values_cache']);
    // Reading works on a copy; the backup file itself is untouched.
    expect(await File(backup.path).readAsBytes(), before);
    await DatabaseBackup(db).validate(data);
  });

  test('backups list newest first with their reason; other files are ignored',
      () async {
    await store.create(db,
        reason: AutomaticBackupReason.scheduled, now: DateTime(2026, 10, 1));
    await store.create(db,
        reason: AutomaticBackupReason.beforeRestore,
        now: DateTime(2026, 10, 2));
    await File(p.join(folder.path, 'notes.txt')).writeAsString('mine');

    final backups = await store.list();
    expect([for (final b in backups) b.createdAt],
        [DateTime(2026, 10, 2), DateTime(2026, 10, 1)]);
    expect(backups.first.reason, AutomaticBackupReason.beforeRestore);
  });

  test('pruning removes backups past the kept days but never the newest',
      () async {
    for (final day in [1, 10, 20]) {
      await store.create(db,
          reason: AutomaticBackupReason.scheduled, now: DateTime(2026, 9, day));
    }
    final notes = File(p.join(folder.path, 'notes.txt'))
      ..writeAsStringSync('mine');

    expect(await store.prune(keepDays: 14, now: DateTime(2026, 9, 25)), 2);
    expect([for (final b in await store.list()) b.createdAt.day], [20]);

    // Even when every backup is past the period, the newest one stays.
    expect(await store.prune(keepDays: 1, now: DateTime(2026, 12, 1)), 0);
    expect(await store.list(), hasLength(1));
    expect(notes.existsSync(), isTrue);
  });
}
