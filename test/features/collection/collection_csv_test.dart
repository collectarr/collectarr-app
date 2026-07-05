import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:csv/csv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('collection csv exports and parses owned shelf rows', () {
    final csv = CollectionCsv();
    final exported = csv.exportShelf([
      ShelfEntry(
        itemId: 'comic-1',
        catalogItem: LibraryMetadataItem.fromCatalogItem(CatalogItem(
          id: 'comic-1',
          kind: 'comic',
          title: 'Spider-Man, "Vol. 1"',
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
          condition: 'Near Mint',
          grade: '9.8',
          purchaseDate: DateTime.utc(2026, 5, 11),
          pricePaidCents: 1299,
          currency: 'USD',
          personalNotes: 'Signed copy',
          quantity: 2,
          locationId: 'loc-short-box-6',
          indexNumber: 1310,
          coverPriceCents: 399,
          rawOrSlabbed: 'Raw',
          gradingCompany: 'CGC',
          graderNotes: 'Clean press',
          signedBy: 'Stan Lee',
          keyComic: true,
          keyReason: 'First appearance',
          rating: 5,
          readStatus: 'Read',
          tags: 'spider,key',
          updatedAt: DateTime.utc(2026, 5, 12),
        ),
        locationPath: 'Office › Shelf A › Short Box 6',
      ),
    ]);

    expect(exported, contains('"Spider-Man, ""Vol. 1"""'));
  expect(exported, contains('location_id'));

    final rows = csv.parse(exported);
    expect(rows.single.itemId, 'comic-1');
    expect(rows.single.kind, 'comic');
    expect(rows.single.title, 'Spider-Man, "Vol. 1"');
    expect(rows.single.itemNumber, '1');
    expect(rows.single.variant, 'Newsstand');
    expect(rows.single.editionTitle, 'Direct market edition');
    expect(rows.single.physicalFormat, 'single-issue');
    expect(rows.single.physicalFormatLabel, 'Single Issue');
    expect(rows.single.publisher, 'Marvel');
    expect(rows.single.releaseDate, DateTime.utc(1963, 3, 1));
    expect(rows.single.barcode, '071486024576');
    expect(rows.single.isOwned, isTrue);
    expect(rows.single.condition, 'Near Mint');
    expect(rows.single.grade, '9.8');
    expect(rows.single.pricePaidCents, 1299);
    expect(rows.single.notes, 'Signed copy');
    expect(rows.single.quantity, 2);
    expect(rows.single.locationId, 'Office › Shelf A › Short Box 6');
    expect(rows.single.indexNumber, 1310);
    expect(rows.single.coverPriceCents, 399);
    expect(rows.single.rawOrSlabbed, 'Raw');
    expect(rows.single.gradingCompany, 'CGC');
    expect(rows.single.graderNotes, 'Clean press');
    expect(rows.single.signedBy, 'Stan Lee');
    expect(rows.single.keyComic, isTrue);
    expect(rows.single.keyReason, 'First appearance');
    expect(rows.single.rating, 5);
    expect(rows.single.readStatus, 'Read');
    expect(rows.single.tags, 'spider,key');
  });

  test('collection csv round-trips typed custom field values', () {
    final csv = CollectionCsv();
    final defs = [
      CustomFieldDefinition(
        id: 'cf-1',
        name: 'Acquisition Source',
        fieldType: 'singleSelect',
        createdAt: DateTime.utc(2026, 1, 1),
      ),
      CustomFieldDefinition(
        id: 'cf-2',
        name: 'Favorite Formats',
        fieldType: 'multiSelect',
        createdAt: DateTime.utc(2026, 1, 1),
      ),
    ];
    final exported = csv.exportShelf(
      [
        ShelfEntry(
          itemId: 'book-1',
          catalogItem: LibraryMetadataItem.fromCatalogItem(CatalogItem(
            id: 'book-1',
            kind: 'book',
            title: 'Test Book',
          )),
          ownedItem: testOwnedItem(
            id: 'owned-1',
            itemId: 'book-1',
            updatedAt: DateTime.utc(2026, 5, 12),
          ),
        ),
      ],
      customFieldDefinitions: defs,
      customFieldValuesByItem: {
        'owned-1': [
          CustomFieldValue(
            id: 'val-1',
            targetId: 'owned-1',
            targetScope: CustomFieldTargetScope.ownedCopy,
            fieldDefinitionId: 'cf-1',
            value: 'Purchase',
            updatedAt: DateTime.utc(2026, 5, 12),
          ),
          CustomFieldValue(
            id: 'val-2',
            targetId: 'owned-1',
            targetScope: CustomFieldTargetScope.ownedCopy,
            fieldDefinitionId: 'cf-2',
            value: '["Hardcover","Digital"]',
            updatedAt: DateTime.utc(2026, 5, 12),
          ),
        ],
      },
    );

    expect(exported, contains('cf_Acquisition Source'));
    expect(exported, contains('cf_Favorite Formats'));

    final rows = csv.parse(exported);
    expect(rows.single.customFieldValues['Acquisition Source'], 'Purchase');
    expect(
      rows.single.customFieldValues['Favorite Formats'],
      '["Hardcover","Digital"]',
    );
  });

  test('collection csv exports clz-friendly shelf rows', () {
    final exported = CollectionCsv().exportClzFriendlyShelf([
      ShelfEntry(
        itemId: 'comic-1',
        catalogItem: LibraryMetadataItem.fromCatalogItem(CatalogItem(
          id: 'comic-1',
          kind: 'comic',
          title: 'The Amazing Spider-Man, Vol. 2',
          itemNumber: '520',
          publisher: 'Marvel Comics',
          releaseDate: DateTime.utc(2005, 7, 1),
          barcode: '75960604716152011',
          variant: 'Regular Cover',
        )),
        ownedItem: testOwnedItem(
          id: 'owned-1',
          itemId: 'comic-1',
          condition: 'Very Fine',
          grade: '7.5',
          pricePaidCents: 900,
          currency: 'USD',
          quantity: 1,
          locationId: 'loc-box-6',
          updatedAt: DateTime.utc(2026, 5, 12),
        ),
        locationPath: 'Office › Shelf A › Box 6',
      ),
    ]);

    expect(exported, contains('Collectarr Item ID'));
    expect(exported, contains('Media Type'));
    expect(exported, contains('Collection Status'));
    expect(exported, contains('The Amazing Spider-Man, Vol. 2'));
    expect(exported, contains('9.00'));
    expect(exported, contains('Office › Shelf A › Box 6'));
  });

  test('collection csv exports media-aware clz-friendly headers', () {
    final exported = CollectionCsv().exportClzFriendlyShelf([
      ShelfEntry(
        itemId: 'movie-1',
        catalogItem: LibraryMetadataItem.fromCatalogItem(CatalogItem(
          id: 'movie-1',
          kind: 'movie',
          title: 'Blade Runner',
          itemNumber: 'Final Cut',
          publisher: 'Warner Bros.',
          releaseDate: DateTime.utc(1982, 6, 25),
          barcode: '883929087129',
          variant: '4K UHD',
          editionTitle: 'Final Cut 4K release',
          physicalFormat: '4k-uhd',
          physicalFormatLabel: '4K UHD',
        )),
        ownedItem: testOwnedItem(
          id: 'owned-1',
          itemId: 'movie-1',
          quantity: 1,
          updatedAt: DateTime.utc(2026, 5, 15),
        ),
      ),
    ]);

    expect(exported, contains('Media Type'));
    expect(exported, contains('Title'));
    expect(exported, contains('Edition no.'));
    expect(exported, contains('Studio'));
    expect(exported, contains('UPC / Barcode'));
    expect(exported, contains('Physical Format'));

    final rows = CollectionCsv().parse(exported);
    expect(rows.single.kind, 'movie');
    expect(rows.single.title, 'Blade Runner');
    expect(rows.single.itemNumber, 'Final Cut');
    expect(rows.single.variant, '4K UHD');
    expect(rows.single.editionTitle, 'Final Cut 4K release');
    expect(rows.single.physicalFormat, '4k-uhd');
    expect(rows.single.physicalFormatLabel, '4K UHD');
    expect(rows.single.publisher, 'Warner Bros.');
  });

  test('collection csv parses clz-style aliases and money fields', () {
    final rows = CollectionCsv().parse(
      const CsvEncoder(lineDelimiter: '\n').convert([
        [
          'Collectarr Item ID',
          'Series',
          'Issue',
          'Collection Status',
          'Variant Description',
          'Publisher',
          'Release Date',
          'Grade',
          'Condition',
          'Purchase Price',
          'Currency',
          'Location ID',
          'Read It',
          'Key Comic',
          'Notes',
        ],
        [
          'comic-1',
          'The Amazing Spider-Man, Vol. 2',
          '520',
          'In Collection',
          'Direct Edition',
          'Marvel Comics',
          '07/01/2005',
          '7.5',
          'Very Fine',
          r'$9.00',
          'USD',
          'loc-box-6',
          'Read',
          'Yes',
          'CLZ import',
        ],
      ]),
    );

    expect(rows.single.itemId, 'comic-1');
    expect(rows.single.status, 'owned');
    expect(rows.single.title, 'The Amazing Spider-Man, Vol. 2');
    expect(rows.single.itemNumber, '520');
    expect(rows.single.variant, 'Direct Edition');
    expect(rows.single.publisher, 'Marvel Comics');
    expect(rows.single.releaseDate, DateTime.utc(2005, 7, 1));
    expect(rows.single.grade, '7.5');
    expect(rows.single.condition, 'Very Fine');
    expect(rows.single.pricePaidCents, 900);
    expect(rows.single.locationId, 'loc-box-6');
    expect(rows.single.readStatus, 'Read');
    expect(rows.single.keyComic, isTrue);
    expect(rows.single.notes, 'CLZ import');
  });

  test('collection csv parses structured location ids directly', () {
    final rows = CollectionCsv().parse(
      const CsvEncoder(lineDelimiter: '\n').convert([
        [
          'item_id',
          'status',
          'title',
          'location_id',
        ],
        ['comic-1', 'owned', 'Test', 'loc-short-box-6'],
      ]),
    );

    expect(rows.single.itemId, 'comic-1');
    expect(rows.single.locationId, 'loc-short-box-6');
  });

  test('collection csv parses decimal and thousands money separators', () {
    final rows = CollectionCsv().parse(
      const CsvEncoder(lineDelimiter: '\n').convert([
        [
          'Collectarr Item ID',
          'Series',
          'Collection Status',
          'Purchase Price',
          'Cover Price',
        ],
        [
          'comic-1',
          'US formatted price',
          'In Collection',
          r'$1,234.56',
          r'$2,500',
        ],
        [
          'comic-2',
          'EU formatted price',
          'In Collection',
          '€1.234,56',
          '€2.500',
        ],
      ]),
    );

    expect(rows[0].pricePaidCents, 123456);
    expect(rows[0].coverPriceCents, 250000);
    expect(rows[1].pricePaidCents, 123456);
    expect(rows[1].coverPriceCents, 250000);
  });

  test('collection csv keeps clz rows without collectarr ids for matching', () {
    final rows = CollectionCsv().parse(
      const CsvEncoder(lineDelimiter: '\n').convert([
        [
          'Collectarr Item ID',
          'Series',
          'Issue',
          'Barcode',
          'Collection Status',
        ],
        [
          '',
          'The Amazing Spider-Man, Vol. 2',
          '520',
          '75960604716152011',
          'In Collection',
        ],
      ]),
    );

    expect(rows, hasLength(1));
    expect(rows.single.itemId, isEmpty);
    expect(rows.single.title, 'The Amazing Spider-Man, Vol. 2');
    expect(rows.single.itemNumber, '520');
    expect(rows.single.barcode, '75960604716152011');
    expect(rows.single.isOwned, isTrue);
  });

  test('collection csv parses quoted newlines', () {
    final values = List<String>.filled(CollectionCsv.header.length, '');
    values[CollectionCsv.header.indexOf('item_id')] = 'comic-1';
    values[CollectionCsv.header.indexOf('kind')] = 'comic';
    values[CollectionCsv.header.indexOf('title')] = 'Title';
    values[CollectionCsv.header.indexOf('item_number')] = '1';
    values[CollectionCsv.header.indexOf('status')] = 'owned';
    values[CollectionCsv.header.indexOf('notes')] =
        'Line one\nLine two with "quote"';
    final rows = CollectionCsv().parse(
      const CsvEncoder(lineDelimiter: '\n').convert([
        CollectionCsv.header,
        values,
      ]),
    );

    expect(rows, hasLength(1));
    expect(rows.single.itemId, 'comic-1');
    expect(rows.single.notes, 'Line one\nLine two with "quote"');
  });

  test('collection csv parses non-iso date formats', () {
    final rows = CollectionCsv().parse(
      const CsvEncoder(lineDelimiter: '\n').convert([
        [
          'Collectarr Item ID',
          'Series',
          'Collection Status',
          'Release Date',
          'Purchase Date',
        ],
        ['comic-1', 'US date', 'In Collection', '05/11/2026', '5/12/26'],
        ['comic-2', 'Day first date', 'In Collection', '31/12/2025', ''],
      ]),
    );

    expect(rows[0].releaseDate, DateTime.utc(2026, 5, 11));
    expect(rows[0].purchaseDate, DateTime.utc(2026, 5, 12));
    expect(rows[1].releaseDate, DateTime.utc(2025, 12, 31));
  });

  test('csv export includes custom field columns', () {
    final defs = [
      CustomFieldDefinition(
        id: 'def-1',
        name: 'Location',
        fieldType: 'text',
        createdAt: DateTime.utc(2026, 1, 1),
      ),
      CustomFieldDefinition(
        id: 'def-2',
        name: 'Rating',
        fieldType: 'number',
        createdAt: DateTime.utc(2026, 1, 1),
      ),
    ];
    final cfValues = {
      'owned-1': [
        CustomFieldValue(
          id: 'v1',
          targetId: 'owned-1',
          targetScope: CustomFieldTargetScope.ownedCopy,
          fieldDefinitionId: 'def-1',
          value: 'Shelf A',
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
        CustomFieldValue(
          id: 'v2',
          targetId: 'owned-1',
          targetScope: CustomFieldTargetScope.ownedCopy,
          fieldDefinitionId: 'def-2',
          value: '9',
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      ],
    };

    final csv = CollectionCsv();
    final exported = csv.exportShelf(
      [
        ShelfEntry(
          itemId: 'comic-1',
          catalogItem: LibraryMetadataItem.fromCatalogItem(CatalogItem(
            id: 'comic-1',
            kind: 'comic',
            title: 'Test',
          )),
          ownedItem: testOwnedItem(
            id: 'owned-1',
            itemId: 'comic-1',
            quantity: 1,
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        ),
      ],
      customFieldDefinitions: defs,
      customFieldValuesByItem: cfValues,
    );

    expect(exported, contains('cf_Location'));
    expect(exported, contains('cf_Rating'));
    expect(exported, contains('Shelf A'));
    expect(exported, contains(',9'));
  });

  test('csv parse extracts cf_ columns into customFieldValues', () {
    final csv = CollectionCsv();
    final rows = csv.parse(
      const CsvEncoder().convert([
        ['item_id', 'status', 'title', 'cf_Location', 'cf_Score'],
        ['comic-1', 'owned', 'Test', 'Shelf B', '42'],
        ['comic-2', 'owned', 'Test 2', '', ''],
      ]),
    );

    expect(rows[0].customFieldValues, {'Location': 'Shelf B', 'Score': '42'});
    expect(rows[1].customFieldValues, isEmpty);
  });

  test('csv roundtrip preserves custom field values', () {
    final defs = [
      CustomFieldDefinition(
        id: 'def-1',
        name: 'Notes',
        fieldType: 'text',
        createdAt: DateTime.utc(2026, 1, 1),
      ),
    ];
    final cfValues = {
      'owned-1': [
        CustomFieldValue(
          id: 'v1',
          targetId: 'owned-1',
          targetScope: CustomFieldTargetScope.ownedCopy,
          fieldDefinitionId: 'def-1',
          value: 'Special note, with comma',
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      ],
    };

    final csv = CollectionCsv();
    final exported = csv.exportShelf(
      [
        ShelfEntry(
          itemId: 'comic-1',
          catalogItem: LibraryMetadataItem.fromCatalogItem(CatalogItem(
            id: 'comic-1',
            kind: 'comic',
            title: 'Test',
          )),
          ownedItem: testOwnedItem(
            id: 'owned-1',
            itemId: 'comic-1',
            quantity: 1,
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        ),
      ],
      customFieldDefinitions: defs,
      customFieldValuesByItem: cfValues,
    );

    final parsed = csv.parse(exported);
    expect(parsed.single.customFieldValues['Notes'],
        'Special note, with comma');
  });
}
