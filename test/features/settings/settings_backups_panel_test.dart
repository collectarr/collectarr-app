import 'dart:io';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';
import 'package:collectarr_app/features/settings/backups/automatic_backup.dart';
import 'package:collectarr_app/features/settings/backups/automatic_backup_controller.dart';
import 'package:collectarr_app/features/settings/backups/automatic_backup_store_native.dart';
import 'package:collectarr_app/features/settings/settings_backups_panel.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lets the file and database work started by a tap finish: it runs on real
/// I/O, which the test clock does not advance.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 40; i++) {
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 25)));
    await tester.pump();
  }
}

void main() {
  late Directory folder;
  late LocalDatabase db;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    folder = Directory.systemTemp.createTempSync('collectarr-backups-test-');
    db = LocalDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
    folder.deleteSync(recursive: true);
  });

  testWidgets('Back up now lists a copy that restores the data it held',
      (tester) async {
    final container = ProviderContainer(overrides: [
      localDatabaseProvider.overrideWithValue(db),
      automaticBackupStoreProvider
          .overrideWithValue(FileAutomaticBackupStore(() async => folder)),
    ]);
    addTearDown(container.dispose);
    final values = PickListRepository(db);

    await tester.runAsync(() => values.addValue('locations', 'Shelf A'));
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
          home: Scaffold(
              body: SingleChildScrollView(
                  child: SettingsAutomaticBackupsPanel()))),
    ));
    await tester.runAsync(() => tester.pump(const Duration(milliseconds: 50)));
    expect(find.text('No backups yet.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('settings.backups.now')));
    await _settle(tester);
    expect(find.text('Restore'), findsOneWidget);

    await tester.runAsync(() => values.addValue('locations', 'Shelf B'));
    await tester.tap(find.text('Restore'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings.backups.restore.confirm')));
    await _settle(tester);

    expect(await tester.runAsync(() => values.getValues('locations')),
        ['Shelf A']);
    final backups = container.read(automaticBackupProvider).backups;
    expect(backups.map((backup) => backup.reason),
        contains(AutomaticBackupReason.beforeRestore));
  });
}
