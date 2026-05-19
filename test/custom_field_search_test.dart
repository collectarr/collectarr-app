import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/comics/comics_filters.dart';
import 'package:collectarr_app/features/comics/shelf/comics_shelf_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('custom field search in comics shelf', () {
    test('filterComicsShelfEntries matches custom field values', () {
      final entries = [
        ShelfEntry(
          itemId: 'comic-1',
          catalogItem: const CatalogItem(
            id: 'comic-1',
            kind: 'comic',
            title: 'Batman',
          ),
          ownedItem: OwnedItem(
            id: 'owned-1',
            itemId: 'comic-1',
            quantity: 1,
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        ),
        ShelfEntry(
          itemId: 'comic-2',
          catalogItem: const CatalogItem(
            id: 'comic-2',
            kind: 'comic',
            title: 'Superman',
          ),
          ownedItem: OwnedItem(
            id: 'owned-2',
            itemId: 'comic-2',
            quantity: 1,
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        ),
      ];

      final cfValues = {
        'owned-1': ['Shelf A', 'Key Issue'],
        'owned-2': ['Shelf B'],
      };

      // Search by custom field value that only owned-1 has.
      final filtered = filterComicsShelfEntries(
        entries: entries,
        query: 'key issue',
        filters: ComicsFilterSelection.none,
        customFieldValuesByItem: cfValues,
      );

      expect(filtered, hasLength(1));
      expect(filtered.single.itemId, 'comic-1');
    });

    test('filterComicsShelfEntries still matches standard fields', () {
      final entries = [
        ShelfEntry(
          itemId: 'comic-1',
          catalogItem: const CatalogItem(
            id: 'comic-1',
            kind: 'comic',
            title: 'Batman',
            publisher: 'DC Comics',
          ),
        ),
      ];

      final filtered = filterComicsShelfEntries(
        entries: entries,
        query: 'dc comics',
        filters: ComicsFilterSelection.none,
      );

      expect(filtered, hasLength(1));
    });

    test('filterComicsShelfEntries with empty query returns all', () {
      final entries = [
        const ShelfEntry(
          itemId: 'comic-1',
          catalogItem: CatalogItem(
            id: 'comic-1',
            kind: 'comic',
            title: 'Batman',
          ),
        ),
        const ShelfEntry(
          itemId: 'comic-2',
          catalogItem: CatalogItem(
            id: 'comic-2',
            kind: 'comic',
            title: 'Superman',
          ),
        ),
      ];

      final filtered = filterComicsShelfEntries(
        entries: entries,
        query: '',
        filters: ComicsFilterSelection.none,
      );

      expect(filtered, hasLength(2));
    });

    test('projectComicsShelf includes custom field search', () {
      final state = ShelfState(
        entries: [
          ShelfEntry(
            itemId: 'comic-1',
            catalogItem: const CatalogItem(
              id: 'comic-1',
              kind: 'comic',
              title: 'Batman',
            ),
            ownedItem: OwnedItem(
              id: 'owned-1',
              itemId: 'comic-1',
              quantity: 1,
              updatedAt: DateTime.utc(2026, 1, 1),
            ),
          ),
          const ShelfEntry(
            itemId: 'comic-2',
            catalogItem: CatalogItem(
              id: 'comic-2',
              kind: 'comic',
              title: 'Superman',
            ),
          ),
        ],
        ownedCount: 1,
        wishlistCount: 0,
        missingGradeCount: 0,
        pricedCount: 0,
        totalPaidCents: null,
        primaryCurrency: null,
        hasMixedCurrencies: false,
      );

      final projection = projectComicsShelf(
        state: state,
        query: 'special value',
        filters: ComicsFilterSelection.none,
        customFieldValuesByItem: {
          'owned-1': ['Special value here'],
        },
      );

      expect(projection.entries, hasLength(1));
      expect(projection.entries.single.itemId, 'comic-1');
    });
  });
}
