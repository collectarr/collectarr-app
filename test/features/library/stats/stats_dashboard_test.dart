import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/game/config.dart';
import 'package:collectarr_app/features/library/kinds/manga/config.dart';
import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/features/library/kinds/tv/config.dart';
import 'package:collectarr_app/features/library/stats/stats_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('music stats dashboard uses artist and label metadata alerts', (
    tester,
  ) async {
    final state = ShelfState(
      entries: [
        ShelfEntry(
          itemId: 'music-1',
          catalogItem: CatalogItem(
            id: 'music-1',
            kind: 'music',
            title: 'Discovery',
          ),
        ),
      ],
      ownedCount: 0,
      wishlistCount: 0,
      missingGradeCount: 0,
      pricedCount: 0,
      totalPaidCents: null,
      primaryCurrency: null,
      hasMixedCurrencies: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showStatsDashboardDialog(
                  context,
                  type: musicLibraryConfig,
                  state: state,
                ),
                child: const Text('Open stats'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open stats'));
    await tester.pumpAndSettle();

    expect(find.text('Top Artists'), findsOneWidget);
    expect(find.text('Top Labels'), findsOneWidget);
    expect(find.text('Top Series'), findsNothing);
    expect(find.text('Top Publishers'), findsNothing);
    expect(find.text('Metadata Alerts'), findsOneWidget);
    expect(find.text('Missing artist'), findsOneWidget);
    expect(find.text('Missing label'), findsOneWidget);
    expect(find.text('Missing series'), findsNothing);
    expect(find.text('Missing publisher'), findsNothing);
  });

  testWidgets('game stats dashboard shows value summaries and invested drill-downs', (
    tester,
  ) async {
    final state = ShelfState(
      entries: [
        ShelfEntry(
          itemId: 'game-1',
          locationPath: 'Office › Shelf A',
          catalogItem: CatalogItem(
            id: 'game-1',
            kind: 'game',
            title: 'Elden Ring',
            series: const CatalogSeriesDetails(seriesTitle: 'Souls'),
            publisher: 'Bandai Namco',
          ),
          ownedItem: OwnedItem(
            id: 'owned-1',
            itemId: 'game-1',
            pricePaidCents: 4000,
            currency: 'USD',
            updatedAt: DateTime.utc(2026, 5, 1),
          ),
        ),
        ShelfEntry(
          itemId: 'game-2',
          locationPath: 'Office › Shelf B',
          catalogItem: CatalogItem(
            id: 'game-2',
            kind: 'game',
            title: 'Dark Souls III',
            series: const CatalogSeriesDetails(seriesTitle: 'Souls'),
            publisher: 'Bandai Namco',
          ),
          ownedItem: OwnedItem(
            id: 'owned-2',
            itemId: 'game-2',
            pricePaidCents: 2500,
            sellPriceCents: 3500,
            soldAt: DateTime.utc(2026, 5, 2),
            currency: 'USD',
            updatedAt: DateTime.utc(2026, 5, 2),
          ),
        ),
      ],
      ownedCount: 2,
      wishlistCount: 0,
      missingGradeCount: 2,
      keyComicCount: 1,
      pricedCount: 2,
      totalPaidCents: 6500,
      primaryCurrency: 'USD',
      hasMixedCurrencies: false,
      totalSellCents: 3500,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showStatsDashboardDialog(
                  context,
                  type: gamesLibraryConfig,
                  state: state,
                ),
                child: const Text('Open stats'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open stats'));
    await tester.pumpAndSettle();

    expect(find.text('Key items'), findsOneWidget);
    expect(find.text('1'), findsWidgets);
    expect(find.text('Net'), findsOneWidget);
    expect(find.text('USD -30.00'), findsOneWidget);
    expect(find.text('Most Invested Locations'), findsOneWidget);
    expect(find.text('Most Invested Series'), findsOneWidget);
    expect(find.text('USD 40.00'), findsOneWidget);
    expect(find.text('USD 65.00'), findsWidgets);
  });

  testWidgets('comic stats dashboard surfaces missing issue gaps', (tester) async {
    final state = ShelfState(
      entries: [
        for (final itemNumber in ['1', '2', '4'])
          ShelfEntry(
            itemId: 'comic-$itemNumber',
            catalogItem: CatalogItem(
              id: 'comic-$itemNumber',
              kind: 'comic',
              title: 'Saga',
              itemNumber: itemNumber,
              series: const CatalogSeriesDetails(seriesTitle: 'Saga'),
            ),
            ownedItem: OwnedItem(
              id: 'owned-$itemNumber',
              itemId: 'comic-$itemNumber',
              updatedAt: DateTime.utc(2026, 5, 1),
            ),
          ),
      ],
      ownedCount: 3,
      wishlistCount: 0,
      missingGradeCount: 3,
      pricedCount: 0,
      totalPaidCents: null,
      primaryCurrency: null,
      hasMixedCurrencies: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showStatsDashboardDialog(
                  context,
                  type: comicsLibraryConfig,
                  state: state,
                ),
                child: const Text('Open stats'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open stats'));
    await tester.pumpAndSettle();

    expect(find.text('Gaps: Saga'), findsOneWidget);
    expect(find.text('#3'), findsOneWidget);
  });

  testWidgets('manga stats dashboard surfaces missing volume gaps', (tester) async {
    final state = ShelfState(
      entries: [
        for (final volume in [1, 3])
          ShelfEntry(
            itemId: 'manga-$volume',
            catalogItem: CatalogItem(
              id: 'manga-$volume',
              kind: 'manga',
              title: 'Vinland Saga',
              series: CatalogSeriesDetails(
                seriesTitle: 'Vinland Saga',
                volumeNumber: volume,
              ),
            ),
            ownedItem: OwnedItem(
              id: 'owned-manga-$volume',
              itemId: 'manga-$volume',
              updatedAt: DateTime.utc(2026, 5, 1),
            ),
          ),
      ],
      ownedCount: 2,
      wishlistCount: 0,
      missingGradeCount: 2,
      pricedCount: 0,
      totalPaidCents: null,
      primaryCurrency: null,
      hasMixedCurrencies: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showStatsDashboardDialog(
                  context,
                  type: mangaLibraryConfig,
                  state: state,
                ),
                child: const Text('Open stats'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open stats'));
    await tester.pumpAndSettle();

    expect(find.text('Missing volumes: Vinland Saga'), findsOneWidget);
    expect(find.text('Vol. 2'), findsOneWidget);
  });

  testWidgets('tv stats dashboard surfaces missing season gaps', (tester) async {
    final state = ShelfState(
      entries: [
        for (final season in [1, 3])
          ShelfEntry(
            itemId: 'tv-$season',
            catalogItem: CatalogItem(
              id: 'tv-$season',
              kind: 'tv',
              title: 'The Mandalorian',
              series: CatalogSeriesDetails(
                seriesTitle: 'The Mandalorian',
                seasonNumber: season,
              ),
            ),
            ownedItem: OwnedItem(
              id: 'owned-tv-$season',
              itemId: 'tv-$season',
              updatedAt: DateTime.utc(2026, 5, 1),
            ),
          ),
      ],
      ownedCount: 2,
      wishlistCount: 0,
      missingGradeCount: 2,
      pricedCount: 0,
      totalPaidCents: null,
      primaryCurrency: null,
      hasMixedCurrencies: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showStatsDashboardDialog(
                  context,
                  type: tvLibraryConfig,
                  state: state,
                ),
                child: const Text('Open stats'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open stats'));
    await tester.pumpAndSettle();

    expect(find.text('Missing seasons: The Mandalorian'), findsOneWidget);
    expect(find.text('Season 2'), findsOneWidget);
  });
}