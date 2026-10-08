import 'package:collectarr_app/features/library/kinds/game/workspace/game_ids.dart';
import 'package:collectarr_app/features/library/kinds/game/config/game_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_schema.dart';
import 'package:flutter/material.dart';

abstract final class GameCatalogItemWorkspaceFields {
  static final title = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.title,
    label: 'Title',
    getValue: (dto) => dto.title,
  );

  static final platform = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.platform,
    label: 'Platform',
    getValue: (dto) => dto.platform,
    searchable: true,
  );

  static final developer = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.developer,
    label: 'Developer',
    getValue: (dto) => dto.developer,
    searchable: true,
  );

  static final publisher = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.publisher,
    label: 'Publisher',
    getValue: (dto) => dto.publisher,
    searchable: true,
  );

  static final releaseDate = dateField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.releaseDate,
    label: GameFieldIdentities.releaseDateLabel,
    getValue: (dto) => dto.releaseDate,
  );

  static final barcode = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.barcode,
    label: GameFieldIdentities.barcodeLabel,
    getValue: (dto) => dto.barcode,
    searchable: true,
  );

  static final edition = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.edition,
    label: 'Edition',
    getValue: (dto) => dto.edition,
  );

  static final cover =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.cover,
    label: 'Cover',
    getValue: (context) => context.dto.coverImageUrl,
  );

  static final franchise = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.franchise,
    label: GameFieldIdentities.franchiseLabel,
    getValue: (dto) => dto.franchise,
    searchable: true,
  );

  static final series = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.series,
    label: 'Series',
    getValue: (dto) => dto.seriesTitle,
  );

  static final ageRating = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.ageRating,
    label: 'Age Rating',
    getValue: (dto) => dto.ageRating,
  );

  static final region = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.region,
    label: 'Region',
    getValue: (dto) => dto.region,
    searchable: true,
  );
}

final gameCatalogItemWorkspaceFieldDefinitions = [
  GameCatalogItemWorkspaceFields.title,
  GameCatalogItemWorkspaceFields.platform,
  GameCatalogItemWorkspaceFields.developer,
  GameCatalogItemWorkspaceFields.publisher,
  GameCatalogItemWorkspaceFields.releaseDate,
  GameCatalogItemWorkspaceFields.barcode,
  GameCatalogItemWorkspaceFields.edition,
  GameCatalogItemWorkspaceFields.cover,
  GameCatalogItemWorkspaceFields.franchise,
  GameCatalogItemWorkspaceFields.series,
  GameCatalogItemWorkspaceFields.ageRating,
  GameCatalogItemWorkspaceFields.region,
];

final gameCatalogItemWorkspaceGroupDefinitions = [
  groupFromField<GameKind, GameWorkspaceDto, String?>(
    GameCatalogItemWorkspaceFields.platform,
    sidebarTitle: 'Platforms',
    icon: Icons.videogame_asset_outlined,
  ),
  groupFromField<GameKind, GameWorkspaceDto, String?>(
    GameCatalogItemWorkspaceFields.franchise,
    sidebarTitle: 'Franchises',
    icon: Icons.auto_stories_outlined,
  ),
  groupFromField<GameKind, GameWorkspaceDto, String?>(
    GameCatalogItemWorkspaceFields.publisher,
    sidebarTitle: 'Publishers',
    icon: Icons.business_outlined,
  ),
];

final gameCatalogItemWorkspaceSortDefinitions = [
  sortFromField<GameKind, GameWorkspaceDto, String>(
      GameCatalogItemWorkspaceFields.platform),
  sortFromField<GameKind, GameWorkspaceDto, String>(
      GameCatalogItemWorkspaceFields.title),
  sortFromField<GameKind, GameWorkspaceDto, String>(
      GameCatalogItemWorkspaceFields.publisher),
  sortFromField<GameKind, GameWorkspaceDto, DateTime>(
      GameCatalogItemWorkspaceFields.releaseDate,
      defaultAscending: false),
  sortFromField<GameKind, GameWorkspaceDto, String>(
      GameCatalogItemWorkspaceFields.edition),
  sortFromField<GameKind, GameWorkspaceDto, String>(
      GameCatalogItemWorkspaceFields.barcode),
];

final gameCatalogItemWorkspaceDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  GameFieldIds.cover,
  GameFieldIds.platform,
  GameFieldIds.title,
};

final gameCatalogItemWorkspaceColumnDefinitions = [
  LibraryColumnDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.cover,
    label: '',
    getValue: GameCatalogItemWorkspaceFields.cover.getValue,
    cellValue: (context) => context.dto.coverImageUrl == null
        ? const SizedBox.shrink()
        : Image.network(
            context.dto.coverImageUrl!,
            width: 32,
            height: 32,
            fit: BoxFit.cover,
          ),
    sortable: false,
    groupable: false,
    defaultWidth: 42,
    minWidth: 44,
  ),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
      GameCatalogItemWorkspaceFields.platform,
      defaultWidth: 120),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
      GameCatalogItemWorkspaceFields.title,
      defaultWidth: 260,
      maxWidth: 520),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GameCatalogItemWorkspaceFields.publisher,
    defaultWidth: 140,
  ),
  columnFromField<GameKind, GameWorkspaceDto, DateTime?>(
    GameCatalogItemWorkspaceFields.releaseDate,
    cellValue: (context) => Text(_formatDate(context.dto.releaseDate)),
    defaultWidth: 118,
  ),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GameCatalogItemWorkspaceFields.edition,
    group: 'Edition',
    defaultWidth: 140,
  ),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GameCatalogItemWorkspaceFields.barcode,
    group: 'Edition',
    defaultWidth: 160,
    maxWidth: 260,
  ),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GameCatalogItemWorkspaceFields.franchise,
    group: 'Classification',
    defaultWidth: 130,
  ),
];

final gameCatalogItemWorkspaceSchema =
    LibraryWorkspaceSchema<GameKind, GameWorkspaceDto>(
  kindNamespace: 'game',
  fields: gameCatalogItemWorkspaceFieldDefinitions,
  columns: gameCatalogItemWorkspaceColumnDefinitions,
  sorts: gameCatalogItemWorkspaceSortDefinitions,
  groups: gameCatalogItemWorkspaceGroupDefinitions,
  primaryColumn: GameFieldIds.title,
  defaultVisibleColumns: gameCatalogItemWorkspaceDefaultVisibleColumns,
  defaultSort: GameSortIds.platform,
  defaultGroup: GameGroupIds.platform,
);

String _formatDate(DateTime? value) {
  if (value == null) return '';
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
