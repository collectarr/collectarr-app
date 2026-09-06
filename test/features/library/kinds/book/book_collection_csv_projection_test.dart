import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/book/integrations/collection_csv/book_collection_csv_import_profile.dart';
import 'package:collectarr_app/features/library/kinds/book/integrations/collection_csv/book_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('Book import profile owns ISBN and edition aliases', () {
    final profile = const BookCollectionCsvImportProfile();
    final cells = profile.importCatalogCells(
      header: const [
        'Media Type',
        'Collectarr Item ID',
        'Title',
        'Edition no.',
        'Edition / Binding',
        'Edition Title',
        'Physical Format',
        'Physical Format Label',
        'Publisher',
        'Release Date',
        'ISBN / Barcode',
      ],
      values: const [
        'Book',
        'book-1',
        'The Hobbit',
        '1',
        'Hardcover',
        'First edition',
        'hardcover',
        'Hardcover',
        'Allen & Unwin',
        '09/21/1937',
        '9780261102217',
      ],
    );

    expect(cells, [
      'book-1',
      'Book',
      'The Hobbit',
      '1',
      'Hardcover',
      'First edition',
      'hardcover',
      'Hardcover',
      'Allen & Unwin',
      '09/21/1937',
      '9780261102217',
    ]);
    expect(
      profile.importOwnedCells(
        header: const ['Media Type'],
        values: const ['Book'],
      ),
      hasLength(9),
    );
  });

  test('projects Book catalog cells with edition semantics', () {
    final projection = const BookCollectionCsvProjection();
    final entry = ShelfEntry(
      itemId: 'book-1',
      catalogItem: testCatalogItemWithKindMetadata(testCatalogItem(
        id: 'book-1',
        kind: 'book',
        title: 'The Hobbit',
        itemNumber: '1',
        variant: 'Hardcover',
        editionTitle: 'First edition',
        physicalFormat: 'hardcover',
        physicalFormatLabel: 'Hardcover',
        publisher: 'Allen & Unwin',
        releaseDate: DateTime.utc(1937, 9, 21),
        barcode: '9780261102217',
      )),
      ownedItem: testOwnedItem(
        id: 'owned-1',
        itemId: 'book-1',
        quantity: 1,
        updatedAt: DateTime.utc(2026, 5, 15),
      ),
    );

    expect(projection.catalogCells(entry), [
      'book-1',
      'book',
      'The Hobbit',
      '1',
      'Hardcover',
      'First edition',
      'hardcover',
      'Hardcover',
      'Allen & Unwin',
      '1937-09-21',
      '9780261102217',
    ]);
    expect(
      projection.ownedCellsBeforeQuantity(entry, clzFriendly: false),
      isEmpty,
    );
    expect(
      projection.ownedCellsAfterIndex(entry, clzFriendly: false),
      everyElement(isEmpty),
    );
  });
}
