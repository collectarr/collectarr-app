import 'package:collectarr_app/features/library/kinds/game/workspace/game_ids.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_library_entry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:flutter/material.dart';

abstract final class GameLibraryEntryWorkspaceFields {
  static final condition =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.condition,
    label: 'Condition',
    getValue: (context) {
      final entry = GameLibraryEntryProjection.fromDispatch(
          context.source.libraryEntryDispatch);
      return entry is GameLibraryEntry ? entry.personal.condition : null;
    },
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final location =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.location,
    label: 'Location',
    getValue: (context) => context.source.locationPath,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final pricePaid =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, int?>(
    id: GameFieldIds.pricePaid,
    label: 'Purchase Price',
    getValue: (context) => context.source.pricePaidCents,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final status =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.status,
    label: 'Status',
    getValue: (context) => context.source.isWishlisted
        ? 'wishlist'
        : (context.source.isEntry ? 'entry' : null),
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final rating =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, int?>(
    id: GameFieldIds.rating,
    label: 'Rating',
    getValue: (context) => context.dto.personal.rating,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final wishlist =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, bool>(
    id: GameFieldIds.wishlist,
    label: 'Wishlist',
    getValue: (context) => context.source.isWishlisted,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final updatedAt =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, DateTime>(
    id: GameFieldIds.updatedAt,
    label: 'Updated',
    getValue: (context) => context.source.updatedAt,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final addedAt =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, DateTime?>(
    id: GameFieldIds.addedAt,
    label: 'Added',
    getValue: (context) => context.source.addedAt,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final completionStatus =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.completionStatus,
    label: 'Completion',
    getValue: (context) {
      final entry = GameLibraryEntryProjection.fromDispatch(
          context.source.libraryEntryDispatch);
      return entry is GameLibraryEntry ? entry.personal.collectionStatus : null;
    },
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final completeness =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.completeness,
    label: 'Completeness',
    getValue: (context) {
      final entry = GameLibraryEntryProjection.fromDispatch(
          context.source.libraryEntryDispatch);
      return entry is GameLibraryEntry
          ? entry.personal.details.completeness
          : null;
    },
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final hasBox =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, bool?>(
    id: GameFieldIds.hasBox,
    label: 'Has Box',
    getValue: (context) {
      final entry = GameLibraryEntryProjection.fromDispatch(
          context.source.libraryEntryDispatch);
      return entry is GameLibraryEntry ? entry.personal.details.hasBox : null;
    },
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final hasManual =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, bool?>(
    id: GameFieldIds.hasManual,
    label: 'Has Manual',
    getValue: (context) {
      final entry = GameLibraryEntryProjection.fromDispatch(
          context.source.libraryEntryDispatch);
      return entry is GameLibraryEntry
          ? entry.personal.details.hasManual
          : null;
    },
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final priceChartingId =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.priceChartingId,
    label: 'PriceCharting ID',
    getValue: (context) {
      final entry = GameLibraryEntryProjection.fromDispatch(
          context.source.libraryEntryDispatch);
      return entry is GameLibraryEntry
          ? entry.personal.details.priceChartingId
          : null;
    },
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final coreRegion =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.coreRegion,
    label: 'Region',
    getValue: (context) {
      final entry = GameLibraryEntryProjection.fromDispatch(
        context.source.libraryEntryDispatch,
      );
      return entry is GameLibraryEntry
          ? entry.personal.details.coreRegion
          : null;
    },
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final valueLocked =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, bool?>(
    id: GameFieldIds.valueLocked,
    label: 'Value Locked',
    getValue: (context) {
      final entry = GameLibraryEntryProjection.fromDispatch(
          context.source.libraryEntryDispatch);
      return entry is GameLibraryEntry
          ? entry.personal.details.valueIsLocked
          : null;
    },
    entityScope: LibraryEntityScope.libraryEntry,
  );
}

final gameLibraryEntryWorkspaceFieldDefinitions = [
  GameLibraryEntryWorkspaceFields.condition,
  GameLibraryEntryWorkspaceFields.location,
  GameLibraryEntryWorkspaceFields.pricePaid,
  GameLibraryEntryWorkspaceFields.status,
  GameLibraryEntryWorkspaceFields.rating,
  GameLibraryEntryWorkspaceFields.wishlist,
  GameLibraryEntryWorkspaceFields.updatedAt,
  GameLibraryEntryWorkspaceFields.addedAt,
  GameLibraryEntryWorkspaceFields.completionStatus,
  GameLibraryEntryWorkspaceFields.completeness,
  GameLibraryEntryWorkspaceFields.coreRegion,
  GameLibraryEntryWorkspaceFields.hasBox,
  GameLibraryEntryWorkspaceFields.hasManual,
  GameLibraryEntryWorkspaceFields.priceChartingId,
  GameLibraryEntryWorkspaceFields.valueLocked,
];

final gameLibraryEntryWorkspaceGroupDefinitions = [
  groupFromField<GameKind, GameWorkspaceDto, String?>(
    GameLibraryEntryWorkspaceFields.location,
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
  groupFromField<GameKind, GameWorkspaceDto, String?>(
    GameLibraryEntryWorkspaceFields.completeness,
    sidebarTitle: 'Completeness',
    icon: Icons.inventory_2_outlined,
  ),
  groupFromField<GameKind, GameWorkspaceDto, String?>(
    GameLibraryEntryWorkspaceFields.condition,
    sidebarTitle: 'Conditions',
    icon: Icons.verified_outlined,
  ),
];

final gameLibraryEntryWorkspaceSortDefinitions = [
  LibrarySortDefinition<GameKind, GameWorkspaceDto>(
    id: GameSortIds.status,
    entityScope: LibraryEntityScope.libraryEntry,
    compare: (left, right) {
      int rank(LibraryProjectionContext<GameWorkspaceDto> ctx) {
        if (ctx.source.isEntry) return 0;
        if (ctx.source.isWishlisted) return 1;
        return 2;
      }

      final res = rank(left).compareTo(rank(right));
      return res != 0 ? res : left.dto.title.compareTo(right.dto.title);
    },
    label: 'Status',
  ),
];

final gameLibraryEntryWorkspaceDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  GameFieldIds.status,
  GameFieldIds.rating,
  GameFieldIds.condition,
  GameFieldIds.pricePaid,
  GameFieldIds.location,
  GameFieldIds.wishlist,
  GameFieldIds.updatedAt,
};

final gameLibraryEntryWorkspaceColumnDefinitions = [
  LibraryColumnDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.status,
    label: 'Status',
    getValue: GameLibraryEntryWorkspaceFields.status.getValue,
    cellValue: (context) => Text(context.source.isWishlisted
        ? 'Wishlist'
        : (context.source.isEntry ? 'Entry' : '')),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<GameKind, GameWorkspaceDto, bool>(
    id: GameFieldIds.wishlist,
    label: 'Wishlist',
    getValue: GameLibraryEntryWorkspaceFields.wishlist.getValue,
    cellValue: (context) => Text(context.source.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<GameKind, GameWorkspaceDto, DateTime>(
    id: GameFieldIds.updatedAt,
    label: 'Updated',
    getValue: GameLibraryEntryWorkspaceFields.updatedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<GameKind, GameWorkspaceDto, DateTime?>(
    id: GameFieldIds.addedAt,
    label: 'Added',
    getValue: GameLibraryEntryWorkspaceFields.addedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GameLibraryEntryWorkspaceFields.location,
    group: 'Personal',
    defaultWidth: 118,
  ),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GameLibraryEntryWorkspaceFields.condition,
    group: 'Value',
    defaultWidth: 124,
  ),
  columnFromField<GameKind, GameWorkspaceDto, int?>(
    GameLibraryEntryWorkspaceFields.pricePaid,
    cellValue: (context) =>
        Text(_formatCents(context.source.pricePaidCents, context.dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  LibraryColumnDefinition<GameKind, GameWorkspaceDto, int?>(
    id: GameFieldIds.rating,
    label: 'Rating',
    getValue: GameLibraryEntryWorkspaceFields.rating.getValue,
    cellValue: (context) => Text(context.dto.personal.rating?.toString() ?? ''),
    defaultWidth: 80,
  ),
];

final gameLibraryEntryWorkspaceSchema =
    LibraryEntityWorkspaceSchema<GameKind, GameWorkspaceDto>(
  kindNamespace: 'game',
  entityScope: LibraryEntityScope.libraryEntry,
  fields: gameLibraryEntryWorkspaceFieldDefinitions,
  columns: gameLibraryEntryWorkspaceColumnDefinitions,
  sorts: gameLibraryEntryWorkspaceSortDefinitions,
  groups: gameLibraryEntryWorkspaceGroupDefinitions,
  primaryColumn: GameFieldIds.status,
  defaultVisibleColumns: gameLibraryEntryWorkspaceDefaultVisibleColumns,
  defaultSort: GameSortIds.status,
  defaultGroup: GameGroupIds.condition,
  preferenceCodec: const GamePreferenceCodec(),
);

String _formatDate(DateTime? value) {
  if (value == null) return '';
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

String _formatCents(int? cents, String? currency) {
  if (cents == null) return '';
  final amount = (cents / 100).toStringAsFixed(2);
  return currency == null ? amount : '$currency $amount';
}
