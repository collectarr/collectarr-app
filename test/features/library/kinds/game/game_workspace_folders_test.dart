import 'package:collectarr_app/features/library/kinds/game/workspace/game_catalog_item_workspace_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_library_entry_workspace_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_groups.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Games registries accept every reference folder', () {
    final entry = gameLibraryEntryWorkspaceSchema.toRegistry();
    final catalog = gameCatalogItemWorkspaceSchema.toRegistry();
    final entryGroups = entry.groups.map((group) => group.id.value).toSet();
    final catalogGroups = catalog.groups.map((group) => group.id.value).toSet();

    for (final field in GameGroupingField.values) {
      expect(entryGroups, contains(field.id));
      expect(catalogGroups.contains(field.id), !field.personal,
          reason: field.id);
    }
    expect(entry.defaultGroup?.value, GameGroupingField.platform.id);
  });

  test('folder categories follow the reference menu', () {
    expect(gameGroupingCategories, ['Main', 'Value', 'Edition', 'Personal']);
    expect(GameGroupingField.completeness.category, 'Value');
    expect(GameGroupingField.storageDevice.category, 'Personal');
  });

  test('Games sorts include the reference sort fields', () {
    final sorts = gameLibraryEntryWorkspaceSchema
        .toRegistry()
        .sorts
        .map((sort) => sort.id.value)
        .toSet();
    expect(
      sorts,
      containsAll([
        'game.sort_title',
        'game.value',
        'game.purchase_price',
        'game.index',
        'game.quantity',
        'game.box',
        'game.manual',
        'game.storage',
        'game.storage_slot',
        'game.added_date_sort',
        'game.modified_date_sort',
      ]),
    );
  });
}
