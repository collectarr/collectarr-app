import 'package:collectarr_app/ui/app_page_header.dart';
import 'package:collectarr_app/app/app_shell.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/features/library/collections/dialog.dart';
import 'package:collectarr_app/features/library/collections/repository.dart';
import 'package:collectarr_app/features/library/generic/sort_dialog.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/config.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../support/app/provider_overrides.dart';
import '../../support/app/test_app_harness.dart';
import '../../support/fixtures/test_constants.dart';

void main() {
  for (final width in [320.0, 1024.0]) {
    testWidgets(
        'native Settings restores a section and returns to index at $width dp',
        (tester) async {
      setUpTestAppPreferences();
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = LocalDatabase(NativeDatabase.memory());
      addTearDown(() => tester.runAsync(db.close));
      await tester.pumpWidget(testApp(
          overrides:
              testAppOverrides(database: db, stubEmptyCollections: true)));
      await pumpUntilSettled(tester);
      final router =
          ProviderScope.containerOf(tester.element(find.byType(AppShell)))
              .read(appRouterProvider);
      router.go('/settings?kind=comic&section=appearance');
      await pumpUntilSettled(tester);
      expect(find.text('Application Skin'), findsOneWidget);
      await tester.tap(find.byType(AppPageBackButton));
      await pumpUntilSettled(tester);
      expect(
          router.routeInformationProvider.value.uri.queryParameters['section'],
          isNull);
      await tester.tap(find.widgetWithText(ListTile, 'Appearance'));
      await pumpUntilSettled(tester);
      expect(
          router.routeInformationProvider.value.uri.queryParameters['section'],
          'appearance');
      router.pop();
      await pumpUntilSettled(tester);
      expect(find.widgetWithText(ListTile, 'Account'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await disposeTestApp(tester);
    },
        variant: TargetPlatformVariant(
            {TargetPlatform.android, TargetPlatform.iOS}));
  }

  testWidgets(
      'native sort favorites and advanced fields use shared rules for every active kind',
      (tester) async {
    setUpTestAppPreferences();
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final type in collectarrKindRegistrationsList) {
      final favorites = librarySortFavoritesForType(type);
      if (favorites.isEmpty) continue;
      List<LibrarySortRule>? result;
      await tester.pumpWidget(MaterialApp(
          home: Builder(
              builder: (context) => Scaffold(
                    body: TextButton(
                        onPressed: () async {
                          result = await showLibrarySortDialog(
                              context: context,
                              type: type,
                              currentRules: favorites.first.rules);
                        },
                        child: const Text('Open sort')),
                  ))));
      await tester.tap(find.text('Open sort'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Advanced sorting'));
      await tester.pumpAndSettle();
      expect(find.text('Fields'), findsOneWidget);
      await tester.tap(find.text('Selected'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Sort descending'), findsWidgets);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(result?.map((r) => r.column),
          favorites.first.rules.map((r) => r.column));
      await tester.tap(find.text('Open sort'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(favorites.first.label).last);
      await tester.pumpAndSettle();
      expect(result?.length, favorites.first.rules.length);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
  },
      variant:
          TargetPlatformVariant({TargetPlatform.android, TargetPlatform.iOS}));

  testWidgets(
      'native collection management cancels creation without changing storage',
      (tester) async {
    setUpTestAppPreferences();
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(() => tester.runAsync(db.close));
    final repo = LibraryCollectionRepository(db);
    await tester.runAsync(() => repo.ensureDefault('music'));
    await tester.pumpWidget(ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Builder(
              builder: (context) => Scaffold(
                  body: TextButton(
                      onPressed: () =>
                          showLibraryCollectionsDialog(context, kind: 'music'),
                      child: const Text('Collections')))),
        )));
    await tester.tap(find.text('Collections'));
    await pumpUntilSettled(tester);
    expect(find.text('Manage Collections'), findsOneWidget);
    await tester.tap(find.byTooltip('Create collection'));
    await pumpUntilSettled(tester);
    await tester.tap(find.text('Cancel'));
    await pumpUntilSettled(tester);
    expect((await tester.runAsync(() => repo.list('music')))!.length, 1);
    await tester.tap(find.byType(BackButton));
    await pumpUntilSettled(tester);
    expect(find.text('Collections'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await disposeTestApp(tester);
  },
      variant:
          TargetPlatformVariant({TargetPlatform.android, TargetPlatform.iOS}));
}
