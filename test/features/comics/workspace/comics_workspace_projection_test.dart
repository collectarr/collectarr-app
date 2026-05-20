import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/comics/shelf/comics_filters.dart';
import 'package:collectarr_app/features/comics/shelf/comics_shelf_projection.dart';
import 'package:collectarr_app/features/comics/workspace/comics_workspace_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('projects workspace series visible items selection and missing issues',
      () {
    final items = [
      _comic(id: 'batman-1', title: 'Batman', itemNumber: '1'),
      _comic(id: 'superman-4', title: 'Superman', itemNumber: '4'),
      _comic(id: 'superman-1', title: 'Superman', itemNumber: '1'),
      _comic(id: 'superman-2', title: 'Superman', itemNumber: '2'),
    ];

    final projection = ComicsWorkspaceProjection.fromItems(
      items: items,
      selectedSeries: 'Superman',
      selectedItemId: 'superman-2',
    );

    expect(
      projection.series.map((bucket) => '${bucket.title}:${bucket.count}'),
      ['Batman:1', 'Superman:3'],
    );
    expect(
      projection.visibleItems.map((item) => item.id),
      ['superman-4', 'superman-1', 'superman-2'],
    );
    expect(projection.selectedItem?.id, 'superman-2');
    expect(projection.missingIssues, [3]);
    expect(projection.totalCount, 4);
    expect(projection.visibleCount, 3);
  });

  test('falls back to the first visible item when selected item is unavailable',
      () {
    final projection = ComicsWorkspaceProjection.fromItems(
      items: [
        _comic(id: 'action-1', title: 'Action Comics', itemNumber: '1'),
        _comic(id: 'action-2', title: 'Action Comics', itemNumber: '2'),
      ],
      selectedSeries: 'Action Comics',
      selectedItemId: 'missing',
    );

    expect(projection.selectedItem?.id, 'action-1');
    expect(projection.missingIssues, isEmpty);
  });

  test(
      'groups workspace entries by publisher year grade condition and wishlist',
      () {
    final entries = [
      ShelfEntry(
        itemId: 'comic-1',
        catalogItem: _comic(
          id: 'comic-1',
          title: 'Action Comics',
          itemNumber: '1',
          publisher: 'DC',
          releaseYear: 2026,
        ),
        ownedItem: _owned('owned-1', 'comic-1', grade: '9.8'),
      ),
      ShelfEntry(
        itemId: 'comic-2',
        catalogItem: _comic(
          id: 'comic-2',
          title: 'Spider-Man',
          itemNumber: '1',
          publisher: 'Marvel',
          releaseYear: 2025,
        ),
        wishlistItem: _wishlist('wish-1', 'comic-2'),
      ),
      ShelfEntry(
        itemId: 'comic-3',
        catalogItem: _comic(
          id: 'comic-3',
          title: 'Batman',
          itemNumber: '1',
          publisher: 'DC',
          releaseYear: 2026,
        ),
        ownedItem: _owned('owned-2', 'comic-3', condition: 'Fine'),
        wishlistItem: _wishlist('wish-2', 'comic-3'),
      ),
    ];

    final publisher = ComicsWorkspaceProjection.fromEntries(
      entries: entries,
      groupMode: ComicsShelfGroupMode.publisher,
      selectedGroup: 'DC',
      selectedItemId: null,
    );
    final year = ComicsWorkspaceProjection.fromEntries(
      entries: entries,
      groupMode: ComicsShelfGroupMode.year,
      selectedGroup: null,
      selectedItemId: null,
    );
    final grade = ComicsWorkspaceProjection.fromEntries(
      entries: entries,
      groupMode: ComicsShelfGroupMode.grade,
      selectedGroup: null,
      selectedItemId: null,
    );
    final condition = ComicsWorkspaceProjection.fromEntries(
      entries: entries,
      groupMode: ComicsShelfGroupMode.condition,
      selectedGroup: null,
      selectedItemId: null,
    );
    final wishlist = ComicsWorkspaceProjection.fromEntries(
      entries: entries,
      groupMode: ComicsShelfGroupMode.wishlist,
      selectedGroup: null,
      selectedItemId: null,
    );

    expect(
      publisher.groups.map((bucket) => '${bucket.title}:${bucket.count}'),
      ['DC:2', 'Marvel:1'],
    );
    expect(publisher.visibleItems.map((item) => item.id), [
      'comic-1',
      'comic-3',
    ]);
    expect(
      year.groups.map((bucket) => bucket.title),
      ['2026', '2025'],
    );
    expect(
      grade.groups.map((bucket) => '${bucket.title}:${bucket.count}'),
      ['9.8:1', 'Ungraded:1', 'Not owned:1'],
    );
    expect(
      condition.groups.map((bucket) => '${bucket.title}:${bucket.count}'),
      ['Fine:1', 'Unknown Condition:1', 'Not owned:1'],
    );
    expect(
      wishlist.groups.map((bucket) => '${bucket.title}:${bucket.count}'),
      ['Owned:1', 'Wishlist:1', 'Owned + Wishlist:1'],
    );
  });

  test('detects local duplicate candidates by barcode and issue metadata', () {
    final entries = [
      ShelfEntry(
        itemId: 'barcode-1',
        catalogItem: _comic(
          id: 'barcode-1',
          title: 'Saga',
          itemNumber: '1',
          publisher: 'Image',
          releaseYear: 2012,
          barcode: '123 456',
        ),
      ),
      ShelfEntry(
        itemId: 'barcode-2',
        catalogItem: _comic(
          id: 'barcode-2',
          title: 'Saga',
          itemNumber: '1',
          publisher: 'Image',
          releaseYear: 2012,
          barcode: '123456',
        ),
      ),
      ShelfEntry(
        itemId: 'issue-1',
        catalogItem: _comic(
          id: 'issue-1',
          title: 'Batman',
          itemNumber: '5',
          publisher: 'DC',
          releaseYear: 2026,
        ),
      ),
      ShelfEntry(
        itemId: 'issue-2',
        catalogItem: _comic(
          id: 'issue-2',
          title: 'Batman',
          itemNumber: '5',
          publisher: 'DC',
          releaseYear: 2026,
        ),
      ),
      ShelfEntry(
        itemId: 'variant-1',
        catalogItem: _comic(
          id: 'variant-1',
          title: 'Batman',
          itemNumber: '5',
          publisher: 'DC',
          releaseYear: 2026,
          variant: 'Foil variant',
        ),
      ),
    ];

    final projection = ComicsWorkspaceProjection.fromEntries(
      entries: entries,
      groupMode: ComicsShelfGroupMode.series,
      selectedGroup: null,
      selectedItemId: null,
    );

    expect(
      projection.duplicateGroups.map((group) => group.reason),
      ['Same barcode', 'Same issue metadata'],
    );
    expect(
      projection.duplicateGroups.map((group) => group.count),
      [2, 2],
    );
  });

  test('filters quick shelf views for missing covers and metadata', () {
    final entries = [
      ShelfEntry(
        itemId: 'complete',
        catalogItem: _comic(
          id: 'complete',
          title: 'Complete Series',
          itemNumber: '1',
          publisher: 'Image',
          releaseYear: 2026,
          barcode: '123',
          coverImageUrl: 'https://cdn.example/complete.jpg',
        ),
      ),
      ShelfEntry(
        itemId: 'no-cover',
        catalogItem: _comic(
          id: 'no-cover',
          title: 'No Cover',
          itemNumber: '1',
          publisher: 'Image',
          releaseYear: 2026,
          barcode: '456',
        ),
      ),
      ShelfEntry(
        itemId: 'thin-metadata',
        catalogItem: _comic(
          id: 'thin-metadata',
          title: 'Thin Metadata',
          itemNumber: '',
          coverImageUrl: 'https://cdn.example/thin.jpg',
        ),
      ),
    ];

    final missingCovers = filterComicsShelfEntries(
      entries: entries,
      query: '',
      filters: ComicsShelfQuickView.missingCovers.filters,
    );
    final missingMetadata = filterComicsShelfEntries(
      entries: entries,
      query: '',
      filters: ComicsShelfQuickView.missingMetadata.filters,
    );

    expect(missingCovers.map((entry) => entry.itemId), [
      'no-cover',
    ]);
    expect(missingMetadata.map((entry) => entry.itemId), [
      'thin-metadata',
    ]);
  });

  test('excludes non-comic media from comics shelf projections', () {
    final state = ShelfState(
      entries: [
        ShelfEntry(
          itemId: 'comic-1',
          catalogItem: _comic(
            id: 'comic-1',
            title: 'Action Comics',
            itemNumber: '1',
            publisher: 'DC',
          ),
        ),
        ShelfEntry(
          itemId: 'book-1',
          catalogItem: CatalogItem(
            id: 'book-1',
            kind: 'book',
            title: 'Dune',
            publisher: 'Ace',
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

    final projection = projectComicsShelf(
      state: state,
      query: '',
      filters: ComicsFilterSelection.none,
    );
    final queryResults = filterComicsShelfEntries(
      entries: state.entries,
      query: 'dune',
      filters: ComicsFilterSelection.none,
    );

    expect(projection.entries.map((entry) => entry.itemId), ['comic-1']);
    expect(projection.filterOptions.publishers, ['DC']);
    expect(queryResults, isEmpty);
  });
}

CatalogItem _comic({
  required String id,
  required String title,
  required String itemNumber,
  String? publisher,
  int? releaseYear,
  String? barcode,
  String? variant,
  String? coverImageUrl,
}) {
  return CatalogItem(
    id: id,
    kind: 'comic',
    title: title,
    itemNumber: itemNumber,
    publisher: publisher,
    releaseYear: releaseYear,
    barcode: barcode,
    variant: variant,
    coverImageUrl: coverImageUrl,
  );
}

OwnedItem _owned(
  String id,
  String itemId, {
  String? grade,
  String? condition,
}) {
  return OwnedItem(
    id: id,
    itemId: itemId,
    grade: grade,
    condition: condition,
    updatedAt: DateTime.utc(2026, 5, 14),
  );
}

WishlistItem _wishlist(String id, String itemId) {
  return WishlistItem(
    id: id,
    itemId: itemId,
    createdAt: DateTime.utc(2026, 5, 14),
    updatedAt: DateTime.utc(2026, 5, 14),
  );
}
