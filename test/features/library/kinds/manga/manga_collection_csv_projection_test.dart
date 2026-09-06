import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/manga/integrations/collection_csv/manga_collection_csv_import_profile.dart';
import 'package:collectarr_app/features/library/kinds/manga/integrations/collection_csv/manga_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('Manga import profile owns chapter and ISBN aliases', () {
    final profile = const MangaCollectionCsvImportProfile();
    final cells = profile.importCatalogCells(
      header: const [
        'Media Type',
        'Collectarr Item ID',
        'Series',
        'Chapter / Vol.',
        'Edition / Variant / Format',
        'Edition Title',
        'Physical Format',
        'Physical Format Label',
        'Publisher / Studio / Creator',
        'Release Date',
        'Barcode / UPC / ISBN',
      ],
      values: const [
        'Manga',
        'manga-1',
        'Berserk',
        '1',
        'Tankobon',
        'Volume 1',
        'tankobon',
        'Tankobon',
        'Hakusensha',
        '11/01/1990',
        '9784592132043',
      ],
    );

    expect(cells, [
      'manga-1',
      'Manga',
      'Berserk',
      '1',
      'Tankobon',
      'Volume 1',
      'tankobon',
      'Tankobon',
      'Hakusensha',
      '11/01/1990',
      '9784592132043',
    ]);
    expect(
      profile.importOwnedCells(
        header: const ['Media Type'],
        values: const ['Manga'],
      ),
      everyElement(isEmpty),
    );
  });

  test('projects Manga catalog cells with volume semantics', () {
    final projection = const MangaCollectionCsvProjection();
    final entry = ShelfEntry(
      itemId: 'manga-1',
      catalogItem: typedCatalogItemFromCatalogItem(testCatalogItem(
        id: 'manga-1',
        kind: 'manga',
        title: 'Berserk',
        itemNumber: '1',
        variant: 'Tankobon',
        editionTitle: 'Volume 1',
        physicalFormat: 'tankobon',
        physicalFormatLabel: 'Tankobon',
        publisher: 'Hakusensha',
        releaseDate: DateTime.utc(1990, 11, 1),
        barcode: '9784592132043',
      )),
      ownedItem: testOwnedItem(
        id: 'owned-1',
        itemId: 'manga-1',
        quantity: 1,
        updatedAt: DateTime.utc(2026, 5, 15),
      ),
    );

    expect(projection.catalogCells(entry), [
      'manga-1',
      'manga',
      'Berserk',
      '1',
      'Tankobon',
      'Volume 1',
      'tankobon',
      'Tankobon',
      'Hakusensha',
      '1990-11-01',
      '9784592132043',
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
