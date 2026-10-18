import 'dart:io';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/settings/backups/automatic_backup.dart';
import 'package:collectarr_app/features/settings/backups/automatic_backup_controller.dart';
import 'package:collectarr_app/features/settings/backups/automatic_backup_store_native.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Directory folder;
  late LocalDatabase db;
  late DateTime now;
  late ProviderContainer container;

  AutomaticBackupController controller() =>
      container.read(automaticBackupProvider.notifier);
  List<AutomaticBackup> backups() =>
      container.read(automaticBackupProvider).backups;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    folder = await Directory.systemTemp.createTemp('collectarr-backups-test-');
    db = LocalDatabase(NativeDatabase.memory());
    now = DateTime(2026, 10, 18, 9);
    container = ProviderContainer(overrides: [
      localDatabaseProvider.overrideWithValue(db),
      automaticBackupStoreProvider
          .overrideWithValue(FileAutomaticBackupStore(() async => folder)),
      automaticBackupClockProvider.overrideWithValue(() => now),
    ]);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
    await folder.delete(recursive: true);
  });

  test('startup takes one backup a day', () async {
    await controller().backUpIfDue();
    expect(backups(), hasLength(1));

    now = now.add(const Duration(hours: 23));
    await controller().backUpIfDue();
    expect(backups(), hasLength(1));

    now = now.add(const Duration(hours: 2));
    await controller().backUpIfDue();
    expect(backups(), hasLength(2));
  });

  test('startup takes none when automatic backups are off', () async {
    await controller().setEnabled(false);
    await controller().backUpIfDue();

    expect(backups(), isEmpty);
    expect(
        (await SharedPreferences.getInstance())
            .getBool('collectarr.backups.automatic'),
        isFalse);
  });

  test('backups past the kept days are removed', () async {
    await controller().load();
    await controller().setKeepDays(7);
    for (var day = 0; day < 10; day++) {
      await controller().backUp();
      now = now.add(const Duration(days: 1));
    }

    expect(backups().map((b) => b.createdAt.day),
        [27, 26, 25, 24, 23, 22, 21, 20]);
    await controller().setKeepDays(0);
    await controller().backUp(reason: AutomaticBackupReason.beforeClear);
    expect(backups(), hasLength(9));
    expect(backups().first.reason, AutomaticBackupReason.beforeClear);
  });
}
