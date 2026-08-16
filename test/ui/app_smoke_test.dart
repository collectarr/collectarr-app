/// Desktop and mobile smoke tests for navigation and mandatory destination keys.
library;

import 'dart:convert';

import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/features/sync/state/sync_controller.dart';
import 'package:collectarr_app/ui/app_shell.dart';
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
  _AuthenticatedAuthController(super.ref);
}

class _NoOpSyncController extends SyncController {
  _NoOpSyncController(super.ref);

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
      (ref) => _AuthenticatedAuthController(ref),
    ),
    syncControllerProvider.overrideWith(
      (ref) => _NoOpSyncController(ref),
    ),
    shelfProvider.overrideWith(
      (ref) async => const ShelfState(
        entries: [],
        ownedCount: 0,
        wishlistCount: 0,
        missingGradeCount: 0,
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

      // Verify all mandatory destination keys exist
      expect(find.byKey(const Key('nav.library')), findsOneWidget);
      expect(find.byKey(const Key('nav.shelf')), findsOneWidget);
      expect(find.byKey(const Key('nav.more')), findsOneWidget);
      expect(find.byKey(const Key('nav.calendar')), findsOneWidget);
      expect(find.byKey(const Key('nav.settings')), findsOneWidget);

      // Navigate to Shelf
      await tester.tap(find.byKey(const Key('nav.shelf')));
      await pumpUntilSettled(tester);
      expect(find.byType(AppShell), findsOneWidget);

      // Navigate to Loans / More
      await tester.tap(find.byKey(const Key('nav.more')));
      await pumpUntilSettled(tester);
      expect(find.byType(AppShell), findsOneWidget);

      // Navigate to Calendar
      await tester.tap(find.byKey(const Key('nav.calendar')));
      await pumpUntilSettled(tester);
      expect(find.byType(AppShell), findsOneWidget);

      // Navigate to Settings
      await tester.tap(find.byKey(const Key('nav.settings')));
      await pumpUntilSettled(tester);
      expect(find.byType(AppShell), findsOneWidget);

      // Navigate back to Libraries
      await tester.tap(find.byKey(const Key('nav.library')));
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

      // Mandatory keys must be present on mobile
      expect(find.byKey(const Key('nav.library')), findsOneWidget);
      expect(find.byKey(const Key('nav.shelf')), findsOneWidget);
      expect(find.byKey(const Key('nav.settings')), findsOneWidget);

      // Navigate to Settings
      await tester.tap(find.byKey(const Key('nav.settings')));
      await pumpUntilSettled(tester);
      expect(find.byType(AppShell), findsOneWidget);

      // Navigate back to Libraries
      await tester.tap(find.byKey(const Key('nav.library')));
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
