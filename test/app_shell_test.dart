import 'dart:convert';

import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/providers/selected_library_provider.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/state/sync_provider.dart';
import 'package:collectarr_app/ui/app_shell.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Builds a [MaterialApp.router] backed by the real [appRouterProvider] so the
/// [AppShell] receives a proper [StatefulNavigationShell].
Widget _shellTestApp({List<Override> overrides = const []}) {
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

void main() {
  testWidgets('app shell requests online-first sync once on startup',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'collectarr.auth.token': _jwtExpiringAt(
        DateTime.now().toUtc().add(const Duration(hours: 1)),
      ),
      'collectarr.auth.email': 'test@example.com',
      'collectarr.auth.is_admin': false,
    });
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    late _SpySyncController syncController;
    await tester.pumpWidget(
      _shellTestApp(
        overrides: [
          authControllerProvider.overrideWith(
            (ref) => _AuthenticatedAuthController(ref),
          ),
          syncControllerProvider.overrideWith(
            (ref) => syncController = _SpySyncController(ref),
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
          wishlistProvider.overrideWith((ref) async => const []),
          wishlistIdsProvider.overrideWith((ref) async => const <String>{}),
        ],
      ),
    );

    await tester.pumpAndSettle();
    expect(syncController.onlineFirstRequests, 1);

    await tester.pump();
    expect(syncController.onlineFirstRequests, 1);
  });

  testWidgets('app shell tints bottom navigation with active library color',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'collectarr.auth.token': _jwtExpiringAt(
        DateTime.now().toUtc().add(const Duration(hours: 1)),
      ),
      'collectarr.auth.email': 'test@example.com',
      'collectarr.auth.is_admin': false,
    });
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _shellTestApp(
        overrides: [
          authControllerProvider.overrideWith(
            (ref) => _AuthenticatedAuthController(ref),
          ),
          selectedLibraryKindProvider.overrideWith((ref) => 'manga'),
          mediaCatalogProvider
              .overrideWith((ref) async => fallbackMediaCatalog),
          syncControllerProvider.overrideWith(
            (ref) => _StaticSyncController(ref, const SyncState()),
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
          wishlistProvider.overrideWith((ref) async => const []),
          wishlistIdsProvider.overrideWith((ref) async => const <String>{}),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final navigationBar = tester.widget<NavigationBar>(
      find.byType(NavigationBar),
    );
    expect(
      navigationBar.indicatorColor,
      libraryAccentForKind('manga').withValues(alpha: 0.52),
    );
  });

  testWidgets('app shell hides admin destination for standard accounts',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'collectarr.auth.token': _jwtExpiringAt(
        DateTime.now().toUtc().add(const Duration(hours: 1)),
      ),
      'collectarr.auth.email': 'test@example.com',
      'collectarr.auth.is_admin': false,
    });
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _shellTestApp(
        overrides: [
          authControllerProvider.overrideWith(
            (ref) => _AuthenticatedAuthController(ref),
          ),
          ..._baseShellOverrides(),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final navigationBar = tester.widget<NavigationBar>(
      find.byType(NavigationBar),
    );
    expect(navigationBar.destinations.length, 3);
    expect(find.text('Admin'), findsNothing);
  });

  testWidgets('app shell shows admin destination for admin accounts',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'collectarr.auth.token': _jwtExpiringAt(
        DateTime.now().toUtc().add(const Duration(hours: 1)),
      ),
      'collectarr.auth.email': 'admin@example.com',
      'collectarr.auth.is_admin': true,
    });
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _shellTestApp(
        overrides: [
          authControllerProvider.overrideWith(
            (ref) => _AuthenticatedAuthController(ref),
          ),
          ..._baseShellOverrides(),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final navigationBar = tester.widget<NavigationBar>(
      find.byType(NavigationBar),
    );
    expect(navigationBar.destinations.length, 4);
    expect(find.text('Admin'), findsOneWidget);
  });
}

List<Override> _baseShellOverrides() {
  return [
    syncControllerProvider.overrideWith(
      (ref) => _StaticSyncController(ref, const SyncState()),
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
    wishlistProvider.overrideWith((ref) async => const []),
    wishlistIdsProvider.overrideWith((ref) async => const <String>{}),
  ];
}

String _jwtExpiringAt(DateTime expiresAt) {
  final encodedHeader = _base64UrlJson({'alg': 'none', 'typ': 'JWT'});
  final encodedPayload = _base64UrlJson({
    'sub': '00000000-0000-0000-0000-000000000001',
    'exp': expiresAt.millisecondsSinceEpoch ~/ 1000,
  });
  return '$encodedHeader.$encodedPayload.signature';
}

String _base64UrlJson(Map<String, Object> value) {
  return base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
}

class _StaticSyncController extends SyncController {
  _StaticSyncController(super.ref, SyncState initial) {
    state = initial;
  }

  @override
  Future<void> refreshPendingCount() async {}

  @override
  Future<void> syncNow() async {}
}

class _SpySyncController extends _StaticSyncController {
  _SpySyncController(Ref ref) : super(ref, const SyncState());

  int onlineFirstRequests = 0;

  @override
  Future<void> syncOnlineFirstIfEnabled() async {
    onlineFirstRequests += 1;
  }
}

/// Auth controller that relies on [SharedPreferences.setMockInitialValues]
/// being called with a valid JWT before construction.  The parent's private
/// [_restoreSession] reads the mocked prefs and transitions to authenticated.
class _AuthenticatedAuthController extends AuthController {
  _AuthenticatedAuthController(super.ref);
}
