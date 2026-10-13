import 'dart:io';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_entry_repository.dart';
import 'package:collectarr_app/features/library/edit/shell/library_edit_scaffold.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/support/app/provider_overrides.dart';
import '../test/support/app/test_app_harness.dart';
import '../test/support/fakes/music_catalog_api_fake.dart';
import '../test/support/fixtures/music_fixtures.dart';
import '../test/support/fixtures/test_constants.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('personal edit persists across database close and app reload',
      (tester) async {
    setUpTestAppPreferences();
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final root = Directory.systemTemp.createTempSync('collectarr-native-edit-');
    final file =
        File('${root.path}${Platform.pathSeparator}collectarr-library.sqlite');
    LocalDatabase? database = LocalDatabase(NativeDatabase(file));
    addTearDown(() async {
      await database?.close();
      // Only files created by this test in its own temporary directory.
      for (final entry in root.listSync()) {
        if (entry is File) entry.deleteSync();
      }
      root.deleteSync();
    });
    await MusicEntryRepository(database).upsert(musicLibraryEntryFixture(
        id: 'native-entry',
        metadata: musicAlbumFixture(title: 'Native Personal Album')));
    final api = MusicCatalogApiFake();
    await tester.pumpWidget(
        testApp(overrides: testAppOverrides(database: database, api: api)));
    await pumpUntilSettled(tester);
    await tester.tap(find.text('Native Personal Album').first);
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tap(find.text('Native Personal Album').first);
    await pumpUntilSettled(tester);
    await tester.tap(find.byTooltip('Edit').first);
    await pumpUntilSettled(tester);
    expect(find.byType(LibraryEditDialogScaffold), findsOneWidget);
    await tester.tap(find.text('Personal').last);
    await pumpUntilSettled(tester);
    final notes = find.descendant(
        of: find.byKey(const ValueKey('library-entry-personal_notes')),
        matching: find.byType(EditableText));
    await tester.ensureVisible(notes);
    await tester.enterText(notes, 'Saved through the native edit dialog');
    await tester.tap(find.text('Save').last);
    await pumpUntilSettled(tester);
    expect(find.byType(LibraryEditDialogScaffold), findsNothing);
    expect(
        (await MusicEntryRepository(database).listActive())
            .single
            .personal
            .personalNotes,
        'Saved through the native edit dialog');
    expect(api.lastSearchQuery, isNull);
    await disposeTestApp(tester);
    await database.close();
    database = LocalDatabase(NativeDatabase(file));
    final reloaded = (await MusicEntryRepository(database).listActive()).single;
    expect(reloaded.personal.personalNotes,
        'Saved through the native edit dialog');
    expect(reloaded.metadata.title, 'Native Personal Album');
    await tester.pumpWidget(
        testApp(overrides: testAppOverrides(database: database, api: api)));
    await pumpUntilSettled(tester);
    expect(find.text('Native Personal Album'), findsWidgets);
    expect(tester.takeException(), isNull);
    await disposeTestApp(tester);
  });
}
