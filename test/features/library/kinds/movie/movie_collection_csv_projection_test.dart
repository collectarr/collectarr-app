import 'package:collectarr_app/features/library/kinds/movie/integrations/collection_csv/movie_collection_csv_import_profile.dart';
import 'package:collectarr_app/features/library/kinds/movie/integrations/collection_csv/movie_collection_csv_projection.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('Movie import profile owns CLZ aliases and value parsing', () {
    final parsed = const MovieCollectionCsvImportProfile().parseRow(
      header: const [
        'Media Type',
        'Collectarr Item ID',
        'Title',
        'Edition no.',
        'Variant',
        'Edition Title',
        'Physical Format',
        'Physical Format Label',
        'Studio',
        'Release Date',
        'UPC / Barcode',
      ],
      values: const [
        'Movie',
        'movie-1',
        'Blade Runner',
        'Final Cut',
        '4K UHD',
        'Final Cut 4K release',
        '4k-uhd',
        '4K UHD',
        'Warner Bros.',
        '06/25/1982',
        '883929087129',
      ],
    );

    expect(parsed, isNotNull);
    expect(parsed!.itemId, 'movie-1');
    expect(parsed.kind, 'Movie');
    expect(parsed.title, 'Blade Runner');
    expect(parsed.itemNumber, 'Final Cut');
    expect(parsed.variant, '4K UHD');
    expect(parsed.editionTitle, 'Final Cut 4K release');
    expect(parsed.studio, 'Warner Bros.');
    expect(parsed.releaseDate, DateTime.utc(1982, 6, 25));
    expect(parsed.barcode, '883929087129');
    expect(parsed.ownedCells, hasLength(9));
    expect(parsed.ownedCells, everyElement(isEmpty));
  });

  test('projects Movie catalog cells without Comic-owned semantics', () {
    final projection = const MovieCollectionCsvProjection();
    final entry = ShelfEntry(
      itemId: 'movie-1',
      catalogItem: testCatalogItemWithKindMetadata(testCatalogItem(
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
    );

    expect(projection.catalogCells(entry), [
      'movie-1',
      'movie',
      'Blade Runner',
      'Final Cut',
      '4K UHD',
      'Final Cut 4K release',
      '4k-uhd',
      '4K UHD',
      'Warner Bros.',
      '1982-06-25',
      '883929087129',
    ]);
    expect(
      projection.ownedCellsBeforeQuantity(entry, clzFriendly: false),
      isEmpty,
    );
    expect(
      projection.ownedCellsAfterIndex(entry, clzFriendly: false),
      hasLength(9),
    );
    expect(
      projection.ownedCellsBeforeQuantity(entry, clzFriendly: true),
      [''],
    );
    expect(
      projection.ownedCellsAfterIndex(entry, clzFriendly: true),
      hasLength(8),
    );
  });
}
