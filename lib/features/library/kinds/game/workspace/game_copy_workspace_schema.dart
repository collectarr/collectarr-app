import 'package:collectarr_app/features/library/kinds/game/workspace/game_ids.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_owned_item.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:flutter/material.dart';

abstract final class GameCopyWorkspaceFields {
  static final condition =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.condition,
    label: 'Condition',
    getValue: (context) {
      final owned = GameOwnedItemProjection.fromDispatch(
          context.source.ownedItemDispatch);
      return owned is GameOwnedItem ? owned.condition : null;
    },
    entityScope: LibraryEntityScope.copy,
  );

  static final location =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.location,
    label: 'Location',
    getValue: (context) => context.source.locationPath,
    entityScope: LibraryEntityScope.copy,
  );

  static final pricePaid =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, int?>(
    id: GameFieldIds.pricePaid,
    label: 'Purchase Price',
    getValue: (context) => context.source.pricePaidCents,
    entityScope: LibraryEntityScope.copy,
  );

  static final status =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.status,
    label: 'Status',
    getValue: (context) => context.source.isWishlisted
        ? 'wishlist'
        : (context.source.isOwned ? 'owned' : null),
    entityScope: LibraryEntityScope.copy,
  );

  static final rating =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, int?>(
    id: GameFieldIds.rating,
    label: 'Rating',
    getValue: (context) => context.dto.personal.rating,
    entityScope: LibraryEntityScope.copy,
  );

  static final wishlist =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, bool>(
    id: GameFieldIds.wishlist,
    label: 'Wishlist',
    getValue: (context) => context.source.isWishlisted,
    entityScope: LibraryEntityScope.copy,
  );

  static final updatedAt =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, DateTime>(
    id: GameFieldIds.updatedAt,
    label: 'Updated',
    getValue: (context) => context.source.updatedAt,
    entityScope: LibraryEntityScope.copy,
  );

  static final addedAt =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, DateTime?>(
    id: GameFieldIds.addedAt,
    label: 'Added',
    getValue: (context) => context.source.addedAt,
    entityScope: LibraryEntityScope.copy,
  );

  static final completionStatus =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.completionStatus,
    label: 'Completion',
    getValue: (context) {
      final owned = GameOwnedItemProjection.fromDispatch(
          context.source.ownedItemDispatch);
      return owned is GameOwnedItem ? owned.collectionStatus : null;
    },
    entityScope: LibraryEntityScope.copy,
  );

  static final completeness =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.completeness,
    label: 'Completeness',
    getValue: (context) {
      final owned = GameOwnedItemProjection.fromDispatch(
          context.source.ownedItemDispatch);
      return owned is GameOwnedItem ? owned.details.completeness : null;
    },
    entityScope: LibraryEntityScope.copy,
  );

  static final hasBox =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, bool?>(
    id: GameFieldIds.hasBox,
    label: 'Has Box',
    getValue: (context) {
      final owned = GameOwnedItemProjection.fromDispatch(
          context.source.ownedItemDispatch);
      return owned is GameOwnedItem ? owned.details.hasBox : null;
    },
    entityScope: LibraryEntityScope.copy,
  );

  static final hasManual =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, bool?>(
    id: GameFieldIds.hasManual,
    label: 'Has Manual',
    getValue: (context) {
      final owned = GameOwnedItemProjection.fromDispatch(
          context.source.ownedItemDispatch);
      return owned is GameOwnedItem ? owned.details.hasManual : null;
    },
    entityScope: LibraryEntityScope.copy,
  );

  static final priceChartingId =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.priceChartingId,
    label: 'PriceCharting ID',
    getValue: (context) {
      final owned = GameOwnedItemProjection.fromDispatch(
          context.source.ownedItemDispatch);
      return owned is GameOwnedItem ? owned.details.priceChartingId : null;
    },
    entityScope: LibraryEntityScope.copy,
  );

  static final coreRegion =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.coreRegion,
    label: 'Region',
    getValue: (context) {
      final owned = GameOwnedItemProjection.fromDispatch(
        context.source.ownedItemDispatch,
      );
      return owned is GameOwnedItem ? owned.details.coreRegion : null;
    },
    entityScope: LibraryEntityScope.copy,
  );

  static final valueLocked =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, bool?>(
    id: GameFieldIds.valueLocked,
    label: 'Value Locked',
    getValue: (context) {
      final owned = GameOwnedItemProjection.fromDispatch(
          context.source.ownedItemDispatch);
      return owned is GameOwnedItem ? owned.details.valueIsLocked : null;
    },
    entityScope: LibraryEntityScope.copy,
  );
}

final gameCopyWorkspaceFieldDefinitions = [
  GameCopyWorkspaceFields.condition,
  GameCopyWorkspaceFields.location,
  GameCopyWorkspaceFields.pricePaid,
  GameCopyWorkspaceFields.status,
  GameCopyWorkspaceFields.rating,
  GameCopyWorkspaceFields.wishlist,
  GameCopyWorkspaceFields.updatedAt,
  GameCopyWorkspaceFields.addedAt,
  GameCopyWorkspaceFields.completionStatus,
  GameCopyWorkspaceFields.completeness,
  GameCopyWorkspaceFields.coreRegion,
  GameCopyWorkspaceFields.hasBox,
  GameCopyWorkspaceFields.hasManual,
  GameCopyWorkspaceFields.priceChartingId,
  GameCopyWorkspaceFields.valueLocked,
];

final gameCopyWorkspaceGroupDefinitions = [
  groupFromField<GameKind, GameWorkspaceDto, String?>(
    GameCopyWorkspaceFields.location,
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
  groupFromField<GameKind, GameWorkspaceDto, String?>(
    GameCopyWorkspaceFields.completeness,
    sidebarTitle: 'Completeness',
    icon: Icons.inventory_2_outlined,
  ),
  groupFromField<GameKind, GameWorkspaceDto, String?>(
    GameCopyWorkspaceFields.condition,
    sidebarTitle: 'Conditions',
    icon: Icons.verified_outlined,
  ),
];

final gameCopyWorkspaceSortDefinitions = [
  LibrarySortDefinition<GameKind, GameWorkspaceDto>(
    id: GameSortIds.status,
    entityScope: LibraryEntityScope.copy,
    compare: (left, right) {
      int rank(LibraryProjectionContext<GameWorkspaceDto> ctx) {
        if (ctx.source.isOwned) return 0;
        if (ctx.source.isWishlisted) return 1;
        return 2;
      }

      final res = rank(left).compareTo(rank(right));
      return res != 0 ? res : left.dto.title.compareTo(right.dto.title);
    },
    label: 'Status',
  ),
];

final gameCopyWorkspaceDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  GameFieldIds.status,
  GameFieldIds.rating,
  GameFieldIds.condition,
  GameFieldIds.pricePaid,
  GameFieldIds.location,
  GameFieldIds.wishlist,
  GameFieldIds.updatedAt,
};

final gameCopyWorkspaceColumnDefinitions = [
  LibraryColumnDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.status,
    label: 'Status',
    getValue: GameCopyWorkspaceFields.status.getValue,
    cellValue: (context) => Text(context.source.isWishlisted
        ? 'Wishlist'
        : (context.source.isOwned ? 'Owned' : '')),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<GameKind, GameWorkspaceDto, bool>(
    id: GameFieldIds.wishlist,
    label: 'Wishlist',
    getValue: GameCopyWorkspaceFields.wishlist.getValue,
    cellValue: (context) => Text(context.source.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<GameKind, GameWorkspaceDto, DateTime>(
    id: GameFieldIds.updatedAt,
    label: 'Updated',
    getValue: GameCopyWorkspaceFields.updatedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<GameKind, GameWorkspaceDto, DateTime?>(
    id: GameFieldIds.addedAt,
    label: 'Added',
    getValue: GameCopyWorkspaceFields.addedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GameCopyWorkspaceFields.location,
    group: 'Personal',
    defaultWidth: 118,
  ),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GameCopyWorkspaceFields.condition,
    group: 'Value',
    defaultWidth: 124,
  ),
  columnFromField<GameKind, GameWorkspaceDto, int?>(
    GameCopyWorkspaceFields.pricePaid,
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
    getValue: GameCopyWorkspaceFields.rating.getValue,
    cellValue: (context) => Text(context.dto.personal.rating?.toString() ?? ''),
    defaultWidth: 80,
  ),
];

final gameCopyWorkspaceSchema =
    LibraryEntityWorkspaceSchema<GameKind, GameWorkspaceDto>(
  kindNamespace: 'game',
  entityScope: LibraryEntityScope.copy,
  fields: gameCopyWorkspaceFieldDefinitions,
  columns: gameCopyWorkspaceColumnDefinitions,
  sorts: gameCopyWorkspaceSortDefinitions,
  groups: gameCopyWorkspaceGroupDefinitions,
  primaryColumn: GameFieldIds.status,
  defaultVisibleColumns: gameCopyWorkspaceDefaultVisibleColumns,
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
