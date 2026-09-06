import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/kinds/tv/integrations/collection_csv/tv_collection_csv_import_profile.dart';
import 'package:collectarr_app/features/library/kinds/tv/integrations/collection_csv/tv_collection_csv_projection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('TV import profile owns network and season aliases', () {
    final profile = const TvCollectionCsvImportProfile();
    final cells = profile.importCatalogCells(
      header: const [
        'Media Type',
        'Collectarr Item ID',
        'Series',
        'Season / Episode',
        'Format / Edition',
        'Edition Title',
        'Physical Format',
        'Physical Format Label',
        'Network',
        'Release Date',
        'UPC / Barcode',
      ],
      values: const [
        'TV',
        'tv-1',
        'The X-Files',
        'S01E01',
        'Complete Series',
        'Collector Edition',
        '4k-uhd',
        '4K UHD',
        'FOX',
        '09/10/1993',
        '024543123456',
      ],
    );

    expect(cells, [
      'tv-1',
      'TV',
      'The X-Files',
      'S01E01',
      'Complete Series',
      'Collector Edition',
      '4k-uhd',
      '4K UHD',
      'FOX',
      '09/10/1993',
      '024543123456',
    ]);
    expect(
      profile.importOwnedCells(
        header: const ['Media Type'],
        values: const ['TV'],
      ),
      hasLength(9),
    );
  });

  test('projects TV catalog cells without flattening episodes', () {
    final projection = const TvCollectionCsvProjection();
    final entry = ShelfEntry(
      itemId: 'tv-1',
      catalogItem: testCatalogItemWithKindMetadata(testCatalogItem(
        id: 'tv-1',
        kind: 'tv',
        title: 'The X-Files',
        itemNumber: 'S01E01',
        publisher: 'FOX',
        releaseDate: DateTime.utc(1993, 9, 10),
        barcode: '024543123456',
        variant: 'Complete Series',
        physicalFormat: '4k-uhd',
        physicalFormatLabel: '4K UHD',
      )),
      ownedItem: testOwnedItem(
        id: 'owned-1',
        itemId: 'tv-1',
        quantity: 1,
        updatedAt: DateTime.utc(2026, 5, 15),
      ),
    );

    expect(projection.catalogCells(entry), [
      'tv-1',
      'tv',
      'The X-Files',
      'S01E01',
      'Complete Series',
      '',
      '4k-uhd',
      '4K UHD',
      'FOX',
      '1993-09-10',
      '024543123456',
    ]);
    expect(
      projection.ownedCellsAfterIndex(entry, clzFriendly: true),
      hasLength(8),
    );
  });
}
