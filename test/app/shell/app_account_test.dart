import 'package:collectarr_app/app/app_shell.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/features/account/my_account_page.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/collections/library_collection_repository.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app/provider_overrides.dart';
import '../../support/app/test_app_harness.dart';
import '../../support/fixtures/test_constants.dart';

void main() {
  late LocalDatabase db;
  setUp(() {
    setUpTestAppPreferences();
    db = LocalDatabase(NativeDatabase.memory());
  });
  tearDown(() async => db.close());

  for (final palette in [kDefaultAppThemePalette, kLightAppThemePalette]) {
    testWidgets(
        'account drawer uses the shared sidebar surface, opens overview and logs out (${palette.brightness})',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.runAsync(() async {
        final repo = LibraryCollectionRepository(db);
        await repo.ensureDefault('music');
        await repo.create('music', 'Keep after logout');
      });
      await tester.pumpWidget(ProviderScope(
        overrides: [
          ...testAppOverrides(database: db),
          shelfProvider.overrideWith((ref) async => const ShelfState(
              entries: [],
              entryCount: 7,
              wishlistCount: 3,
              pricedCount: 0,
              totalPaidCents: null,
              primaryCurrency: null,
              hasMixedCurrencies: false,
              libraryEntryCountByKind: {'music': 2, 'game': 5},
              wishlistItemCountByKind: {'music': 1, 'game': 2})),
        ],
        child: Consumer(
            builder: (context, ref, _) => MaterialApp.router(
                theme: buildAppShellTheme(palette: palette),
                routerConfig: ref.watch(appRouterProvider))),
      ));
      await pumpUntilSettled(tester);
      final container =
          ProviderScope.containerOf(tester.element(find.byType(AppShell)));
      final router = container.read(appRouterProvider);
      router.go('/libraries?kind=game');
      await pumpUntilSettled(tester);
      await tester.tap(find.byKey(const Key('app.account')));
      await pumpUntilSettled(tester);
      final drawer =
          tester.widget<Drawer>(find.byKey(const Key('account.drawer')));
      expect(drawer.backgroundColor, palette.sidebar);
      expect(find.text('test@example.com'), findsOneWidget);
      await tester.tap(find.text('My Account'));
      await pumpUntilSettled(tester);
      expect(find.byType(MyAccountPage), findsOneWidget);
      expect(router.routeInformationProvider.value.uri.queryParameters['kind'],
          'game');
      expect(find.text('Library totals on this device'), findsOneWidget);
      expect(find.text('Hardware'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      await tester.tap(find.byKey(const Key('app.account')));
      await pumpUntilSettled(tester);
      await tester.tap(find.text('Logout'));
      await pumpUntilSettled(tester);
      expect(container.read(authControllerProvider).isAuthenticated, isFalse);
      // Auth deliberately retains the last email; the header must still clear.
      expect(container.read(authControllerProvider).email, 'test@example.com');
      expect(find.text("test's games"), findsNothing);
      expect(find.text('Local library'), findsOneWidget);
      expect(find.byKey(const Key('account.drawer')), findsNothing);
      final collections = await tester
          .runAsync(() => LibraryCollectionRepository(db).watch('music').first);
      expect(collections!.any((c) => c.name == 'Keep after logout'), isTrue);
      expect(tester.takeException(), isNull);
      await disposeTestApp(tester);
    });
  }

  testWidgets(
      'signed-out account overview fits a narrow screen and offers sign in',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(testApp(overrides: [
      ...testAppOverrides(database: db, stubEmptyCollections: true),
    ]));
    await pumpUntilSettled(tester);
    final container =
        ProviderScope.containerOf(tester.element(find.byType(AppShell)));
    // Exercise the real logout path before opening the signed-out drawer.
    await container.read(authControllerProvider.notifier).logout();
    await pumpUntilSettled(tester);
    await tester.tap(find.byKey(const Key('app.account')));
    await pumpUntilSettled(tester);
    expect(find.text('Logout'), findsNothing);
    expect(find.text('Sign in'), findsOneWidget);
    await tester.tap(find.text('My Account'));
    await pumpUntilSettled(tester);
    expect(find.byType(MyAccountPage), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Sync & activity'), 250);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const Key('app.account')));
    await pumpUntilSettled(tester);
    await tester.tap(find.text('Sign in').last);
    await pumpUntilSettled(tester);
    expect(
        container
            .read(appRouterProvider)
            .routeInformationProvider
            .value
            .uri
            .path,
        AppRoutes.auth);
    await disposeTestApp(tester);
  });
}
