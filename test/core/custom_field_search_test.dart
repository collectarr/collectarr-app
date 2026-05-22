import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/comics_library_config.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_view_state.dart';
import 'package:flutter_test/flutter_test.dart';

final _defaultViewState = LibraryWorkspaceViewState(
  viewMode: LibraryViewMode.grid,
  detailsLayout: LibraryDetailsLayout.hidden,
  sortColumn: LibrarySortColumn.title,
  sortAscending: true,
  coverSize: 128,
  sidebarWidth: 200,
  detailsWidth: 300,
  visibleColumns: const {},
  columnWidths: const {},
);

LibraryProjection _project({
  required ShelfState shelf,
  String query = '',
  Map<String, List<String>> customFieldValuesByItem = const {},
}) {
  return LibraryProjection.fromShelf(
    shelf: shelf,
    type: comicsLibraryConfig,
    viewState: _defaultViewState,
    query: query,
    selectedBucket: null,
    selectedItemId: null,
    quickView: null,
    groupMode: LibraryGroupMode.series,
    customFieldValuesByItem: customFieldValuesByItem,
  );
}

void main() {
  group('custom field search in generic projection', () {
    test('matches custom field values', () {
      final shelf = ShelfState(
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
        ],
        ownedCount: 2,
        wishlistCount: 0,
        missingGradeCount: 0,
        pricedCount: 0,
        totalPaidCents: null,
        primaryCurrency: null,
        hasMixedCurrencies: false,
      );

      final projection = _project(
        shelf: shelf,
        query: 'key issue',
        customFieldValuesByItem: {
          'owned-1': ['Shelf A', 'Key Issue'],
          'owned-2': ['Shelf B'],
        },
      );

      expect(projection.filteredItems, hasLength(1));
      expect(projection.filteredItems.single.entry.id, 'comic-1');
    });

    test('matches standard fields', () {
      final shelf = ShelfState(
        entries: [
          const ShelfEntry(
            itemId: 'comic-1',
            catalogItem: CatalogItem(
              id: 'comic-1',
              kind: 'comic',
              title: 'Batman',
              publisher: 'DC Comics',
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

      final projection = _project(shelf: shelf, query: 'dc comics');

      expect(projection.filteredItems, hasLength(1));
    });

    test('empty query returns all', () {
      final shelf = ShelfState(
        entries: const [
          ShelfEntry(
            itemId: 'comic-1',
            catalogItem: CatalogItem(
              id: 'comic-1',
              kind: 'comic',
              title: 'Batman',
            ),
          ),
          ShelfEntry(
            itemId: 'comic-2',
            catalogItem: CatalogItem(
              id: 'comic-2',
              kind: 'comic',
              title: 'Superman',
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

      final projection = _project(shelf: shelf);

      expect(projection.filteredItems, hasLength(2));
    });

    test('projection includes custom field search', () {
      final shelf = ShelfState(
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

      final projection = _project(
        shelf: shelf,
        query: 'special value',
        customFieldValuesByItem: {
          'owned-1': ['Special value here'],
        },
      );

      expect(projection.filteredItems, hasLength(1));
      expect(projection.filteredItems.single.entry.id, 'comic-1');
    });
  });
}
