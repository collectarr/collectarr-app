import '../../../../../../support/contracts/collection_csv_contract.dart';
import 'package:collectarr_app/features/library/kinds/anime/integrations/collection_csv/anime_collection_csv_import_profile.dart';
import 'package:collectarr_app/features/library/kinds/anime/integrations/collection_csv/anime_collection_csv_projection.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../../../support/builders/catalog_item_builder.dart';

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
      profile.importEntryCells(
        header: const ['Media Type'],
        values: const ['Anime'],
      ),
      hasLength(9),
    );
  });

  test('projects Anime catalog cells without video hierarchy erasure', () {
    final projection = const AnimeCollectionCsvProjection();
    final entry = collectionCsvFixture(
      catalog: testCatalogItem(
        id: 'anime-1',
        kind: 'anime',
        title: 'Cowboy Bebop',
        itemNumber: '1',
        publisher: 'Sunrise',
        releaseDate: DateTime.utc(1998, 4, 3),
        barcode: '123456789012',
        editionTitle: 'Complete Series',
        physicalFormat: 'blu-ray',
        physicalFormatLabel: 'Blu-ray',
        payload: const {'variant_name': 'TV / Collector'},
      ),
    );

    verifyCollectionCsvCatalogContract(
        projection: projection,
        fixture: entry,
        expectedCells: [
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
      projection.entryCellsAfterIndex(entry, clzFriendly: true),
      hasLength(9),
    );
  });
}
