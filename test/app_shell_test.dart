import 'dart:convert';

import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/providers/selected_library_provider.dart';
import 'package:collectarr_app/state/sync_provider.dart';
import 'package:collectarr_app/ui/app_shell.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app shell exposes sync status in the floating action button',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          syncControllerProvider.overrideWith(
            (ref) => _StaticSyncController(
              ref,
              const SyncState(pendingCount: 3),
            ),
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
        child: const MaterialApp(home: AppShell()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byTooltip('Sync personal data - 3 pending, never synced'),
      findsOneWidget,
    );
    expect(find.text('3'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(FloatingActionButton),
        matching: find.byIcon(Icons.sync),
      ),
      findsOneWidget,
    );
  });

  testWidgets('app shell shows offline sync state', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          syncControllerProvider.overrideWith(
            (ref) => _StaticSyncController(
              ref,
              const SyncState(
                pendingCount: 2,
                isOffline: true,
                errorMessage: 'sync unavailable',
              ),
            ),
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
        child: const MaterialApp(home: AppShell()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('sync unavailable'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(FloatingActionButton),
        matching: find.byIcon(Icons.cloud_off),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(FloatingActionButton),
        matching: find.text('2'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('app shell tints bottom navigation with active library color',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
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
        child: const MaterialApp(home: AppShell()),
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

  testWidgets('sync action keeps white foreground on bright library accents',
      (tester) async {
    for (final kind in ['comic', 'manga', 'boardgame', 'movie']) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: LibraryAwareSyncButton(
              sync: const SyncState(),
              accent: libraryAccentForKind(kind),
              animationsEnabled: false,
              tooltip: 'Sync',
              onPressed: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      final button = tester.widget<FloatingActionButton>(
        find.byType(FloatingActionButton),
      );
      final background = button.backgroundColor;
      expect(button.foregroundColor, Colors.white);
      expect(background, libraryAccentActionColor(libraryAccentForKind(kind)));
      expect(_contrastWithWhite(background!), greaterThanOrEqualTo(4.5));
    }
  });

  testWidgets('app shell hides admin destination for standard accounts',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: _baseShellOverrides(),
        child: const MaterialApp(home: AppShell()),
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
      ProviderScope(
        overrides: _baseShellOverrides(),
        child: const MaterialApp(home: AppShell()),
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

double _contrastWithWhite(Color color) {
  return 1.05 / (color.computeLuminance() + 0.05);
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
