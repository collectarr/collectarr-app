import 'package:collectarr_app/features/library/kinds/comic/integrations/collection_csv/comic_collection_csv_projection.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('projects Comic catalog and owned cells at the CSV boundary', () {
    final projection = const ComicCollectionCsvProjection();
    final entry = ShelfEntry(
      itemId: 'comic-1',
      catalogItem: typedCatalogItemFromCatalogItem(testCatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'Spider-Man',
        itemNumber: '1',
        variant: 'Newsstand',
        editionTitle: 'Direct market edition',
        physicalFormat: 'single-issue',
        physicalFormatLabel: 'Single Issue',
        publisher: 'Marvel',
        releaseDate: DateTime.utc(1963, 3, 1),
        barcode: '071486024576',
      )),
      ownedItem: testOwnedItem(
        id: 'owned-1',
        itemId: 'comic-1',
        coverPriceCents: 399,
        rawOrSlabbed: 'Raw',
        keyComic: true,
        updatedAt: DateTime.utc(2026, 5, 12),
      ),
    );

    expect(projection.catalogCells(entry), [
      'comic-1',
      'comic',
      'Spider-Man',
      '1',
      'Newsstand',
      'Direct market edition',
      'single-issue',
      'Single Issue',
      'Marvel',
      '1963-03-01',
      '071486024576',
    ]);
    expect(
      projection.ownedCellsBeforeQuantity(entry, clzFriendly: false),
      isEmpty,
    );
    expect(
      projection.ownedCellsAfterIndex(entry, clzFriendly: false),
      ['399', 'Raw', '', '', '', '', '', 'true', ''],
    );
    expect(
      projection.ownedCellsBeforeQuantity(entry, clzFriendly: true),
      ['3.99'],
    );
    expect(
      projection.ownedCellsAfterIndex(entry, clzFriendly: true),
      ['Raw', '', '', '', '', '', 'true', ''],
    );
  });
}
