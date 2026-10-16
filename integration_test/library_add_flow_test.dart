import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_entry_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/support/app/provider_overrides.dart';
import '../test/support/app/test_app_harness.dart';
import '../test/support/fakes/music_catalog_api_fake.dart';
import '../test/support/fixtures/test_constants.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
      'Core search selection saves a Music entry and returns to library',
      (tester) async {
    setUpTestAppPreferences();
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final database = LocalDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final api = MusicCatalogApiFake(
        searchId: 'native-core-album', title: 'Native Core Album');
    await tester.pumpWidget(
        testApp(overrides: testAppOverrides(database: database, api: api)));
    await pumpUntilSettled(tester);
    await tester.tap(find.byKey(const Key('app.open-navigation')));
    await pumpUntilSettled(tester);
    await tester.tap(find.text('Add Albums from Core'));
    await pumpUntilSettled(tester);
    expect(find.byType(LibraryAddDialog), findsOneWidget);
    final queryField = find.descendant(
        of: find.byKey(const ValueKey('library-add-query-field')),
        matching: find.byType(EditableText));
    await tester.enterText(queryField, 'Native Core Album');
    await tester.tap(find.byKey(const ValueKey('library-add-search-button')));
    await pumpUntilSettled(tester);
    expect(api.lastSearchQuery?.query, 'Native Core Album');
    await tester.tap(find
        .byKey(const ValueKey('library-add-search-result-native-core-album')));
    await pumpUntilSettled(tester);
    await tester.tap(find.text('Add to Collection'));
    await pumpUntilSettled(tester);
    // Adding confirms the pre-fill settings first, as in the reference.
    expect(find.text('Pre-fill Settings'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await pumpUntilSettled(tester);
    expect(find.byType(LibraryAddDialog), findsNothing);
    final saved = (await MusicEntryRepository(database).listActive()).single;
    expect(saved.metadata.title, 'Native Core Album');
    expect(saved.sourceCatalogRef?.id, 'native-core-album');
    final container = ProviderScope.containerOf(
        tester.element(find.text('COLLECTARR MUSIC').first));
    expect(
        container
            .read(appRouterProvider)
            .routeInformationProvider
            .value
            .uri
            .path,
        AppRoutes.libraries);
    expect(find.text('Native Core Album'), findsWidgets);
    expect(tester.takeException(), isNull);
    await disposeTestApp(tester);
  });
}
