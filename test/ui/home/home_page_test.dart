import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/repositories/loan_repository.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/home/home_page.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_constants.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  testWidgets('non-comic libraries use the generic workspace', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1220, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime.utc(2026, 5, 15);
    final game = CatalogItem(
      id: 'game-1',
      kind: 'game',
      title: 'Hades',
      publisher: 'Supergiant Games',
      releaseYear: 2020,
      barcode: '123456789012',
    );
    final shelf = ShelfState.from(
      ownedItems: [
        testOwnedItem(
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
        child: MaterialApp(
          home: LibraryHomePage(routeUri: Uri(path: '/libraries')),
        ),
      ),
    );
    await pumpUntilSettled(tester);

    await tester.tap(find.text('Games'));
    await pumpUntilSettled(tester);

    // Core workspace layout renders with game data.
    expect(find.text('Add Games'), findsOneWidget);
    expect(find.text('Hades'), findsWidgets);
    expect(find.text('No game selected'), findsOneWidget);
    expect(find.byTooltip('Open details'), findsNothing);

    // Toolbar controls are available.
    expect(find.byTooltip('Library tools'), findsOneWidget);
    expect(find.byTooltip('Group by'), findsOneWidget);

    await tester.tap(find.byTooltip('Group by'));
    await pumpUntilSettled(tester);
    final yearOption = find.textContaining('Year').last;
    await tester.ensureVisible(yearOption);
    await tester.tap(yearOption);
    await pumpUntilSettled(tester);
  });

  testWidgets('generic library workspace exposes compact buckets',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(620, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime.utc(2026, 5, 15);
    final game = CatalogItem(
      id: 'game-1',
      kind: 'game',
      title: 'Hades',
      publisher: 'Supergiant Games',
      releaseYear: 2020,
    );
    final shelf = ShelfState.from(
      ownedItems: [
        testOwnedItem(id: 'owned-1', itemId: game.id, updatedAt: now),
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
        child: MaterialApp(
          home: LibraryHomePage(routeUri: Uri(path: '/libraries')),
        ),
      ),
    );
    await pumpUntilSettled(tester);

    // Navigate to games by scrolling the tab strip and tapping.
    await tester.dragUntilVisible(
      find.text('Games'),
      find.byType(ListView),
      const Offset(-100, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Games'));
    await pumpUntilSettled(tester);

    expect(find.text('[All Games] 1'), findsOneWidget);
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
    final podcast = CatalogItem(
      id: 'podcast-1',
      kind: 'podcast',
      title: 'The Library Feed',
      publisher: 'Collectarr Studio',
      releaseYear: 2026,
    );
    final shelf = ShelfState.from(
      ownedItems: [
        testOwnedItem(id: 'owned-podcast-1', itemId: podcast.id, updatedAt: now),
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
        child: MaterialApp(
          home: LibraryHomePage(routeUri: Uri(path: '/libraries')),
        ),
      ),
    );
    await pumpUntilSettled(tester);

    await tester.dragUntilVisible(
      find.text('Podcasts'),
      find.byType(ListView).first,
      const Offset(-100, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Podcasts'));
    await pumpUntilSettled(tester);

    expect(find.text('Add Podcasts'), findsOneWidget);
    expect(find.byTooltip('Library tools'), findsOneWidget);
    expect(find.text('Search podcasts...'), findsOneWidget);
    expect(find.text('[All Podcasts]'), findsOneWidget);
    expect(find.text('The Library Feed'), findsWidgets);
    expect(find.text('No podcast selected'), findsOneWidget);
  });

  testWidgets('library navigation preferences hide comics and use left rail',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'collectarr.library_nav.order': ['game', 'comic', 'manga'],
      'collectarr.library_nav.hidden': ['comic'],
      'collectarr.library_nav.placement': 'left',
    });
    tester.view.physicalSize = const Size(1220, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime.utc(2026, 5, 15);
    final game = CatalogItem(
      id: 'game-rail-1',
      kind: 'game',
      title: 'Celeste',
      publisher: 'Maddy Makes Games',
      releaseYear: 2018,
    );
    final shelf = ShelfState.from(
      ownedItems: [
        testOwnedItem(id: 'owned-game-rail-1', itemId: game.id, updatedAt: now),
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
        child: MaterialApp(
          home: LibraryHomePage(routeUri: Uri(path: '/libraries')),
        ),
      ),
    );
    await pumpUntilSettled(tester);

    expect(find.text('Add Games'), findsOneWidget);
    expect(find.text('Celeste'), findsWidgets);
    expect(find.text('Add Comics'), findsNothing);
    expect(find.byTooltip('Comics'), findsNothing);
    expect(find.byTooltip('Games'), findsOneWidget);
    expect(find.byTooltip('More libraries'), findsNothing);
  });

  testWidgets('main chrome shows overdue loan alert chip', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1220, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final now = DateTime.utc(2026, 5, 15);
    final game = CatalogItem(
      id: 'game-overdue-1',
      kind: 'game',
      title: 'Citizen Sleeper',
      publisher: 'Jump Over the Age',
      releaseYear: 2022,
    );
    final owned = testOwnedItem(
      id: 'owned-overdue-1',
      itemId: game.id,
      updatedAt: now,
    );
    final shelf = ShelfState.from(
      ownedItems: [owned],
      wishlistItems: const [],
      catalogItems: {game.id: game},
    );
    await LoanRepository(db).create(
      Loan(
        id: 'loan-overdue-1',
        ownedItemId: owned.id,
        borrowerName: 'Alex',
        lentDate: DateTime.utc(2020, 1, 1),
        dueDate: DateTime.utc(2020, 1, 10),
      ),
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
          localDatabaseProvider.overrideWithValue(db),
        ],
        child: MaterialApp(
          home: LibraryHomePage(routeUri: Uri(path: '/libraries')),
        ),
      ),
    );
    await pumpUntilSettled(tester);

    expect(find.text('1 overdue'), findsOneWidget);
    expect(
      find.byTooltip('1 overdue loan · Open Shelf'),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('unknown route kinds fall back to the first catalog page',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1220, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mediaCatalogProvider
              .overrideWith((ref) async => fallbackMediaCatalog),
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
        child: MaterialApp(
          home: LibraryHomePage(
            routeUri:
                Uri(path: '/libraries', queryParameters: {'kind': 'nope'}),
          ),
        ),
      ),
    );
    await pumpUntilSettled(tester);

    expect(find.text('Add Comics'), findsOneWidget);
    expect(find.text('Search comics...'), findsOneWidget);
    expect(find.text('Add Movies'), findsNothing);
  });
}
