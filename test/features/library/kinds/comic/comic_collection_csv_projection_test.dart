import 'package:collectarr_app/features/library/kinds/comic/integrations/collection_csv/comic_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/comic/integrations/collection_csv/comic_collection_csv_import_profile.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('Comic import profile owns CLZ aliases and value parsing', () {
    final parsed = const ComicCollectionCsvImportProfile().parseRow(
      header: const [
        'Media Type',
        'Core ComicID',
        'Series',
        'Issue Number',
        'Variant Description',
        'Release Date',
        'Cover Price',
        'Raw / Slabbed',
        'Key Comic',
        'Key Reason',
      ],
      values: const [
        'Comic',
        'comic-1',
        'Amazing Spider-Man',
        '1',
        'Newsstand',
        '07/01/2005',
        r'$3.99',
        'Slabbed',
        'Yes',
        'First appearance',
      ],
    );

    expect(parsed, isNotNull);
    expect(parsed!.itemId, 'comic-1');
    expect(parsed.kind, 'Comic');
    expect(parsed.title, 'Amazing Spider-Man');
    expect(parsed.issueNumber, '1');
    expect(parsed.variantDescription, 'Newsstand');
    expect(parsed.releaseDate, DateTime.utc(2005, 7, 1));
    expect(parsed.coverPriceCents, 399);
    expect(parsed.rawOrSlabbed, 'Slabbed');
    expect(parsed.keyComic, isTrue);
    expect(parsed.keyReason, 'First appearance');
  });

  test('projects Comic catalog and owned cells at the CSV boundary', () {
    final projection = const ComicCollectionCsvProjection();
    final entry = ShelfEntry(
      itemId: 'comic-1',
      catalogItem: testCatalogItemWithKindMetadata(testCatalogItem(
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
