import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/collections/library_collection_repository.dart';
import 'package:collectarr_app/features/library/generic/page/generic_library_page.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/view_preference_store.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/data.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../support/builders/library_entry_builder.dart';
import '../../../../support/builders/workspace_item_builder.dart';

void main() {
  testWidgets(
      'restored quick filter is visible and clearing restores all albums permanently',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    LibraryViewPreferenceStore.resetCachedPreferencesForTesting();
    const preferences = LibraryViewPreferenceStore(CatalogMediaKind.music);
    await preferences.writeQuickView(LibraryQuickView.missingCovers);
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final shelf = ShelfState(
      entries: [
        for (var i = 0; i < 3; i++)
          testLibraryWorkspaceSource(
            itemId: 'album-$i',
            kind: 'music',
            title: 'Album $i',
            libraryEntrySummary: testLibraryEntrySummary(testLibraryEntry(
              id: 'entry-$i',
              itemId: 'album-$i',
              kind: 'music',
              catalogTitle: 'Album $i',
            )),
            catalogData: MusicWorkspaceData.fromMusic(MusicAlbum(
              id: CatalogItemRef(kind: CatalogMediaKind.music, id: 'album-$i'),
              title: 'Album $i',
              artist: 'Artist',
              coverImageUrl:
                  i == 0 ? null : 'https://example.invalid/cover-$i.png',
            )),
          ),
      ],
      entryCount: 3,
      wishlistCount: 0,
      pricedCount: 0,
      totalPaidCents: null,
      primaryCurrency: null,
      hasMixedCurrencies: false,
    );
    final container = ProviderContainer(overrides: [
      localDatabaseProvider.overrideWithValue(db),
      shelfProvider.overrideWith((ref) async => shelf),
      libraryCollectionsProvider('music').overrideWith((ref) => Stream.value([
            const LibraryCollectionSummary(
                id: 'main',
                kind: 'music',
                name: 'Main',
                position: 0,
                isActive: true,
                entryIds: {'entry-0', 'entry-1', 'entry-2'}),
          ])),
    ]);
    await container.read(shelfProvider.future);
    Future<void> mount() async {
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
            home: GenericLibraryPage(
          type: const MusicRegistration(),
          routeUri: Uri(path: '/'),
          topBar: const SizedBox.shrink(),
          accent: Colors.orange,
        )),
      ));
      await tester.pumpAndSettle(const Duration(milliseconds: 100),
          EnginePhase.sendSemanticsUpdate, const Duration(seconds: 3));
    }

    await mount();
    expect(find.text('1 of 3 albums'), findsOneWidget);
    expect(find.text('Missing covers'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Clear filters'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate, const Duration(seconds: 3));
    expect(find.text('1 of 3 albums'), findsNothing);
    expect(find.text('3 albums'), findsOneWidget);
    expect(await preferences.readQuickView(), isNull);
    expect(preferences.cachedQuickView, isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await mount();
    expect(find.text('3 albums'), findsOneWidget);
    expect(find.text('Missing covers'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    await tester.pump(const Duration(milliseconds: 100));
    LibraryViewPreferenceStore.resetCachedPreferencesForTesting();
  });
}
