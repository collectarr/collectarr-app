import 'package:collectarr_app/features/library/workspace/tiles/card.dart';
import 'package:collectarr_app/features/library/selection/bulk_edit_dialog.dart';
import 'package:collectarr_app/features/library/ui/primitives/selection_fields.dart';
import 'package:flutter/gestures.dart';
import 'package:collectarr_app/ui/adaptive/platform_layout.dart';
import 'package:collectarr_app/features/library/workspace/tiles/cover_tile.dart';
import 'dart:io';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_entry_repository.dart';
import 'package:collectarr_app/features/library/edit/shell/scaffold.dart';
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
  testWidgets(
      'personal edit survives reload and selection bulk edit saves tags',
      (tester) async {
    setUpTestAppPreferences();
    tester.view.physicalSize = appPresentationPlatform.isNativeMobile
        ? const Size(390, 844)
        : const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final root = Directory.systemTemp.createTempSync('collectarr-native-edit-');
    final file =
        File('${root.path}${Platform.pathSeparator}collectarr-library.sqlite');
    LocalDatabase? database = LocalDatabase(NativeDatabase(file));
    addTearDown(() async {
      await disposeTestApp(tester);
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
    if (appPresentationPlatform.isNativeMobile) {
      await tester.tap(find.byType(LibraryCoverTile).first);
      await pumpUntilSettled(tester);
    } else {
      await tester.tap(find.text('Native Personal Album').first);
      await tester.pump(const Duration(milliseconds: 80));
      await tester.tap(find.text('Native Personal Album').first);
      await pumpUntilSettled(tester);
    }
    await tester.tap(find.byTooltip('Edit').first);
    await pumpUntilSettled(tester);
    expect(find.byType(LibraryEditDialogScaffold), findsOneWidget);
    final personalTab = find.text('Personal').last;
    await tester.ensureVisible(personalTab);
    await pumpUntilSettled(tester);
    await tester.tap(personalTab);
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
    if (!appPresentationPlatform.isNativeMobile) {
      final covers = find.byType(LibraryCoverTile);
      final tile = covers.evaluate().isNotEmpty
          ? covers.first
          : find.byType(LibraryWorkspaceCard).first;
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(tile));
      await pumpUntilSettled(tester);
      await tester.tap(find.descendant(
          of: tile, matching: find.byType(LibraryTileSelectionToggleButton)));
      await pumpUntilSettled(tester);
      await tester.tap(find.widgetWithText(TextButton, 'Edit').first);
      await pumpUntilSettled(tester);
      expect(find.byType(LibraryBulkEditDialog), findsOneWidget);
      final tags = tester
          .widgetList<LibraryMultiVocabularyField>(
              find.byType(LibraryMultiVocabularyField))
          .singleWhere((field) => field.label == 'Tags');
      tags.controller.value = ['native-bulk-tag'];
      await tester.pump();
      await tester.tap(find.text('Apply').last);
      await pumpUntilSettled(tester);
      expect(find.byType(LibraryBulkEditDialog), findsNothing);
      expect(
          (await MusicEntryRepository(database).listActive())
              .single
              .personal
              .tags,
          contains('native-bulk-tag'));
    }
    expect(tester.takeException(), isNull);
    await disposeTestApp(tester);
  });
}
