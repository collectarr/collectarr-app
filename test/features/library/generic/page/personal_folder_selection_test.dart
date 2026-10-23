import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/page/generic_library_page.dart';
import 'package:collectarr_app/features/library/generic/view_preference_store.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final kind in [
    CatalogMediaKind.game,
    CatalogMediaKind.gameHardware,
    CatalogMediaKind.gameToy
  ]) {
    testWidgets(
        '${kind.apiValue} retains a personal folder selected through the page menu',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      LibraryViewPreferenceStore.resetCachedPreferencesForTesting();
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = LocalDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      const shelf = ShelfState(
          entries: [],
          entryCount: 0,
          wishlistCount: 0,
          pricedCount: 0,
          totalPaidCents: null,
          primaryCurrency: null,
          hasMixedCurrencies: false);
      final container = ProviderContainer(overrides: [
        localDatabaseProvider.overrideWithValue(db),
        shelfProvider.overrideWith((ref) async => shelf)
      ]);
      await container.read(shelfProvider.future);
      Future<void> mount() async {
        await tester.pumpWidget(UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
                home: GenericLibraryPage(
                    type: defaultLibraryKindRegistry.require(kind),
                    routeUri: Uri(path: '/'),
                    topBar: const SizedBox.shrink(),
                    accent: Colors.red))));
        await tester.pumpAndSettle();
      }

      await mount();
      await tester.tap(find.byTooltip('Group By'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Purchase Date'));
      await tester.tap(find.text('Purchase Date'));
      await tester.pumpAndSettle();
      expect(find.text('Purchase Date'), findsOneWidget);
      final preferences = LibraryViewPreferenceStore(kind);
      expect((await preferences.readFolderPreset())?.primaryMode,
          '${kind.apiValue}.purchase_date');
      await tester.pumpWidget(const SizedBox.shrink());
      await mount();
      expect(find.text('Purchase Date'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      await tester.pump(const Duration(milliseconds: 100));
      LibraryViewPreferenceStore.resetCachedPreferencesForTesting();
    });
  }
}
