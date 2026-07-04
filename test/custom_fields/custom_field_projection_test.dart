import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace_view.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

final _defaultViewState = LibraryWorkspaceViewState(
  viewMode: LibraryViewMode.grid,
  detailsLayout: LibraryDetailsLayout.hidden,
  isSidebarVisible: true,
  sortColumn: LibrarySortColumn.title,
  sortAscending: true,
  coverSize: 128,
  sidebarWidth: 200,
  detailsWidth: 300,
  detailsHeight: 220,
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
    adapter: comicsMediaAdapter,
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
            catalogItem: CatalogItem(
              id: 'comic-1',
              kind: 'comic',
              title: 'Batman',
            ),
            ownedItem: testOwnedItem(
              id: 'owned-1',
              itemId: 'comic-1',
              catalogRef: CatalogEntityRef(
                kind: 'comic',
                entityType: CatalogEntityType.work,
                id: 'comic-1',
              ),
              quantity: 1,
              updatedAt: DateTime.utc(2026, 1, 1),
            ),
          ),
          ShelfEntry(
            itemId: 'comic-2',
            catalogItem: CatalogItem(
              id: 'comic-2',
              kind: 'comic',
              title: 'Superman',
            ),
            ownedItem: testOwnedItem(
              id: 'owned-2',
              itemId: 'comic-2',
              catalogRef: CatalogEntityRef(
                kind: 'comic',
                entityType: CatalogEntityType.work,
                id: 'comic-2',
              ),
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
          ShelfEntry(
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

    test('matches original and display title aliases', () {
      final shelf = ShelfState(
        entries: [
          ShelfEntry(
            itemId: 'movie-1',
            catalogItem: CatalogItem(
              id: 'movie-1',
              kind: 'comic',
              title: 'Kimi no Na wa.',
              displayTitle: 'Your Name',
              localizedTitle: 'Your Name',
              originalTitle: '君の名は。',
              searchAliases: const ['Your Name'],
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

      final englishProjection = _project(shelf: shelf, query: 'your name');
      final originalProjection = _project(shelf: shelf, query: '君の名');

      expect(englishProjection.filteredItems, hasLength(1));
      expect(originalProjection.filteredItems, hasLength(1));
      expect(englishProjection.filteredItems.single.entry.resolvedTitle, 'Your Name');
    });

    test('empty query returns all', () {
      final shelf = ShelfState(
        entries: [
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
            catalogItem: CatalogItem(
              id: 'comic-1',
              kind: 'comic',
              title: 'Batman',
            ),
            ownedItem: testOwnedItem(
              id: 'owned-1',
              itemId: 'comic-1',
              quantity: 1,
              updatedAt: DateTime.utc(2026, 1, 1),
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
