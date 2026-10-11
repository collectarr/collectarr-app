/// Desktop and mobile smoke tests for navigation and mandatory destination keys.
library;

import 'dart:convert';

import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/features/sync/state/sync_controller.dart';
import 'package:collectarr_app/app/app_shell.dart';
import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/home/home_page.dart';
import 'package:collectarr_app/ui/app_page_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/secure_storage_mock.dart';
import '../helpers/test_constants.dart';

// ---------------------------------------------------------------------------
// Fake auth / sync helpers
// ---------------------------------------------------------------------------

String _jwtExpiringAt(DateTime exp) {
  final header = base64Url.encode(utf8.encode('{"alg":"HS256","typ":"JWT"}'));
  final payload = base64Url.encode(
    utf8.encode(
        '{"sub":"test","email":"test@example.com","exp":${exp.millisecondsSinceEpoch ~/ 1000}}'),
  );
  return '$header.$payload.fake_signature';
}

class _AuthenticatedAuthController extends AuthController {
  _AuthenticatedAuthController();
}

class _NoOpSyncController extends SyncController {
  _NoOpSyncController();

  @override
  Future<void> syncOnlineFirstIfEnabled() async {}
}

// ---------------------------------------------------------------------------
// Test app builder
// ---------------------------------------------------------------------------

Widget _smokeApp({List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: Consumer(
      builder: (context, ref, _) {
        final router = ref.watch(appRouterProvider);
        return MaterialApp.router(routerConfig: router);
      },
    ),
  );
}

List<Override> _testOverrides() {
  return [
    authControllerProvider.overrideWith(
      () => _AuthenticatedAuthController(),
    ),
    syncControllerProvider.overrideWith(
      () => _NoOpSyncController(),
    ),
    shelfProvider.overrideWith(
      (ref) async => const ShelfState(
        entries: [],
        entryCount: 0,
        wishlistCount: 0,
        pricedCount: 0,
        totalPaidCents: null,
        primaryCurrency: null,
        hasMixedCurrencies: false,
      ),
    ),
    collectionProvider.overrideWith((ref) async => const []),
    mediaCatalogProvider.overrideWith(
      (ref) async => fallbackMediaCatalog,
    ),
  ];
}

void _mockAuthPreferences() {
  SharedPreferences.setMockInitialValues({
    'collectarr.auth.token': _jwtExpiringAt(
      DateTime.now().toUtc().add(const Duration(hours: 1)),
    ),
    'collectarr.auth.email': 'test@example.com',
    'collectarr.auth.is_admin': true,
  });
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(setUpSecureStorageMock);

  group('App Mandatory Destination Smoke Tests', () {
    testWidgets(
        'direct Music settings route retains kind when returning to library',
        (tester) async {
      _mockAuthPreferences();
      tester.view.physicalSize = kDesktopTestSize;
      tester.view.devicePixelRatio = kDesktopTestDPR;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_smokeApp(overrides: _testOverrides()));
      await pumpUntilSettled(tester);
      final container =
          ProviderScope.containerOf(tester.element(find.byType(AppShell)));
      final router = container.read(appRouterProvider);
      router.go('/settings?kind=music');
      await pumpUntilSettled(tester);
      expect(find.text('COLLECTARR MUSIC'), findsOneWidget);
      await tester.tap(find.byKey(const Key('settings.back')));
      await pumpUntilSettled(tester);
      expect(
          router.routeInformationProvider.value.uri.path, AppRoutes.libraries);
      expect(router.routeInformationProvider.value.uri.queryParameters['kind'],
          'music');
      expect(find.text('COLLECTARR MUSIC'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'Music header persists on pushed tools and Core add returns to library',
        (tester) async {
      _mockAuthPreferences();
      tester.view.physicalSize = kDesktopTestSize;
      tester.view.devicePixelRatio = kDesktopTestDPR;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_smokeApp(overrides: _testOverrides()));
      await pumpUntilSettled(tester);
      final container =
          ProviderScope.containerOf(tester.element(find.byType(AppShell)));
      final router = container.read(appRouterProvider);
      router.go('/libraries?kind=music');
      await pumpUntilSettled(tester);
      expect(find.text('COLLECTARR MUSIC'), findsOneWidget);
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

      await tester.tap(find.byKey(const Key('nav.settings')));
      await pumpUntilSettled(tester);
      expect(find.text('COLLECTARR MUSIC'), findsOneWidget);
      expect(find.byType(AppPageHeader), findsOneWidget);
      await tester.tap(find.byKey(const Key('app.open-navigation')));
      await pumpUntilSettled(tester);
      await tester.tap(find.text('Print to PDF'));
      await pumpUntilSettled(tester);
      expect(find.text('COLLECTARR MUSIC'), findsOneWidget);
      expect(find.byKey(const Key('nav.library-kind-picker')), findsOneWidget);
      expect(find.byKey(const Key('nav.settings')), findsOneWidget);
      expect(find.byType(AppPageHeader), findsOneWidget);
      await tester.tap(find.byKey(const Key('app.open-navigation')));
      await pumpUntilSettled(tester);
      expect(
          tester
              .widget<AppNavigationDrawer>(find.byType(AppNavigationDrawer))
              .selectedAction,
          DrawerAction.printToPdf);
      expect(tester.widget<Text>(find.text('Libraries')).style?.fontWeight,
          FontWeight.w500);
      expect(
          tester
              .widget<Text>(find.descendant(
                  of: find.byType(AppNavigationDrawer),
                  matching: find.text('Print to PDF')))
              .style
              ?.fontWeight,
          FontWeight.w700);
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
          DrawerAction.libraries);
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
      expect(find.text('COLLECTARR MUSIC'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'desktop smoke: can navigate through all mandatory destinations',
        (tester) async {
      _mockAuthPreferences();

      tester.view.physicalSize = kDesktopTestSize;
      tester.view.devicePixelRatio = kDesktopTestDPR;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _smokeApp(overrides: _testOverrides()),
      );
      await pumpUntilSettled(tester);

      expect(find.byType(AppShell), findsOneWidget);
      expect(find.byKey(const Key('app.open-navigation')), findsOneWidget);
      expect(find.byKey(const Key('app.kind-icon')), findsOneWidget);
      expect(find.byKey(const Key('nav.settings')), findsOneWidget);

      Future<void> openDrawer() async {
        await tester.tap(find.byKey(const Key('app.open-navigation')));
        await pumpUntilSettled(tester);
      }

      await openDrawer();
      expect(find.byKey(const Key('nav.library')), findsOneWidget);
      expect(find.byKey(const Key('nav.shelf')), findsNothing);
      expect(find.text('My Shelf'), findsNothing);
      expect(find.byKey(const Key('nav.more')), findsOneWidget);
      expect(find.byKey(const Key('nav.calendar')), findsOneWidget);

      // Navigate to the library
      await tester.tap(find.byKey(const Key('nav.library')));
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
      await tester.tap(find.byKey(const Key('nav.settings')));
      await pumpUntilSettled(tester);
      expect(find.byType(AppShell), findsOneWidget);

      // Navigate back to Libraries
      await tester.tap(find.byKey(const Key('settings.back')));
      await pumpUntilSettled(tester);
      expect(find.byType(AppShell), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'mobile phone smoke (390x844): navigates shell, settings, and back without overflow',
        (tester) async {
      _mockAuthPreferences();

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
        _smokeApp(overrides: _testOverrides()),
      );
      await pumpUntilSettled(tester);

      expect(find.byType(AppShell), findsOneWidget);
      expect(find.byKey(const Key('app.open-navigation')), findsOneWidget);
      expect(find.byKey(const Key('nav.settings')), findsOneWidget);

      // Mandatory keys must be present in drawer on mobile
      await tester.tap(find.byKey(const Key('app.open-navigation')));
      await pumpUntilSettled(tester);
      expect(find.byKey(const Key('nav.library')), findsOneWidget);
      expect(find.byKey(const Key('nav.shelf')), findsNothing);
      expect(find.text('My Shelf'), findsNothing);

      // Navigate to the library via drawer
      await tester.tap(find.byKey(const Key('nav.library')));
      await pumpUntilSettled(tester);
      expect(find.byType(AppShell), findsOneWidget);

      // Navigate to Settings
      await tester.tap(find.byKey(const Key('nav.settings')));
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
    });
  });
}
