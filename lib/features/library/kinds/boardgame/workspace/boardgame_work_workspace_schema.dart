import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_ids.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:flutter/material.dart';

abstract final class BoardGameWorkWorkspaceFields {
  static final title = textField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.title,
    label: 'Title',
    getValue: (dto) => dto.title,
    entityScope: LibraryEntityScope.work,
  );

  static final designer = textField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.designer,
    label: 'Designer',
    getValue: (dto) => dto.metadata?.designers.firstOrNull ?? dto.publisher,
    entityScope: LibraryEntityScope.work,
  );

  static final cover =
      LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto, String?>(
    id: BoardGameFieldIds.cover,
    label: 'Cover',
    getValue: (context) => context.dto.coverImageUrl,
    entityScope: LibraryEntityScope.work,
  );

  static final minPlayers = numberField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.minPlayers,
    label: 'Min Players',
    getValue: (dto) => dto.metadata?.minPlayers,
    entityScope: LibraryEntityScope.work,
  );

  static final maxPlayers = numberField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.maxPlayers,
    label: 'Max Players',
    getValue: (dto) => dto.metadata?.maxPlayers,
    entityScope: LibraryEntityScope.work,
  );

  static final bestPlayers = textField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.bestPlayers,
    label: 'Best Players',
    getValue: (dto) => dto.metadata?.bestPlayers,
    entityScope: LibraryEntityScope.work,
  );

  static final recommendedPlayers =
      textField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.recommendedPlayers,
    label: 'Recommended Players',
    getValue: (dto) => dto.metadata?.recommendedPlayers,
    entityScope: LibraryEntityScope.work,
  );

  static final minPlaytimeMinutes =
      numberField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.minPlaytimeMinutes,
    label: 'Min Playtime (m)',
    getValue: (dto) => dto.metadata?.minPlaytimeMinutes,
    entityScope: LibraryEntityScope.work,
  );

  static final maxPlaytimeMinutes =
      numberField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.maxPlaytimeMinutes,
    label: 'Max Playtime (m)',
    getValue: (dto) => dto.metadata?.maxPlaytimeMinutes,
    entityScope: LibraryEntityScope.work,
  );

  static final complexityWeight =
      numberField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.complexityWeight,
    label: 'Complexity / Weight',
    getValue: (dto) => dto.metadata?.complexityWeight,
    entityScope: LibraryEntityScope.work,
  );

  static final bggRating = numberField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.bggRating,
    label: 'BGG Rating',
    getValue: (dto) => dto.metadata?.bggRating,
    entityScope: LibraryEntityScope.work,
  );

  static final bggRank = numberField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.bggRank,
    label: 'BGG Rank',
    getValue: (dto) => dto.metadata?.bggRank,
    entityScope: LibraryEntityScope.work,
  );

  static final expansionFor = textField<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameFieldIds.expansionFor,
    label: 'Expansion For',
    getValue: (dto) => dto.metadata?.expansionFor,
    entityScope: LibraryEntityScope.work,
  );
}

final boardgameWorkWorkspaceFieldDefinitions = [
  BoardGameWorkWorkspaceFields.cover,
  BoardGameWorkWorkspaceFields.title,
  BoardGameWorkWorkspaceFields.designer,
  BoardGameWorkWorkspaceFields.minPlayers,
  BoardGameWorkWorkspaceFields.maxPlayers,
  BoardGameWorkWorkspaceFields.bestPlayers,
  BoardGameWorkWorkspaceFields.recommendedPlayers,
  BoardGameWorkWorkspaceFields.minPlaytimeMinutes,
  BoardGameWorkWorkspaceFields.maxPlaytimeMinutes,
  BoardGameWorkWorkspaceFields.complexityWeight,
  BoardGameWorkWorkspaceFields.bggRating,
  BoardGameWorkWorkspaceFields.bggRank,
  BoardGameWorkWorkspaceFields.expansionFor,
];

final boardgameWorkWorkspaceGroupDefinitions = [
  groupFromField<BoardGameKind, BoardGameWorkspaceDto, String?>(
    BoardGameWorkWorkspaceFields.bestPlayers,
    sidebarTitle: 'Best Player Count',
    icon: Icons.group_outlined,
  ),
];

final boardgameWorkWorkspaceSortDefinitions = [
  sortFromField<BoardGameKind, BoardGameWorkspaceDto, String>(
      BoardGameWorkWorkspaceFields.title),
  sortFromField<BoardGameKind, BoardGameWorkspaceDto, num>(
      BoardGameWorkWorkspaceFields.bggRating,
      defaultAscending: false),
  sortFromField<BoardGameKind, BoardGameWorkspaceDto, num>(
      BoardGameWorkWorkspaceFields.bggRank),
  sortFromField<BoardGameKind, BoardGameWorkspaceDto, num>(
      BoardGameWorkWorkspaceFields.complexityWeight,
      defaultAscending: false),
];

final boardgameWorkWorkspaceDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  BoardGameFieldIds.cover,
  BoardGameFieldIds.title,
};

final boardgameWorkWorkspaceColumnDefinitions = [
  LibraryColumnDefinition<BoardGameKind, BoardGameWorkspaceDto, String?>(
    id: BoardGameFieldIds.cover,
    label: '',
    getValue: BoardGameWorkWorkspaceFields.cover.getValue,
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
      BoardGameWorkWorkspaceFields.title,
      defaultWidth: 260,
      maxWidth: 520),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, num?>(
    BoardGameWorkWorkspaceFields.minPlayers,
    group: 'Players',
    isNumeric: true,
    defaultWidth: 90,
  ),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, num?>(
    BoardGameWorkWorkspaceFields.maxPlayers,
    group: 'Players',
    isNumeric: true,
    defaultWidth: 90,
  ),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, String?>(
    BoardGameWorkWorkspaceFields.bestPlayers,
    group: 'Players',
    defaultWidth: 100,
  ),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, num?>(
    BoardGameWorkWorkspaceFields.complexityWeight,
    group: 'Details',
    isNumeric: true,
    defaultWidth: 100,
  ),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, num?>(
    BoardGameWorkWorkspaceFields.bggRating,
    group: 'Details',
    isNumeric: true,
    defaultWidth: 90,
  ),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, num?>(
    BoardGameWorkWorkspaceFields.bggRank,
    group: 'Details',
    isNumeric: true,
    defaultWidth: 80,
  ),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, String?>(
    BoardGameWorkWorkspaceFields.expansionFor,
    group: 'Details',
    defaultWidth: 150,
  ),
];

final boardgameWorkWorkspaceSchema =
    LibraryEntityWorkspaceSchema<BoardGameKind, BoardGameWorkspaceDto>(
  kindNamespace: 'boardgame',
  entityScope: LibraryEntityScope.work,
  fields: boardgameWorkWorkspaceFieldDefinitions,
  columns: boardgameWorkWorkspaceColumnDefinitions,
  sorts: boardgameWorkWorkspaceSortDefinitions,
  groups: boardgameWorkWorkspaceGroupDefinitions,
  primaryColumn: BoardGameFieldIds.title,
  defaultVisibleColumns: boardgameWorkWorkspaceDefaultVisibleColumns,
  defaultSort: BoardGameSortIds.title,
  defaultGroup: BoardGameGroupIds.bestPlayers,
  preferenceCodec: const BoardGamePreferenceCodec(),
);
