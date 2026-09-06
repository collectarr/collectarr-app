import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/anime/integrations/collection_csv/anime_collection_csv_import_profile.dart';
import 'package:collectarr_app/features/library/kinds/anime/integrations/collection_csv/anime_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('Anime import profile owns studio and format aliases', () {
    final profile = const AnimeCollectionCsvImportProfile();
    final cells = profile.importCatalogCells(
      header: const [
        'Media Type',
        'Collectarr Item ID',
        'Series',
        'Edition no.',
        'Format / Edition',
        'Edition Title',
        'Physical Format',
        'Physical Format Label',
        'Studio',
        'Release Date',
        'UPC / Barcode',
      ],
      values: const [
        'Anime',
        'anime-1',
        'Cowboy Bebop',
        '1',
        'TV / Collector',
        'Complete Series',
        'blu-ray',
        'Blu-ray',
        'Sunrise',
        '04/03/1998',
        '123456789012',
      ],
    );

    expect(cells, [
      'anime-1',
      'Anime',
      'Cowboy Bebop',
      '1',
      'TV / Collector',
      'Complete Series',
      'blu-ray',
      'Blu-ray',
      'Sunrise',
      '04/03/1998',
      '123456789012',
    ]);
    expect(
      profile.importOwnedCells(
        header: const ['Media Type'],
        values: const ['Anime'],
      ),
      hasLength(9),
    );
  });

  test('projects Anime catalog cells without video hierarchy erasure', () {
    final projection = const AnimeCollectionCsvProjection();
    final entry = ShelfEntry(
      itemId: 'anime-1',
      catalogItem: typedCatalogItemFromCatalogItem(testCatalogItem(
        id: 'anime-1',
        kind: 'anime',
        title: 'Cowboy Bebop',
        itemNumber: '1',
        publisher: 'Sunrise',
        releaseDate: DateTime.utc(1998, 4, 3),
        barcode: '123456789012',
        variant: 'TV / Collector',
        editionTitle: 'Complete Series',
        physicalFormat: 'blu-ray',
        physicalFormatLabel: 'Blu-ray',
      )),
      ownedItem: testOwnedItem(
        id: 'owned-1',
        itemId: 'anime-1',
        quantity: 1,
        updatedAt: DateTime.utc(2026, 5, 15),
      ),
    );

    expect(projection.catalogCells(entry), [
      'anime-1',
      'anime',
      'Cowboy Bebop',
      '1',
      'TV / Collector',
      'Complete Series',
      'blu-ray',
      'Blu-ray',
      'Sunrise',
      '1998-04-03',
      '123456789012',
    ]);
    expect(
      projection.ownedCellsAfterIndex(entry, clzFriendly: true),
      hasLength(8),
    );
  });
}
