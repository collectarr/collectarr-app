import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/game/integrations/collection_csv/game_collection_csv_import_profile.dart';
import 'package:collectarr_app/features/library/kinds/game/integrations/collection_csv/game_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('Game import profile owns platform and UPC aliases', () {
    final profile = const GameCollectionCsvImportProfile();
    final cells = profile.importCatalogCells(
      header: const [
        'Media Type',
        'Collectarr Item ID',
        'Series',
        'Version',
        'Platform / Edition',
        'Edition Title',
        'Physical Format',
        'Physical Format Label',
        'Publisher / Studio',
        'Release Date',
        'UPC / Barcode',
      ],
      values: const [
        'Game',
        'game-1',
        'The Legend of Zelda',
        '1.0',
        'Nintendo Switch',
        'Collector edition',
        'cartridge',
        'Cartridge',
        'Nintendo',
        '03/03/2017',
        '045496590593',
      ],
    );

    expect(cells, [
      'game-1',
      'Game',
      'The Legend of Zelda',
      '1.0',
      'Nintendo Switch',
      'Collector edition',
      'cartridge',
      'Cartridge',
      'Nintendo',
      '03/03/2017',
      '045496590593',
    ]);
  });

  test('projects Game catalog cells with platform and edition semantics', () {
    final projection = const GameCollectionCsvProjection();
    final entry = ShelfEntry(
      itemId: 'game-1',
      catalogItem: testCatalogItemWithKindMetadata(testCatalogItem(
        id: 'game-1',
        kind: 'game',
        title: 'The Legend of Zelda',
        publisher: 'Nintendo',
        releaseDate: DateTime.utc(2017, 3, 3),
        barcode: '045496590593',
        physicalFormat: 'cartridge',
        physicalFormatLabel: 'Cartridge',
        payload: {
          'edition': '1.0',
          'platform': 'Nintendo Switch',
          'edition_title': 'Collector edition',
        },
      )),
      ownedItem: testOwnedItem(
        id: 'owned-1',
        itemId: 'game-1',
        quantity: 1,
        updatedAt: DateTime.utc(2026, 5, 15),
      ),
    );

    expect(projection.catalogCells(entry), [
      'game-1',
      'game',
      'The Legend of Zelda',
      '1.0',
      'Nintendo Switch',
      '1.0',
      'cartridge',
      'Cartridge',
      'Nintendo',
      '2017-03-03',
      '045496590593',
    ]);
    expect(
      projection.ownedCellsAfterIndex(entry, clzFriendly: false),
      everyElement(isEmpty),
    );
  });
}
