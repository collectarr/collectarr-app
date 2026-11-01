import 'package:collectarr_app/app/app_shell.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app/provider_overrides.dart';
import '../../support/app/test_app_harness.dart';
import '../../support/fixtures/test_constants.dart';

void main() {
  testWidgets('mobile header opens, submits and clears library search',
      (tester) async {
    setUpTestAppPreferences();
    tester.view.physicalSize = const Size(407, 904);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(testApp(
        overrides: testAppOverrides(database: db, stubEmptyCollections: true)));
    await pumpUntilSettled(tester);
    final container =
        ProviderScope.containerOf(tester.element(find.byType(AppShell)));
    final router = container.read(appRouterProvider);
    router.go('/libraries?kind=comic');
    await pumpUntilSettled(tester);
    expect(find.byType(SearchBar), findsNothing);
    expect(find.byKey(const Key('app.open-search')), findsOneWidget);
    await tester.tap(find.byKey(const Key('app.open-search')));
    await pumpUntilSettled(tester);
    final field = find.byKey(const ValueKey('library-header-search-comic'));
    expect(field, findsOneWidget);
    expect(tester.testTextInput.isVisible, isTrue);
    expect(find.byKey(const Key('app.brand-title')), findsNothing);
    await tester.enterText(field, 'Batman');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await pumpUntilSettled(tester);
    expect(find.text('No results found...'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear search'));
    await pumpUntilSettled(tester);
    expect(tester.widget<TextField>(field).controller!.text, isEmpty);
    expect(find.text('No results found...'), findsNothing);
    await tester.tap(find.byType(BackButton));
    await pumpUntilSettled(tester);
    expect(field, findsNothing);
    expect(find.text('CLR COMICS'), findsOneWidget);
    await tester.tap(find.byKey(const Key('app.open-search')));
    await pumpUntilSettled(tester);
    await tester.enterText(field, 'query');
    router.go('/libraries?kind=game');
    await pumpUntilSettled(tester);
    expect(
        find.byKey(const ValueKey('library-header-search-game')), findsNothing);
    await tester.tap(find.byKey(const Key('app.open-search')));
    await pumpUntilSettled(tester);
    expect(
        tester
            .widget<TextField>(
                find.byKey(const ValueKey('library-header-search-game')))
            .controller!
            .text,
        isEmpty);
    await disposeTestApp(tester);
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));
}
