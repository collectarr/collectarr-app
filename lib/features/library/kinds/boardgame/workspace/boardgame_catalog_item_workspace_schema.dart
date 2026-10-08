import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_ids.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_schema.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_bucket_mutators.dart';
import 'package:flutter/material.dart';

abstract final class BoardGameCatalogItemWorkspaceFields {
  static final title = textField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.title,
    label: 'Title',
    getValue: (dto) => dto.title,
  );

  static final publisher = textField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.publisher,
    label: 'Publisher',
    getValue: (dto) => dto.publisher,
    searchable: true,
  );

  static final releaseDate = dateField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.releaseDate,
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
  );

  static final barcode = textField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.barcode,
    label: 'Barcode',
    getValue: (dto) => dto.barcode,
    searchable: true,
  );

  static final designer = textField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.designer,
    label: 'Designer',
    getValue: (dto) => dto.metadata.designers.firstOrNull ?? dto.publisher,
  );

  static final cover =
      LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto, String?>(
    id: BoardGameFieldIds.cover,
    label: 'Cover',
    getValue: (context) => context.dto.coverImageUrl,
  );

  static final minPlayers = numberField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.minPlayers,
    label: 'Min Players',
    getValue: (dto) => dto.metadata.minPlayers,
  );

  static final maxPlayers = numberField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.maxPlayers,
    label: 'Max Players',
    getValue: (dto) => dto.metadata.maxPlayers,
  );

  static final bestPlayers = textField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.bestPlayers,
    label: 'Best Players',
    getValue: (dto) => dto.metadata.bestPlayers,
  );

  static final recommendedPlayers =
      textField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.recommendedPlayers,
    label: 'Recommended Players',
    getValue: (dto) => dto.metadata.recommendedPlayers,
  );

  static final minPlaytimeMinutes =
      numberField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.minPlaytimeMinutes,
    label: 'Min Playtime (m)',
    getValue: (dto) => dto.metadata.minPlaytimeMinutes,
  );

  static final maxPlaytimeMinutes =
      numberField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.maxPlaytimeMinutes,
    label: 'Max Playtime (m)',
    getValue: (dto) => dto.metadata.maxPlaytimeMinutes,
  );

  static final complexityWeight =
      numberField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.complexityWeight,
    label: 'Complexity / Weight',
    getValue: (dto) => dto.metadata.complexityWeight,
  );

  static final bggRating = numberField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.bggRating,
    label: 'BGG Rating',
    getValue: (dto) => dto.metadata.bggRating,
  );

  static final bggRank = numberField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.bggRank,
    label: 'BGG Rank',
    getValue: (dto) => dto.metadata.bggRank,
  );

  static final expansionFor = textField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.expansionFor,
    label: 'Expansion For',
    getValue: (dto) => dto.metadata.expansionFor,
  );
}

final boardgameCatalogItemWorkspaceFieldDefinitions = [
  BoardGameCatalogItemWorkspaceFields.cover,
  BoardGameCatalogItemWorkspaceFields.title,
  BoardGameCatalogItemWorkspaceFields.publisher,
  BoardGameCatalogItemWorkspaceFields.releaseDate,
  BoardGameCatalogItemWorkspaceFields.barcode,
  BoardGameCatalogItemWorkspaceFields.designer,
  BoardGameCatalogItemWorkspaceFields.minPlayers,
  BoardGameCatalogItemWorkspaceFields.maxPlayers,
  BoardGameCatalogItemWorkspaceFields.bestPlayers,
  BoardGameCatalogItemWorkspaceFields.recommendedPlayers,
  BoardGameCatalogItemWorkspaceFields.minPlaytimeMinutes,
  BoardGameCatalogItemWorkspaceFields.maxPlaytimeMinutes,
  BoardGameCatalogItemWorkspaceFields.complexityWeight,
  BoardGameCatalogItemWorkspaceFields.bggRating,
  BoardGameCatalogItemWorkspaceFields.bggRank,
  BoardGameCatalogItemWorkspaceFields.expansionFor,
];

final boardgameCatalogItemWorkspaceGroupDefinitions = [
  groupFromField<BoardGameKind, BoardGameWorkspaceDto, String?>(
    BoardGameCatalogItemWorkspaceFields.bestPlayers,
    sidebarTitle: 'Best Player Count',
    icon: Icons.group_outlined,
  ),
  groupFromField<BoardGameKind, BoardGameWorkspaceDto, String?>(
    BoardGameCatalogItemWorkspaceFields.publisher,
    sidebarTitle: 'Publishers',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
    bucketValueMutator: catalogTransportStringListBucketValueMutator(
      'publishers',
      scalarMirrorKeys: ['publisher'],
    ),
  ),
];

final boardgameCatalogItemWorkspaceSortDefinitions = [
  sortFromField<BoardGameKind, BoardGameWorkspaceDto, String>(
      BoardGameCatalogItemWorkspaceFields.title),
  sortFromField<BoardGameKind, BoardGameWorkspaceDto, String>(
      BoardGameCatalogItemWorkspaceFields.publisher),
  sortFromField<BoardGameKind, BoardGameWorkspaceDto, DateTime>(
      BoardGameCatalogItemWorkspaceFields.releaseDate,
      defaultAscending: false),
  sortFromField<BoardGameKind, BoardGameWorkspaceDto, num>(
      BoardGameCatalogItemWorkspaceFields.bggRating,
      defaultAscending: false),
  sortFromField<BoardGameKind, BoardGameWorkspaceDto, num>(
      BoardGameCatalogItemWorkspaceFields.bggRank),
  sortFromField<BoardGameKind, BoardGameWorkspaceDto, num>(
      BoardGameCatalogItemWorkspaceFields.complexityWeight,
      defaultAscending: false),
];

final boardgameCatalogItemWorkspaceDefaultVisibleColumns =
    <LibraryFieldIdRuntime>{
  BoardGameFieldIds.cover,
  BoardGameFieldIds.title,
  BoardGameFieldIds.publisher,
  BoardGameFieldIds.releaseDate,
  BoardGameFieldIds.barcode,
};

final boardgameCatalogItemWorkspaceColumnDefinitions = [
  LibraryColumnDefinition<BoardGameKind, BoardGameWorkspaceDto, String?>(
    id: BoardGameFieldIds.cover,
    label: '',
    getValue: BoardGameCatalogItemWorkspaceFields.cover.getValue,
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
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, String?>(
      BoardGameCatalogItemWorkspaceFields.title,
      defaultWidth: 260,
      maxWidth: 520),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, String?>(
      BoardGameCatalogItemWorkspaceFields.publisher,
      defaultWidth: 150),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, DateTime?>(
    BoardGameCatalogItemWorkspaceFields.releaseDate,
    cellValue: (context) => Text(_formatDate(context.dto.releaseDate)),
    defaultWidth: 118,
  ),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, String?>(
    BoardGameCatalogItemWorkspaceFields.barcode,
    group: 'Catalog Item',
    defaultWidth: 160,
    maxWidth: 260,
  ),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, num?>(
    BoardGameCatalogItemWorkspaceFields.minPlayers,
    group: 'Players',
    isNumeric: true,
    defaultWidth: 90,
  ),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, num?>(
    BoardGameCatalogItemWorkspaceFields.maxPlayers,
    group: 'Players',
    isNumeric: true,
    defaultWidth: 90,
  ),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, String?>(
    BoardGameCatalogItemWorkspaceFields.bestPlayers,
    group: 'Players',
    defaultWidth: 100,
  ),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, num?>(
    BoardGameCatalogItemWorkspaceFields.complexityWeight,
    group: 'Details',
    isNumeric: true,
    defaultWidth: 100,
  ),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, num?>(
    BoardGameCatalogItemWorkspaceFields.bggRating,
    group: 'Details',
    isNumeric: true,
    defaultWidth: 90,
  ),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, num?>(
    BoardGameCatalogItemWorkspaceFields.bggRank,
    group: 'Details',
    isNumeric: true,
    defaultWidth: 80,
  ),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, String?>(
    BoardGameCatalogItemWorkspaceFields.expansionFor,
    group: 'Details',
    defaultWidth: 150,
  ),
];

final boardgameCatalogItemWorkspaceSchema =
    LibraryWorkspaceSchema<BoardGameKind, BoardGameWorkspaceDto>(
  kindNamespace: 'boardgame',
  fields: boardgameCatalogItemWorkspaceFieldDefinitions,
  columns: boardgameCatalogItemWorkspaceColumnDefinitions,
  sorts: boardgameCatalogItemWorkspaceSortDefinitions,
  groups: boardgameCatalogItemWorkspaceGroupDefinitions,
  primaryColumn: BoardGameFieldIds.title,
  defaultVisibleColumns: boardgameCatalogItemWorkspaceDefaultVisibleColumns,
  defaultSort: BoardGameSortIds.title,
  defaultGroup: BoardGameGroupIds.bestPlayers,
);

String _formatDate(DateTime? value) {
  if (value == null) return '';
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
