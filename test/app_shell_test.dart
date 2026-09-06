import 'dart:convert';

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/home/home_page.dart';
import 'package:collectarr_app/features/loans/loan_manager_page.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/providers/selected_library_provider.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/features/sync/state/sync_controller.dart';
import 'package:collectarr_app/features/sync/state/sync_state.dart';

import 'package:collectarr_app/ui/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/native.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/secure_storage_mock.dart';
import 'helpers/test_constants.dart';

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

void _setDesktopViewport(WidgetTester tester) {
  tester.view.physicalSize = kDesktopTestSize;
  tester.view.devicePixelRatio = kDesktopTestDPR;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  setUp(setUpSecureStorageMock);

  testWidgets('app shell requests online-first sync once on startup',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'collectarr.auth.token': _jwtExpiringAt(
        DateTime.now().toUtc().add(const Duration(hours: 1)),
      ),
      'collectarr.auth.email': 'test@example.com',
      'collectarr.auth.is_admin': false,
    });
    _setDesktopViewport(tester);

    late _SpySyncController syncController;
    await tester.pumpWidget(
      _shellTestApp(
        overrides: [
          authControllerProvider.overrideWith(
            () => _AuthenticatedAuthController(),
          ),
          syncControllerProvider.overrideWith(
            () => syncController = _SpySyncController(),
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

    await pumpUntilSettled(tester);
    expect(syncController.onlineFirstRequests, 1);

    await tester.pump();
    expect(syncController.onlineFirstRequests, 1);
  });

  testWidgets('app shell keeps bottom nav aligned with the library bar',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'collectarr.auth.token': _jwtExpiringAt(
        DateTime.now().toUtc().add(const Duration(hours: 1)),
      ),
      'collectarr.auth.email': 'test@example.com',
      'collectarr.auth.is_admin': false,
    });
    _setDesktopViewport(tester);

    await tester.pumpWidget(
      _shellTestApp(
        overrides: [
          authControllerProvider.overrideWith(
            () => _AuthenticatedAuthController(),
          ),
          ..._baseShellOverrides(),
        ],
      ),
    );
    await pumpUntilSettled(tester);

    final navBarSize = tester.getSize(find.byType(NavigationBar));
    expect(navBarSize.height, 44.0);

    await tester.tap(find.byTooltip('Hide bottom navigation'));
    await pumpUntilSettled(tester);

    expect(find.byType(NavigationBar), findsNothing);
    final collapsedHandle = find.byTooltip('Show bottom navigation');
    final handleSize = tester.getSize(collapsedHandle);
    expect(handleSize.height, lessThanOrEqualTo(6));
    expect(handleSize.width, 44);
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
    _setDesktopViewport(tester);

    await tester.pumpWidget(
      _shellTestApp(
        overrides: [
          authControllerProvider.overrideWith(
            () => _AuthenticatedAuthController(),
          ),
          selectedLibraryKindProvider
              .overrideWith(() => _FixedLibraryKind('comic')),
          mediaCatalogProvider
              .overrideWith((ref) async => fallbackMediaCatalog),
          syncControllerProvider.overrideWith(
            () => _StaticSyncController(SyncState()),
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
    await pumpUntilSettled(tester);

    final context = tester.element(find.byType(AppShell));
    GoRouter.of(context).go(AppRoutes.shelf);
    await pumpUntilSettled(tester);

    final navigationBar = tester.widget<NavigationBar>(
      find.byType(NavigationBar),
    );
    expect(
      navigationBar.indicatorColor,
      libraryAccentForKind(
        CatalogMediaKind.comic,
      ).withValues(alpha: 0.52),
    );
  });

  testWidgets('app shell shows Manage destination for standard accounts',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'collectarr.auth.token': _jwtExpiringAt(
        DateTime.now().toUtc().add(const Duration(hours: 1)),
      ),
      'collectarr.auth.email': 'test@example.com',
      'collectarr.auth.is_admin': false,
    });
    _setDesktopViewport(tester);

    await tester.pumpWidget(
      _shellTestApp(
        overrides: [
          authControllerProvider.overrideWith(
            () => _AuthenticatedAuthController(),
          ),
          ..._baseShellOverrides(),
        ],
      ),
    );
    await pumpUntilSettled(tester);

    final context = tester.element(find.byType(AppShell));
    GoRouter.of(context).go(AppRoutes.shelf);
    await pumpUntilSettled(tester);

    final navigationBar = tester.widget<NavigationBar>(
      find.byType(NavigationBar),
    );
    // Non-admin users see 5 destinations (Libraries, Shelf, Loans, Calendar, Settings).
    expect(navigationBar.destinations.length, 5);
    expect(find.text('Loans'), findsOneWidget);
    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('Admin'), findsNothing);
  });

  testWidgets('app shell opens the loans tab', (tester) async {
    SharedPreferences.setMockInitialValues({
      'collectarr.auth.token': _jwtExpiringAt(
        DateTime.now().toUtc().add(const Duration(hours: 1)),
      ),
      'collectarr.auth.email': 'test@example.com',
      'collectarr.auth.is_admin': false,
    });
    _setDesktopViewport(tester);
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      _shellTestApp(
        overrides: [
          authControllerProvider.overrideWith(
            () => _AuthenticatedAuthController(),
          ),
          localDatabaseProvider.overrideWithValue(db),
          ..._baseShellOverrides(),
        ],
      ),
    );
    await pumpUntilSettled(tester);

    final context = tester.element(find.byType(AppShell));
    GoRouter.of(context).go(AppRoutes.loans);
    await tester.pump();

    expect(find.byType(LoanManagerPage), findsOneWidget);
  });

  testWidgets(
      'desktop library workspace keeps bottom nav visible and shows workspace switcher',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'collectarr.auth.token': _jwtExpiringAt(
        DateTime.now().toUtc().add(const Duration(hours: 1)),
      ),
      'collectarr.auth.email': 'test@example.com',
      'collectarr.auth.is_admin': false,
    });
    _setDesktopViewport(tester);

    await tester.pumpWidget(
      _shellTestApp(
        overrides: [
          authControllerProvider.overrideWith(
            () => _AuthenticatedAuthController(),
          ),
          ..._baseShellOverrides(),
        ],
      ),
    );
    await pumpUntilSettled(tester);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(AppShell), findsOneWidget);
    expect(find.byKey(const ValueKey('library-kind-comic')), findsWidgets);
  });

  testWidgets('app shell shows admin destination for admin accounts',
      (tester) async {
    final token = _jwtExpiringAt(
      DateTime.now().toUtc().add(const Duration(hours: 1)),
    );
    setSecureStorageValue('collectarr.auth.token', token);
    SharedPreferences.setMockInitialValues({
      'collectarr.auth.email': 'admin@example.com',
      'collectarr.auth.is_admin': true,
    });
    _setDesktopViewport(tester);

    await tester.pumpWidget(
      _shellTestApp(
        overrides: [
          authControllerProvider.overrideWith(
            () => _AuthenticatedAuthController(),
          ),
          ..._baseShellOverrides(),
        ],
      ),
    );
    await pumpUntilSettled(tester);

    final context = tester.element(find.byType(AppShell));
    GoRouter.of(context).go(AppRoutes.shelf);
    await pumpUntilSettled(tester);

    final navigationBar = tester.widget<NavigationBar>(
      find.byType(NavigationBar),
    );
    // Admin accounts see 6 destinations with 'Admin' label
    // (Libraries, Shelf, Loans, Calendar, Admin, Settings).
    expect(navigationBar.destinations.length, 6);
    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('Manage'), findsNothing);
  });

  testWidgets('detail route without request payload redirects to libraries',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'collectarr.auth.token': _jwtExpiringAt(
        DateTime.now().toUtc().add(const Duration(hours: 1)),
      ),
      'collectarr.auth.email': 'test@example.com',
      'collectarr.auth.is_admin': false,
    });
    _setDesktopViewport(tester);

    await tester.pumpWidget(
      _shellTestApp(
        overrides: [
          authControllerProvider.overrideWith(
            () => _AuthenticatedAuthController(),
          ),
          ..._baseShellOverrides(),
        ],
      ),
    );
    await pumpUntilSettled(tester);

    final context = tester.element(find.byType(AppShell));
    GoRouter.of(context).go(AppRoutes.detail);
    await pumpUntilSettled(tester);

    expect(find.byType(LibraryHomePage), findsOneWidget);
    expect(find.byType(AppShell), findsOneWidget);
  });

  testWidgets('app shell adapts navigation on mobile viewport (< 480 dp width)',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'collectarr.auth.token': _jwtExpiringAt(
        DateTime.now().toUtc().add(const Duration(hours: 1)),
      ),
      'collectarr.auth.email': 'test@example.com',
      'collectarr.auth.is_admin': false,
    });
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _shellTestApp(
        overrides: [
          authControllerProvider.overrideWith(
            () => _AuthenticatedAuthController(),
          ),
          ..._baseShellOverrides(),
        ],
      ),
    );
    await pumpUntilSettled(tester);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(AppShell), findsOneWidget);
  });
}

List<Override> _baseShellOverrides() {
  return [
    syncControllerProvider.overrideWith(
      () => _StaticSyncController(SyncState()),
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
  _StaticSyncController(this.initial);

  final SyncState initial;

  @override
  SyncState build() => initial;

  @override
  Future<void> refreshPendingCount() async {}

  @override
  Future<void> syncNow() async {}
}

class _SpySyncController extends _StaticSyncController {
  _SpySyncController() : super(SyncState());

  int onlineFirstRequests = 0;

  @override
  Future<void> syncOnlineFirstIfEnabled() async {
    onlineFirstRequests += 1;
  }
}

/// Auth controller that restores a valid JWT from the mocked secure storage.
class _AuthenticatedAuthController extends AuthController {
  _AuthenticatedAuthController();
}

class _FixedLibraryKind extends SelectedLibraryKind {
  _FixedLibraryKind(this._kind);
  final String _kind;

  @override
  String build() => _kind;
}
