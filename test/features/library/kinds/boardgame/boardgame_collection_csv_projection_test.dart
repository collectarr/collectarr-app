import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/integrations/collection_csv/boardgame_collection_csv_import_profile.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/integrations/collection_csv/boardgame_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('BoardGame import profile owns edition and barcode aliases', () {
    final profile = const BoardGameCollectionCsvImportProfile();
    final cells = profile.importCatalogCells(
      header: const [
        'Media Type',
        'Collectarr Item ID',
        'Series',
        'Edition',
        'Expansion / Edition',
        'Edition Title',
        'Physical Format',
        'Physical Format Label',
        'Publisher / Designer',
        'Release Date',
        'Barcode',
      ],
      values: const [
        'BoardGame',
        'boardgame-1',
        'Catan',
        '5th',
        'Seafarers',
        'Base game',
        'box',
        'Boxed game',
        'Kosmos',
        '04/01/1995',
        '4002051693302',
      ],
    );

    expect(cells, [
      'boardgame-1',
      'BoardGame',
      'Catan',
      '5th',
      'Seafarers',
      'Base game',
      'box',
      'Boxed game',
      'Kosmos',
      '04/01/1995',
      '4002051693302',
    ]);
  });

  test('projects BoardGame catalog cells with edition semantics', () {
    final projection = const BoardGameCollectionCsvProjection();
    final entry = ShelfEntry(
      itemId: 'boardgame-1',
      catalogItem: typedCatalogItemFromCatalogItem(testCatalogItem(
        id: 'boardgame-1',
        kind: 'boardgame',
        title: 'Catan',
        itemNumber: '5th',
        variant: 'Seafarers',
        physicalFormat: 'box',
        physicalFormatLabel: 'Boxed game',
        publisher: 'Kosmos',
        releaseDate: DateTime.utc(1995, 4, 1),
        barcode: '4002051693302',
      )),
      ownedItem: testOwnedItem(
        id: 'owned-1',
        itemId: 'boardgame-1',
        quantity: 1,
        updatedAt: DateTime.utc(2026, 5, 15),
      ),
    );

    expect(projection.catalogCells(entry), [
      'boardgame-1',
      'boardgame',
      'Catan',
      '5th',
      'Seafarers',
      '',
      'box',
      'Boxed game',
      'Kosmos',
      '1995-04-01',
      '4002051693302',
    ]);
    expect(
      projection.ownedCellsAfterIndex(entry, clzFriendly: false),
      everyElement(isEmpty),
    );
  });
}
