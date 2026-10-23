import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/domain/library_target_ref.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_entry_dispatch.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_projection_context.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_catalog_item_workspace_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_ids.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_library_entry_workspace_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_platform_icon.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_groups.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:flutter/material.dart';
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
    expect(gameGroupingCategories, [
      'Images',
      'Main',
      'Value',
      'Edition',
      'Personal',
    ]);
    expect(GameGroupingField.hasFront.category, 'Images');
    expect(GameGroupingField.hasBack.category, 'Images');
    expect(GameGroupingField.imageType.category, 'Images');
    expect(GameGroupingField.completeness.category, 'Value');
    expect(GameGroupingField.storageDevice.category, 'Personal');
  });

  test('Games columns include platform icon, developer and genre fields', () {
    final entry = gameLibraryEntryWorkspaceSchema.toRegistry();
    final catalog = gameCatalogItemWorkspaceSchema.toRegistry();
    final entryCols = entry.columns.map((c) => c.id.value).toSet();
    final catalogCols = catalog.columns.map((c) => c.id.value).toSet();

    expect(entryCols, contains(GameFieldIds.platformIcon.value));
    expect(catalogCols, contains(GameFieldIds.platformIcon.value));
    expect(entryCols, contains(GameFieldIds.developer.value));
    expect(entryCols, contains(GameFieldIds.genre.value));
    expect(entryCols, isNot(contains('game.toy_type')));
    expect(entryCols, isNot(contains('game.toy_subtype')));

    expect(gameLibraryEntryWorkspaceDefaultVisibleColumns.map((c) => c.value),
        contains(GameFieldIds.platformIcon.value));
    expect(gameCatalogItemWorkspaceDefaultVisibleColumns.map((c) => c.value),
        contains(GameFieldIds.platformIcon.value));
    // The reference default list has no cover thumbnail column.
    expect(gameLibraryEntryWorkspaceDefaultVisibleColumns.map((c) => c.value),
        isNot(contains(GameFieldIds.cover.value)));
  });

  test('the Series field reads the catalog series', () {
    final dto = GameWorkspaceDto(
      common: const WorkspaceCommonProjection(title: 'Fictional Game'),
      personal: PersonalEntryProjection(),
      metadata: const GameCatalogMetadata(
          title: 'Fictional Game', seriesTitle: 'Fictional Series'),
    );

    expect(dto.seriesTitle, 'Fictional Series');
  });

  test('Completed and Collection Status are separate fields', () {
    LibraryProjectionContext<GameWorkspaceDto> context(
        {bool? completed, String? status}) {
      const metadata = GameCatalogMetadata(title: 'Fictional Game');
      final entry = GameLibraryEntry(
        id: const LibraryEntryId('completed'),
        metadata: metadata,
        personal: GamePersonalData(
          collectionStatus: status,
          details: GameEntryDetails(completed: completed),
        ),
        updatedAt: DateTime.utc(2026),
      );
      return LibraryProjectionContext(
        item: WorkspaceItem(
          target: const CatalogTargetRef(
              CatalogItemRef(kind: CatalogMediaKind.game, id: 'completed')),
          libraryEntryDispatch: OpaqueLibraryEntryDispatch(
            ref: const LibraryEntryRef(
                kind: CatalogMediaKind.game, id: LibraryEntryId('completed')),
            kind: CatalogMediaKind.game,
            value: entry,
          ),
        ),
        personal: const PersonalOverlay(),
        sorting: const LibrarySortingOptions(),
        dto: GameWorkspaceDto(
          common: const WorkspaceCommonProjection(title: 'Fictional Game'),
          personal: PersonalEntryProjection(),
          metadata: metadata,
        ),
      );
    }

    final finishedWish = context(completed: true, status: 'Wish List');
    final unfinishedOwned = context(completed: false, status: 'In Collection');

    expect(GameLibraryEntryWorkspaceFields.completed.getValue(finishedWish),
        'Yes');
    expect(
        GameLibraryEntryWorkspaceFields.completionStatus.getValue(finishedWish),
        'Wish List');
    expect(GameLibraryEntryWorkspaceFields.completed.getValue(unfinishedOwned),
        'No');
    expect(
        GameLibraryEntryWorkspaceFields.completionStatus
            .getValue(unfinishedOwned),
        'In Collection');
    expect(GameLibraryEntryWorkspaceFields.completionStatus.metadata.label,
        'Collection Status');
  });

  test('resolveGamePlatformIcon maps platforms correctly', () {
    expect(resolveGamePlatformIcon('PC'), Icons.desktop_windows);
    expect(resolveGamePlatformIcon('Windows'), Icons.desktop_windows);
    expect(resolveGamePlatformIcon('macOS'), Icons.desktop_windows);
    expect(resolveGamePlatformIcon('Linux'), Icons.desktop_windows);
    expect(resolveGamePlatformIcon('Android'), Icons.smartphone);
    expect(resolveGamePlatformIcon('iOS'), Icons.smartphone);
    expect(resolveGamePlatformIcon('PlayStation 4'), AppIcons.gamepad);
    expect(resolveGamePlatformIcon('Nintendo Switch'), AppIcons.gamepad);
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
