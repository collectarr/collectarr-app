import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/shelf_controller.dart';
import 'package:collectarr_app/state/sync_provider.dart';
import 'package:collectarr_app/ui/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    expect(find.text('2'), findsOneWidget);
  });
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
