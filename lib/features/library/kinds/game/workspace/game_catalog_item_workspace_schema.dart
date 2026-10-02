import 'package:collectarr_app/features/library/kinds/game/workspace/game_ids.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:flutter/material.dart';

abstract final class GameCatalogItemWorkspaceFields {
  static final title = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.title,
    label: 'Title',
    getValue: (dto) => dto.title,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final platform = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.platform,
    label: 'Platform',
    getValue: (dto) => dto.platform,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final developer = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.developer,
    label: 'Developer',
    getValue: (dto) => dto.developer,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final publisher = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.publisher,
    label: 'Publisher',
    getValue: (dto) => dto.publisher,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final releaseDate = dateField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.releaseDate,
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final barcode = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.barcode,
    label: 'Barcode',
    getValue: (dto) => dto.barcode,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final edition = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.edition,
    label: 'Edition',
    getValue: (dto) => dto.edition,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final cover =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.cover,
    label: 'Cover',
    getValue: (context) => context.dto.coverImageUrl,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final franchise = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.franchise,
    label: 'Franchise',
    getValue: (dto) => dto.franchise,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final series = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.series,
    label: 'Series',
    getValue: (dto) => dto.seriesTitle,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final ageRating = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.ageRating,
    label: 'Age Rating',
    getValue: (dto) => dto.ageRating,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final loosePrice = numberField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.loosePrice,
    label: 'Loose Price',
    getValue: (dto) => dto.loosePrice,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final cibPrice = numberField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.cibPrice,
    label: 'CIB Price',
    getValue: (dto) => dto.cibPrice,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final newPrice = numberField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.newPrice,
    label: 'New/Sealed Price',
    getValue: (dto) => dto.newPrice,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final gradedPrice = numberField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.gradedPrice,
    label: 'Graded Price',
    getValue: (dto) => dto.gradedPrice,
    entityScope: LibraryEntityScope.catalogItem,
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
  GameCatalogItemWorkspaceFields.loosePrice,
  GameCatalogItemWorkspaceFields.cibPrice,
  GameCatalogItemWorkspaceFields.newPrice,
  GameCatalogItemWorkspaceFields.gradedPrice,
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
  sortFromField<GameKind, GameWorkspaceDto, num>(
      GameCatalogItemWorkspaceFields.cibPrice,
      defaultAscending: false),
  sortFromField<GameKind, GameWorkspaceDto, num>(
      GameCatalogItemWorkspaceFields.loosePrice,
      defaultAscending: false),
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
  columnFromField<GameKind, GameWorkspaceDto, num?>(
    GameCatalogItemWorkspaceFields.cibPrice,
    cellValue: (context) =>
        Text(_formatCents(context.dto.cibPrice, context.dto.currency)),
    group: 'Valuation',
    isNumeric: true,
    defaultWidth: 100,
  ),
  columnFromField<GameKind, GameWorkspaceDto, num?>(
    GameCatalogItemWorkspaceFields.loosePrice,
    cellValue: (context) =>
        Text(_formatCents(context.dto.loosePrice, context.dto.currency)),
    group: 'Valuation',
    isNumeric: true,
    defaultWidth: 100,
  ),
];

final gameCatalogItemWorkspaceSchema =
  LibraryEntityWorkspaceSchema<GameKind, GameWorkspaceDto>(
  kindNamespace: 'game',
  entityScope: LibraryEntityScope.catalogItem,
  fields: gameCatalogItemWorkspaceFieldDefinitions,
  columns: gameCatalogItemWorkspaceColumnDefinitions,
  sorts: gameCatalogItemWorkspaceSortDefinitions,
  groups: gameCatalogItemWorkspaceGroupDefinitions,
  primaryColumn: GameFieldIds.title,
  defaultVisibleColumns: gameCatalogItemWorkspaceDefaultVisibleColumns,
  defaultSort: GameSortIds.platform,
  defaultGroup: GameGroupIds.platform,
  preferenceCodec: const GamePreferenceCodec(),
);

String _formatCents(int? cents, String? currency) {
  if (cents == null) return '';
  final amount = (cents / 100).toStringAsFixed(2);
  return currency == null ? amount : '$currency $amount';
}

String _formatDate(DateTime? value) {
  if (value == null) return '';
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
