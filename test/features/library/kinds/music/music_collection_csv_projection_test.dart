import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/music/integrations/collection_csv/music_collection_csv_import_profile.dart';
import 'package:collectarr_app/features/library/kinds/music/integrations/collection_csv/music_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('Music import profile owns label and catalog number aliases', () {
    final profile = const MusicCollectionCsvImportProfile();
    final cells = profile.importCatalogCells(
      header: const [
        'Media Type',
        'Collectarr Item ID',
        'Release',
        'Catalog no.',
        'Format / Edition',
        'Edition Title',
        'Physical Format',
        'Physical Format Label',
        'Label',
        'Release Date',
        'Barcode / Catalog no.',
      ],
      values: const [
        'Music',
        'music-1',
        'Kind of Blue',
        'CK  CS 8163',
        'Remastered',
        'Anniversary Edition',
        'vinyl',
        'LP',
        'Columbia',
        '08/17/1959',
        '074646528825',
      ],
    );

    expect(cells, [
      'music-1',
      'Music',
      'Kind of Blue',
      'CK  CS 8163',
      'Remastered',
      'Anniversary Edition',
      'vinyl',
      'LP',
      'Columbia',
      '08/17/1959',
      '074646528825',
    ]);
    expect(
      profile.importOwnedCells(
        header: const ['Media Type'],
        values: const ['Music'],
      ),
      hasLength(9),
    );
  });

  test('projects Music release cells without flattening tracks', () {
    final projection = const MusicCollectionCsvProjection();
    final entry = ShelfEntry(
      itemId: 'music-1',
      catalogItem: typedCatalogItemFromCatalogItem(testCatalogItem(
        id: 'music-1',
        kind: 'music',
        title: 'Kind of Blue',
        publisher: 'Columbia',
        releaseDate: DateTime.utc(1959, 8, 17),
        barcode: '074646528825',
        variant: 'Remastered',
        editionTitle: 'Anniversary Edition',
        physicalFormat: 'vinyl',
        physicalFormatLabel: 'LP',
        payload: const {
          'releases': [
            {
              'id': 'release-1',
              'title': 'Kind of Blue',
              'catalog_number': 'CK  CS 8163',
              'format': 'Remastered',
            },
          ],
          'tracks': [
            {'number': '1', 'title': 'So What'},
          ],
        },
      )),
      ownedItem: testOwnedItem(
        id: 'owned-1',
        itemId: 'music-1',
        quantity: 1,
        updatedAt: DateTime.utc(2026, 5, 15),
      ),
    );

    expect(projection.catalogCells(entry), [
      'music-1',
      'music',
      'Kind of Blue',
      'CK  CS 8163',
      'Remastered',
      'Anniversary Edition',
      'vinyl',
      'LP',
      'Columbia',
      '1959-08-17',
      '074646528825',
    ]);
    expect(
      projection.ownedCellsAfterIndex(entry, clzFriendly: true),
      hasLength(8),
    );
  });
}
