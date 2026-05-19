import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/home/library_home_page.dart';
import 'package:collectarr_app/features/library/media_catalog_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('non-comic libraries use the generic workspace', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1220, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime.utc(2026, 5, 15);
    const game = CatalogItem(
      id: 'game-1',
      kind: 'game',
      title: 'Hades',
      publisher: 'Supergiant Games',
      releaseYear: 2020,
      barcode: '123456789012',
    );
    final shelf = ShelfState.from(
      ownedItems: [
        OwnedItem(
          id: 'owned-1',
          itemId: game.id,
          condition: 'New',
          pricePaidCents: 2499,
          currency: 'USD',
          updatedAt: now,
        ),
      ],
      wishlistItems: const [],
      catalogItems: {game.id: game},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mediaCatalogProvider
              .overrideWith((ref) async => fallbackMediaCatalog),
          shelfProvider.overrideWith((ref) async => shelf),
          collectionProvider.overrideWith((ref) async => const []),
          wishlistProvider.overrideWith((ref) async => const []),
          wishlistIdsProvider.overrideWith((ref) async => const <String>{}),
        ],
        child: const MaterialApp(home: LibraryHomePage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Games'));
    await tester.pumpAndSettle();

    expect(find.text('Add Games'), findsOneWidget);
    expect(find.text('Owned'), findsWidgets);
    expect(find.text('Wishlist'), findsWidgets);
    expect(find.text('Hades'), findsWidgets);
    expect(find.text('Supergiant Games'), findsWidgets);
    expect(find.byTooltip('Open details'), findsOneWidget);
    expect(find.text('Metadata'), findsWidgets);
    expect(find.text('Missing cover'), findsOneWidget);
    expect(find.text('USD 24.99'), findsWidgets);
    expect(find.text('No game selected'), findsNothing);
    expect(find.byTooltip('Library tools'), findsOneWidget);
    expect(find.byTooltip('Group by'), findsOneWidget);
    expect(find.byTooltip('Clear group filter'), findsOneWidget);

    await tester.tap(find.byTooltip('Group by'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Year'));
    await tester.pumpAndSettle();

    expect(find.text('Years'), findsOneWidget);

    await tester.tap(find.byTooltip('Library tools'));
    await tester.pumpAndSettle();

    expect(find.text('Quick views'), findsOneWidget);
    expect(find.text('Statistics'), findsOneWidget);

    await tester.tap(find.widgetWithText(ListTile, 'Statistics'));
    await tester.pumpAndSettle();

    expect(find.text('Games statistics'), findsOneWidget);
    expect(find.text('Shown 1'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Library tools'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Wishlist'));
    await tester.pumpAndSettle();

    expect(find.text('No matching games'), findsOneWidget);
    expect(find.text('Hades'), findsNothing);
    await tester.tap(find.text('Clear filter'));
    await tester.pumpAndSettle();
    expect(find.text('Hades'), findsWidgets);

    await tester.tap(find.byTooltip('Open details'));
    await tester.pumpAndSettle();

    expect(find.text('Catalog metadata'), findsOneWidget);
    expect(find.text('Cover status'), findsOneWidget);
    expect(find.text('Local collection'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Providers'), 400);
    expect(find.text('Providers'), findsOneWidget);
    await tester.drag(find.byType(ListView).last, const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Local snapshot'), findsWidgets);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Refresh metadata'));
    await tester.pumpAndSettle();

    expect(find.text('Refresh games metadata'), findsOneWidget);
    expect(find.text('Source: Collectarr Core search'), findsOneWidget);
    expect(find.text('Hades'), findsWidgets);
  });

  testWidgets('generic library workspace exposes compact buckets',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(620, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime.utc(2026, 5, 15);
    const game = CatalogItem(
      id: 'game-1',
      kind: 'game',
      title: 'Hades',
      publisher: 'Supergiant Games',
      releaseYear: 2020,
    );
    final shelf = ShelfState.from(
      ownedItems: [
        OwnedItem(id: 'owned-1', itemId: game.id, updatedAt: now),
      ],
      wishlistItems: const [],
      catalogItems: {game.id: game},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mediaCatalogProvider
              .overrideWith((ref) async => fallbackMediaCatalog),
          shelfProvider.overrideWith((ref) async => shelf),
          collectionProvider.overrideWith((ref) async => const []),
          wishlistProvider.overrideWith((ref) async => const []),
          wishlistIdsProvider.overrideWith((ref) async => const <String>{}),
        ],
        child: const MaterialApp(home: LibraryHomePage()),
      ),
    );
    await tester.pumpAndSettle();

    final overflowButton = tester.widget<PopupMenuButton<CatalogMediaType>>(
      find.byType(PopupMenuButton<CatalogMediaType>),
    );
    expect(overflowButton.color, const Color(0xFF202020));
    expect(overflowButton.surfaceTintColor, Colors.transparent);
    expect(overflowButton.position, PopupMenuPosition.under);

    await tester.tap(find.byTooltip('More libraries'));
    await tester.pumpAndSettle();
    final gameItem = tester.widget<PopupMenuItem<CatalogMediaType>>(
      find.byKey(const ValueKey('library-overflow-item-game')),
    );
    expect(gameItem.height, 38);
    await tester.tap(find.text('Games'));
    await tester.pumpAndSettle();

    expect(find.text('[All Games] 1'), findsOneWidget);
    expect(find.text('Supergiant Games 1'), findsOneWidget);
    expect(find.text('Hades'), findsWidgets);
  });

  testWidgets('catalog-defined libraries use generic workspace controls',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1220, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const podcastType = CatalogMediaType(
      kind: 'podcast',
      singularLabel: 'Podcast',
      pluralLabel: 'Podcasts',
      routeSegments: ['podcasts'],
      defaultProvider: 'podindex',
      providers: ['podindex'],
    );
    final now = DateTime.utc(2026, 5, 15);
    const podcast = CatalogItem(
      id: 'podcast-1',
      kind: 'podcast',
      title: 'The Library Feed',
      publisher: 'Collectarr Studio',
      releaseYear: 2026,
    );
    final shelf = ShelfState.from(
      ownedItems: [
        OwnedItem(id: 'owned-podcast-1', itemId: podcast.id, updatedAt: now),
      ],
      wishlistItems: const [],
      catalogItems: {podcast.id: podcast},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mediaCatalogProvider.overrideWith(
            (ref) async => [...fallbackMediaCatalog, podcastType],
          ),
          shelfProvider.overrideWith((ref) async => shelf),
          collectionProvider.overrideWith((ref) async => const []),
          wishlistProvider.overrideWith((ref) async => const []),
          wishlistIdsProvider.overrideWith((ref) async => const <String>{}),
        ],
        child: const MaterialApp(home: LibraryHomePage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('More libraries'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Podcasts'));
    await tester.pumpAndSettle();

    expect(find.text('Add Podcasts'), findsOneWidget);
    expect(find.byTooltip('Scan barcode'), findsOneWidget);
    expect(find.byTooltip('Refresh metadata'), findsOneWidget);
    expect(find.byTooltip('Library tools'), findsOneWidget);
    expect(find.text('Search podcasts...'), findsOneWidget);
    expect(find.text('[All Podcasts]'), findsOneWidget);
    expect(find.text('The Library Feed'), findsWidgets);
    expect(find.text('Collectarr Studio'), findsWidgets);
    expect(find.text('No podcast selected'), findsNothing);
  });

  testWidgets('library navigation preferences hide comics and use left rail',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'collectarr.library_nav.order': ['game', 'comic', 'manga'],
      'collectarr.library_nav.hidden': ['comic'],
      'collectarr.library_nav.placement': 'left',
    });
    tester.view.physicalSize = const Size(900, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime.utc(2026, 5, 15);
    const game = CatalogItem(
      id: 'game-rail-1',
      kind: 'game',
      title: 'Celeste',
      publisher: 'Maddy Makes Games',
      releaseYear: 2018,
    );
    final shelf = ShelfState.from(
      ownedItems: [
        OwnedItem(id: 'owned-game-rail-1', itemId: game.id, updatedAt: now),
      ],
      wishlistItems: const [],
      catalogItems: {game.id: game},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mediaCatalogProvider
              .overrideWith((ref) async => fallbackMediaCatalog),
          shelfProvider.overrideWith((ref) async => shelf),
          collectionProvider.overrideWith((ref) async => const []),
          wishlistProvider.overrideWith((ref) async => const []),
          wishlistIdsProvider.overrideWith((ref) async => const <String>{}),
        ],
        child: const MaterialApp(home: LibraryHomePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Add Games'), findsOneWidget);
    expect(find.text('Celeste'), findsWidgets);
    expect(find.text('Add Comics'), findsNothing);
    expect(find.byTooltip('Comics'), findsNothing);
    expect(find.byTooltip('Games'), findsOneWidget);
    expect(find.byTooltip('More libraries'), findsNothing);
  });
}
