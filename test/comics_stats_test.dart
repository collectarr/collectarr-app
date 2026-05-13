import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/shelf_controller.dart';
import 'package:collectarr_app/features/comics/comics_stats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('comics stats bar renders local counts and metadata gaps',
      (tester) async {
    final state = ShelfState.from(
      ownedItems: [
        OwnedItem(
          id: 'owned-1',
          itemId: 'comic-1',
          grade: '9.4',
          condition: 'Near Mint',
          pricePaidCents: 399,
          currency: 'USD',
          updatedAt: DateTime.utc(2026),
        ),
      ],
      wishlistItems: const [],
      catalogItems: {
        'comic-1': CatalogItem(
          id: 'comic-1',
          kind: 'comic',
          title: 'Superman, Vol. 4',
          publisher: 'DC',
          releaseDate: DateTime.utc(2016, 10, 5),
          synopsis: 'A comic issue.',
        ),
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ComicsStatsBar(
            state: state,
            selectedSeries: 'Superman, Vol. 4',
            missingIssues: const [2, 3],
          ),
        ),
      ),
    );

    expect(find.text('Local comics'), findsOneWidget);
    expect(find.text('Owned'), findsOneWidget);
    expect(find.text('Missing metadata'), findsOneWidget);
    expect(find.text('2'), findsWidgets);
  });

  test('missing metadata counts incomplete catalog entries', () {
    final entries = [
      ShelfEntry(
        itemId: 'comic-1',
        catalogItem: CatalogItem(
          id: 'comic-1',
          kind: 'comic',
          title: 'Missing cover',
          publisher: 'DC',
          releaseDate: DateTime.utc(2026),
          synopsis: 'Known issue.',
        ),
      ),
      ShelfEntry(
        itemId: 'comic-2',
        catalogItem: CatalogItem(
          id: 'comic-2',
          kind: 'comic',
          title: 'Complete',
          publisher: 'DC',
          releaseDate: DateTime.utc(2026),
          synopsis: 'Known issue.',
          coverImageUrl: 'https://example.test/cover.jpg',
        ),
      ),
    ];

    expect(missingComicsMetadataCount(entries), 1);
  });
}
