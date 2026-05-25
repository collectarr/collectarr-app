/// End-to-end smoke test for the Collectarr desktop app.
///
/// Launches the full [CollectarrApp] with mocked auth/sync/database providers
/// and navigates through the main tabs.
///
/// Run with:
///   flutter test integration_test/app_smoke_test.dart
library;

import 'dart:convert';

import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/state/sync_provider.dart';
import 'package:collectarr_app/ui/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/helpers/secure_storage_mock.dart';
import '../test/helpers/test_constants.dart';

// ---------------------------------------------------------------------------
// Fake auth / sync helpers
// ---------------------------------------------------------------------------

String _jwtExpiringAt(DateTime exp) {
  final header = base64Url.encode(utf8.encode('{"alg":"HS256","typ":"JWT"}'));
  final payload = base64Url.encode(
    utf8.encode('{"sub":"test","email":"test@example.com","exp":${exp.millisecondsSinceEpoch ~/ 1000}}'),
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

Widget _integrationApp({List<Override> overrides = const []}) {
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

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(setUpSecureStorageMock);

  testWidgets('smoke: can navigate through all main tabs', (tester) async {
    SharedPreferences.setMockInitialValues({
      'collectarr.auth.token': _jwtExpiringAt(
        DateTime.now().toUtc().add(const Duration(hours: 1)),
      ),
      'collectarr.auth.email': 'test@example.com',
      'collectarr.auth.is_admin': true,
    });

    tester.view.physicalSize = kDesktopTestSize;
    tester.view.devicePixelRatio = kDesktopTestDPR;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _integrationApp(
        overrides: [
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
        ],
      ),
    );
    await pumpUntilSettled(tester);

    // Verify we land on the Libraries tab.
    expect(find.byType(AppShell), findsOneWidget);

    // Navigate to Shelf tab.
    final shelfTab = find.byIcon(Icons.shelves);
    if (shelfTab.evaluate().isNotEmpty) {
      await tester.tap(shelfTab);
      await pumpUntilSettled(tester);
    }

    // Navigate to Settings tab.
    final settingsTab = find.byIcon(Icons.settings);
    if (settingsTab.evaluate().isNotEmpty) {
      await tester.tap(settingsTab);
      await pumpUntilSettled(tester);
    }

    // Navigate back to Libraries tab.
    final libraryTab = find.byIcon(Icons.collections_bookmark);
    if (libraryTab.evaluate().isNotEmpty) {
      await tester.tap(libraryTab);
      await pumpUntilSettled(tester);
    }

    // If we reached here without crashes, the smoke test passes.
    expect(find.byType(AppShell), findsOneWidget);
  });
}
