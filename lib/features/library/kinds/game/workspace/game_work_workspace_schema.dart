import 'package:collectarr_app/features/library/kinds/game/workspace/game_ids.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:flutter/material.dart';

abstract final class GameWorkWorkspaceFields {
  static final title = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.title,
    label: 'Title',
    getValue: (dto) => dto.title,
    entityScope: LibraryEntityScope.work,
  );

  static final platform = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.platform,
    label: 'Platform',
    getValue: (dto) => dto.platform,
    entityScope: LibraryEntityScope.work,
  );

  static final developer = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.developer,
    label: 'Developer',
    getValue: (dto) => dto.developer,
    entityScope: LibraryEntityScope.work,
  );

  static final cover =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.cover,
    label: 'Cover',
    getValue: (context) => context.dto.coverImageUrl,
    entityScope: LibraryEntityScope.work,
  );

  static final franchise = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.franchise,
    label: 'Franchise',
    getValue: (dto) => dto.franchise,
    entityScope: LibraryEntityScope.work,
  );

  static final series = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.series,
    label: 'Series',
    getValue: (dto) => dto.seriesTitle,
    entityScope: LibraryEntityScope.work,
  );

  static final ageRating = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.ageRating,
    label: 'Age Rating',
    getValue: (dto) => dto.ageRating,
    entityScope: LibraryEntityScope.work,
  );

  static final loosePrice = numberField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.loosePrice,
    label: 'Loose Price',
    getValue: (dto) => dto.loosePrice,
    entityScope: LibraryEntityScope.work,
  );

  static final cibPrice = numberField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.cibPrice,
    label: 'CIB Price',
    getValue: (dto) => dto.cibPrice,
    entityScope: LibraryEntityScope.work,
  );

  static final newPrice = numberField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.newPrice,
    label: 'New/Sealed Price',
    getValue: (dto) => dto.newPrice,
    entityScope: LibraryEntityScope.work,
  );

  static final gradedPrice = numberField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.gradedPrice,
    label: 'Graded Price',
    getValue: (dto) => dto.gradedPrice,
    entityScope: LibraryEntityScope.work,
  );
}

final gameWorkWorkspaceFieldDefinitions = [
  GameWorkWorkspaceFields.title,
  GameWorkWorkspaceFields.platform,
  GameWorkWorkspaceFields.developer,
  GameWorkWorkspaceFields.cover,
  GameWorkWorkspaceFields.franchise,
  GameWorkWorkspaceFields.series,
  GameWorkWorkspaceFields.ageRating,
  GameWorkWorkspaceFields.loosePrice,
  GameWorkWorkspaceFields.cibPrice,
  GameWorkWorkspaceFields.newPrice,
  GameWorkWorkspaceFields.gradedPrice,
];

final gameWorkWorkspaceGroupDefinitions = [
  groupFromField<GameKind, GameWorkspaceDto, String?>(
    GameWorkWorkspaceFields.platform,
    sidebarTitle: 'Platforms',
    icon: Icons.videogame_asset_outlined,
  ),
  groupFromField<GameKind, GameWorkspaceDto, String?>(
    GameWorkWorkspaceFields.franchise,
    sidebarTitle: 'Franchises',
    icon: Icons.auto_stories_outlined,
  ),
];

final gameWorkWorkspaceSortDefinitions = [
  sortFromField<GameKind, GameWorkspaceDto, String>(
      GameWorkWorkspaceFields.platform),
  sortFromField<GameKind, GameWorkspaceDto, String>(
      GameWorkWorkspaceFields.title),
  sortFromField<GameKind, GameWorkspaceDto, num>(
      GameWorkWorkspaceFields.cibPrice,
      defaultAscending: false),
  sortFromField<GameKind, GameWorkspaceDto, num>(
      GameWorkWorkspaceFields.loosePrice,
      defaultAscending: false),
];

final gameWorkWorkspaceDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  GameFieldIds.cover,
  GameFieldIds.platform,
  GameFieldIds.title,
};

final gameWorkWorkspaceColumnDefinitions = [
  LibraryColumnDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.cover,
    label: '',
    getValue: GameWorkWorkspaceFields.cover.getValue,
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
      GameWorkWorkspaceFields.platform,
      defaultWidth: 120),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
      GameWorkWorkspaceFields.title,
      defaultWidth: 260,
      maxWidth: 520),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GameWorkWorkspaceFields.franchise,
    group: 'Classification',
    defaultWidth: 130,
  ),
  columnFromField<GameKind, GameWorkspaceDto, num?>(
    GameWorkWorkspaceFields.cibPrice,
    cellValue: (context) =>
        Text(_formatCents(context.dto.cibPrice, context.dto.currency)),
    group: 'Valuation',
    isNumeric: true,
    defaultWidth: 100,
  ),
  columnFromField<GameKind, GameWorkspaceDto, num?>(
    GameWorkWorkspaceFields.loosePrice,
    cellValue: (context) =>
        Text(_formatCents(context.dto.loosePrice, context.dto.currency)),
    group: 'Valuation',
    isNumeric: true,
    defaultWidth: 100,
  ),
];

final gameWorkWorkspaceSchema =
    LibraryEntityWorkspaceSchema<GameKind, GameWorkspaceDto>(
  kindNamespace: 'game',
  entityScope: LibraryEntityScope.work,
  fields: gameWorkWorkspaceFieldDefinitions,
  columns: gameWorkWorkspaceColumnDefinitions,
  sorts: gameWorkWorkspaceSortDefinitions,
  groups: gameWorkWorkspaceGroupDefinitions,
  primaryColumn: GameFieldIds.title,
  defaultVisibleColumns: gameWorkWorkspaceDefaultVisibleColumns,
  defaultSort: GameSortIds.platform,
  defaultGroup: GameGroupIds.platform,
  preferenceCodec: const GamePreferenceCodec(),
);

String _formatCents(int? cents, String? currency) {
  if (cents == null) return '';
  final amount = (cents / 100).toStringAsFixed(2);
  return currency == null ? amount : '$currency $amount';
}
