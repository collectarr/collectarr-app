import 'package:collectarr_app/features/catalog/transport/catalog_item_cache_repository.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/features/library/detail/item_provider.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import '../../../support/builders/catalog_item_builder.dart';
import 'package:collectarr_app/features/library/generic/body.dart';
import 'package:collectarr_app/features/library/workspace/tiles/cover_tile.dart';
import 'package:collectarr_app/features/library/generic/sidebar/compact_bucket_bar.dart';
import 'package:collectarr_app/app/app_shell.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/features/library/detail/location.dart';
import 'package:collectarr_app/features/library/detail/page.dart';
import 'package:collectarr_app/features/library/domain/target_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_entry_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../support/app/provider_overrides.dart';
import '../../../support/app/test_app_harness.dart';
import '../../../support/fixtures/music_fixtures.dart';
import '../../../support/fixtures/test_constants.dart';

void main() {
  test('stable locations distinguish catalog and entry namespaces', () {
    for (final target in <LibraryTargetRef>[
      const CatalogTargetRef(
          CatalogItemRef(kind: CatalogMediaKind.music, id: 'same/id ?')),
      const EntryTargetRef(LibraryEntryRef(
          kind: CatalogMediaKind.music, id: LibraryEntryId('same/id ?'))),
    ]) {
      final uri = LibraryDetailLocation(target).toUri();
      expect(LibraryDetailLocation.fromUri(uri)?.target, target);
      expect(uri.queryParameters.length, 3);
    }
    for (final query in [
      'kind=unknown&target=entry&id=x',
      'kind=music&target=entry',
      'kind=music&target=other&id=x'
    ]) {
      expect(
          LibraryDetailLocation.fromUri(Uri.parse('/detail?$query')), isNull);
    }
  });

  test(
      'cold hydration keeps catalog, wishlist and deleted entry namespaces distinct',
      () async {
    setUpTestAppPreferences();
    final db = LocalDatabase(NativeDatabase.memory());
    final container =
        ProviderContainer(overrides: testAppOverrides(database: db));
    try {
      final entry = musicLibraryEntryFixture(
          id: 'shared-id', metadata: musicAlbumFixture(title: 'Local copy'));
      await MusicEntryRepository(db).upsert(entry);
      await CatalogItemCacheRepository(db).upsert(testCatalogItem(
          id: 'shared-id', kind: 'music', title: 'Cached catalog album'));
      const catalog = CatalogTargetRef(
          CatalogItemRef(kind: CatalogMediaKind.music, id: 'shared-id'));
      const local = EntryTargetRef(LibraryEntryRef(
          kind: CatalogMediaKind.music, id: LibraryEntryId('shared-id')));
      final cached =
          await container.read(restorableDetailItemProvider(catalog).future);
      expect(cached?.source.title, 'Cached catalog album');
      expect(cached?.source.isEntry, isFalse);
      expect(
          (await container.read(restorableDetailItemProvider(local).future))
              ?.source
              .title,
          'Local copy');
      final now = DateTime.utc(2026, 11, 2);
      await WishlistItemsCacheRepository(db).upsert(WishlistItem(
          id: 'wish', catalogRef: catalog.ref, createdAt: now, updatedAt: now));
      container.invalidate(wishlistProvider);
      container.invalidate(shelfProvider);
      expect(
          (await container.read(restorableDetailItemProvider(catalog).future))
              ?.source
              .isWishlisted,
          isTrue);
      await MusicEntryRepository(db).upsert(entry.copyWith(deletedAt: now));
      container.invalidate(collectionSummariesProvider);
      container.invalidate(shelfProvider);
      expect(await container.read(restorableDetailItemProvider(local).future),
          isNull);
      expect(
          (await container.read(restorableDetailItemProvider(catalog).future))
              ?.source
              .title,
          'Cached catalog album');
    } finally {
      container.dispose();
      await db.close();
    }
  });

  for (final width in [390.0, 1024.0]) {
    testWidgets(
        'cold local detail, unavailable target and safe Back at $width dp',
        (tester) async {
      setUpTestAppPreferences();
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = LocalDatabase(NativeDatabase.memory());
      addTearDown(() => tester.runAsync(db.close));
      final entry = musicLibraryEntryFixture(
          metadata: musicAlbumFixture(title: 'Offline local album'));
      await tester.runAsync(() => MusicEntryRepository(db).upsert(entry));
      await tester
          .pumpWidget(testApp(overrides: testAppOverrides(database: db)));
      await pumpUntilSettled(tester);
      final container =
          ProviderScope.containerOf(tester.element(find.byType(AppShell)));
      final router = container.read(appRouterProvider);
      router.go('/libraries?kind=music&q=Offline');
      await pumpUntilSettled(tester);
      final tile = find.byType(LibraryCoverTile).first;
      expect(find.byType(LibraryCompactBucketBar), findsNothing);
      await tester.longPress(tile);
      await pumpUntilSettled(tester);
      expect(
          tester.widget<LibraryBody>(find.byType(LibraryBody)).selectionEnabled,
          isTrue);
      expect(
          router.routeInformationProvider.value.uri.path, AppRoutes.libraries);
      await tester.tap(tile);
      await pumpUntilSettled(tester);
      expect(
          tester.widget<LibraryBody>(find.byType(LibraryBody)).selectionEnabled,
          isFalse);
      await tester.tap(tile);
      await pumpUntilSettled(tester);
      expect(find.byType(LibraryDetailPage), findsOneWidget);
      await tester.binding.handlePopRoute();
      await pumpUntilSettled(tester);
      expect(tester.widget<LibraryBody>(find.byType(LibraryBody)).searchQuery,
          'Offline');
      expect(router.routeInformationProvider.value.uri.queryParameters['q'],
          'Offline');
      final uri = LibraryDetailLocation(EntryTargetRef(
              LibraryEntryRef(kind: CatalogMediaKind.music, id: entry.id)))
          .toUri();
      router.go(uri.toString());
      await pumpUntilSettled(tester);
      expect(find.byType(LibraryDetailPage), findsOneWidget);
      expect(find.text('Offline local album'), findsWidgets);
      expect(find.byKey(const Key('app.mobile-navigation')), findsNothing);
      expect(tester.takeException(), isNull);
      router.go('/detail?kind=music&target=entry&id=removed');
      await pumpUntilSettled(tester);
      expect(find.text('This item was removed or is not available offline.'),
          findsOneWidget);
      await tester.tap(find.byType(BackButton).first);
      await pumpUntilSettled(tester);
      expect(
          router.routeInformationProvider.value.uri.path, AppRoutes.libraries);
      expect(router.routeInformationProvider.value.uri.queryParameters['kind'],
          'music');
      expect(tester.takeException(), isNull);
      await disposeTestApp(tester);
    },
        variant: TargetPlatformVariant(
            {TargetPlatform.android, TargetPlatform.iOS}));
  }
}
