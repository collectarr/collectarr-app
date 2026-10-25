import '../../support/app/provider_overrides.dart';
import '../../support/app/test_app_harness.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:drift/native.dart';
// Desktop and mobile smoke tests for navigation and mandatory destination keys.
import 'package:collectarr_app/app/shell/app_navigation_drawer.dart';
import 'package:collectarr_app/app/shell/app_navigation_model.dart';

import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/app/app_shell.dart';
import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/home/home_page.dart';
import 'package:collectarr_app/ui/app_page_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../support/fixtures/test_constants.dart';

void main() {
  late LocalDatabase database;
  setUp(() {
    setUpTestAppPreferences();
    database = LocalDatabase(NativeDatabase.memory());
  });
  tearDown(() async => database.close());

  group('App Mandatory Destination Smoke Tests', () {
    testWidgets(
        'direct Music settings route retains kind when returning to library',
        (tester) async {
      setUpTestAppPreferences();
      tester.view.physicalSize = kDesktopTestSize;
      tester.view.devicePixelRatio = kDesktopTestDPR;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(testApp(
          overrides: testAppOverrides(
              database: database, stubEmptyCollections: true)));
      await pumpUntilSettled(tester);
      final container =
          ProviderScope.containerOf(tester.element(find.byType(AppShell)));
      final router = container.read(appRouterProvider);
      router.go('/settings?kind=music');
      await pumpUntilSettled(tester);
      expect(find.text('CLR MUSIC'), findsOneWidget);
      await tester.tap(find.byKey(const Key('settings.back')));
      await pumpUntilSettled(tester);
      expect(
          router.routeInformationProvider.value.uri.path, AppRoutes.libraries);
      expect(router.routeInformationProvider.value.uri.queryParameters['kind'],
          'music');
      expect(find.text('CLR MUSIC'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await disposeTestApp(tester);
    });

    testWidgets(
        'Music header persists on pushed tools and Core add returns to library',
        (tester) async {
      setUpTestAppPreferences();
      tester.view.physicalSize = kDesktopTestSize;
      tester.view.devicePixelRatio = kDesktopTestDPR;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(testApp(
          overrides: testAppOverrides(
              database: database, stubEmptyCollections: true)));
      await pumpUntilSettled(tester);
      final container =
          ProviderScope.containerOf(tester.element(find.byType(AppShell)));
      final router = container.read(appRouterProvider);
      router.go('/libraries?kind=music');
      await pumpUntilSettled(tester);
      expect(find.text('CLR MUSIC'), findsOneWidget);
      final kindIcon =
          tester.widget<Icon>(find.byKey(const Key('app.kind-icon')));
      expect(kindIcon.icon, Icons.music_note);
      expect(kindIcon.color, Colors.white);

      await tester.tap(find.byKey(const Key('nav.library-kind-picker')));
      await pumpUntilSettled(tester);
      expect(find.text('Music'), findsOneWidget);
      expect(find.text('Albums'), findsNothing);
      await tester.tap(find.text('Music'));
      await pumpUntilSettled(tester);

      await tester.tap(find.byKey(const Key('app.open-navigation')));
      await pumpUntilSettled(tester);
      await tester.tap(find.text('Settings'));
      await pumpUntilSettled(tester);
      expect(find.text('CLR MUSIC'), findsOneWidget);
      expect(find.byType(AppPageHeader), findsOneWidget);
      await tester.tap(find.byKey(const Key('app.open-navigation')));
      await pumpUntilSettled(tester);
      await tester.tap(find.text('Print to PDF'));
      await pumpUntilSettled(tester);
      expect(find.text('CLR MUSIC'), findsOneWidget);
      expect(find.byKey(const Key('nav.library-kind-picker')), findsOneWidget);
      expect(find.byType(AppPageHeader), findsOneWidget);
      await tester.tap(find.byKey(const Key('app.open-navigation')));
      await pumpUntilSettled(tester);
      expect(
          tester
              .widget<AppNavigationDrawer>(find.byType(AppNavigationDrawer))
              .selectedAction,
          DrawerAction.printToPdf);
      // The selected entry is drawn in the kind accent at regular weight.
      expect(
          tester
              .widget<Text>(find.descendant(
                  of: find.byType(AppNavigationDrawer),
                  matching: find.text('Print to PDF')))
              .style
              ?.color,
          tester
              .widget<AppNavigationDrawer>(find.byType(AppNavigationDrawer))
              .accent);
      await tester.tap(find.text('Find Duplicates'));
      await pumpUntilSettled(tester);
      expect(find.byKey(const Key('print_pdf.back')), findsNothing);
      await tester.tap(find.byType(AppPageBackButton));
      await pumpUntilSettled(tester);
      expect(router.canPop(), isFalse);
      expect(
          router.routeInformationProvider.value.uri.path, AppRoutes.libraries);

      await tester.tap(find.byKey(const Key('app.open-navigation')));
      await pumpUntilSettled(tester);
      expect(
          tester
              .widget<AppNavigationDrawer>(find.byType(AppNavigationDrawer))
              .selectedAction,
          null);
      expect(find.text('My Shelf'), findsNothing);
      await tester.tap(find.text('Add Albums from Core'));
      await pumpUntilSettled(tester);
      expect(
          router.routeInformationProvider.value.uri.path, AppRoutes.libraries);
      expect(router.routeInformationProvider.value.uri.queryParameters['kind'],
          'music');
      expect(find.byType(LibraryAddDialog), findsOneWidget);
      Navigator.of(tester.element(find.byType(LibraryAddDialog))).pop();
      await pumpUntilSettled(tester);
      expect(find.byType(LibraryHomePage), findsOneWidget);
      expect(find.text('CLR MUSIC'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await disposeTestApp(tester);
    });

    testWidgets(
        'desktop smoke: can navigate through all mandatory destinations',
        (tester) async {
      setUpTestAppPreferences();

      tester.view.physicalSize = kDesktopTestSize;
      tester.view.devicePixelRatio = kDesktopTestDPR;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        testApp(
            overrides: testAppOverrides(
                database: database, stubEmptyCollections: true)),
      );
      await pumpUntilSettled(tester);

      expect(find.byType(AppShell), findsOneWidget);
      expect(find.byKey(const Key('app.open-navigation')), findsOneWidget);
      expect(find.byKey(const Key('app.kind-icon')), findsOneWidget);

      Future<void> openDrawer() async {
        await tester.tap(find.byKey(const Key('app.open-navigation')));
        await pumpUntilSettled(tester);
      }

      await openDrawer();
      expect(find.byKey(const Key('nav.library')), findsNothing);
      expect(find.byKey(const Key('nav.shelf')), findsNothing);
      expect(find.text('My Shelf'), findsNothing);
      expect(find.byKey(const Key('nav.more')), findsOneWidget);
      expect(find.byKey(const Key('nav.calendar')), findsOneWidget);

      // Navigate to the library
      Navigator.of(tester.element(find.byKey(const Key('nav.more')))).pop();
      await pumpUntilSettled(tester);
      expect(find.byType(AppShell), findsOneWidget);

      // Navigate to Loans / More
      await openDrawer();
      await tester.tap(find.byKey(const Key('nav.more')));
      await pumpUntilSettled(tester);
      expect(find.byType(AppShell), findsOneWidget);

      // Navigate to Calendar
      await openDrawer();
      await tester.tap(find.byKey(const Key('nav.calendar')));
      await pumpUntilSettled(tester);
      expect(find.byType(AppShell), findsOneWidget);

      // Navigate to Settings
      await tester.tap(find.byKey(const Key('app.open-navigation')));
      await pumpUntilSettled(tester);
      await tester.tap(find.text('Settings'));
      await pumpUntilSettled(tester);
      expect(find.byType(AppShell), findsOneWidget);

      // Navigate back to Libraries
      await tester.tap(find.byKey(const Key('settings.back')));
      await pumpUntilSettled(tester);
      expect(find.byType(AppShell), findsOneWidget);

      expect(tester.takeException(), isNull);
      await disposeTestApp(tester);
    });

    testWidgets(
        'mobile phone smoke (390x844): navigates shell, settings, and back without overflow',
        (tester) async {
      setUpTestAppPreferences();

      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        debugPrint('FLUTTER ON ERROR CAUGHT:\n${details.toString()}');
        originalOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      await tester.pumpWidget(
        testApp(
            overrides: testAppOverrides(
                database: database, stubEmptyCollections: true)),
      );
      await pumpUntilSettled(tester);

      expect(find.byType(AppShell), findsOneWidget);
      expect(find.byKey(const Key('app.open-navigation')), findsOneWidget);

      // Mandatory keys must be present in drawer on mobile
      await tester.tap(find.byKey(const Key('app.open-navigation')));
      await pumpUntilSettled(tester);
      expect(find.byKey(const Key('nav.library')), findsNothing);
      expect(find.byKey(const Key('nav.shelf')), findsNothing);
      expect(find.text('My Shelf'), findsNothing);

      // Dismiss navigation without changing the current library
      Navigator.of(tester.element(find.byKey(const Key('nav.more')))).pop();
      await pumpUntilSettled(tester);
      expect(find.byType(AppShell), findsOneWidget);

      // Navigate to Settings
      await tester.tap(find.byKey(const Key('app.open-navigation')));
      await pumpUntilSettled(tester);
      await tester.tap(find.text('Settings'));
      await pumpUntilSettled(tester);
      expect(find.byType(AppShell), findsOneWidget);

      // Navigate back to Libraries
      await tester.tap(find.byKey(const Key('settings.back')));
      await pumpUntilSettled(tester);
      expect(find.byType(AppShell), findsOneWidget);

      final err = tester.takeException();
      if (err is FlutterError) {
        debugPrint('FULL FLUTTER ERROR:\n${err.message}');
        for (final d in err.diagnostics) {
          debugPrint('  diag: ${d.toStringDeep()}');
        }
      }
      expect(err, isNull);
      await disposeTestApp(tester);
    });
  });
}
