import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_ids.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_owned_item.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:flutter/material.dart';

abstract final class BoardGameCopyWorkspaceFields {
  static final condition =
      LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto, String?>(
    id: BoardGameFieldIds.condition,
    label: 'Condition',
    getValue: (context) {
      final owned = BoardGameOwnedItemProjection.fromDispatch(
          context.source.ownedItemDispatch);
      return owned is BoardGameOwnedItem ? owned.condition : null;
    },
    entityScope: LibraryEntityScope.copy,
  );

  static final location =
      LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto, String?>(
    id: BoardGameFieldIds.location,
    label: 'Location',
    getValue: (context) => context.source.locationPath,
    entityScope: LibraryEntityScope.copy,
  );

  static final pricePaid =
      LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto, int?>(
    id: BoardGameFieldIds.pricePaid,
    label: 'Purchase Price',
    getValue: (context) => context.source.pricePaidCents,
    entityScope: LibraryEntityScope.copy,
  );

  static final status =
      LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto, String?>(
    id: BoardGameFieldIds.status,
    label: 'Status',
    getValue: (context) => context.source.isWishlisted
        ? 'wishlist'
        : (context.source.isOwned ? 'owned' : null),
    entityScope: LibraryEntityScope.copy,
  );

  static final rating =
      LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto, int?>(
    id: BoardGameFieldIds.rating,
    label: 'Rating',
    getValue: (context) => context.dto.personal.rating,
    entityScope: LibraryEntityScope.copy,
  );

  static final wishlist =
      LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto, bool>(
    id: BoardGameFieldIds.wishlist,
    label: 'Wishlist',
    getValue: (context) => context.source.isWishlisted,
    entityScope: LibraryEntityScope.copy,
  );

  static final updatedAt =
      LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto, DateTime>(
    id: BoardGameFieldIds.updatedAt,
    label: 'Updated',
    getValue: (context) => context.source.updatedAt,
    entityScope: LibraryEntityScope.copy,
  );

  static final addedAt =
      LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto, DateTime?>(
    id: BoardGameFieldIds.addedAt,
    label: 'Added',
    getValue: (context) => context.source.addedAt,
    entityScope: LibraryEntityScope.copy,
  );
}

final boardgameCopyWorkspaceFieldDefinitions = [
  BoardGameCopyWorkspaceFields.status,
  BoardGameCopyWorkspaceFields.condition,
  BoardGameCopyWorkspaceFields.location,
  BoardGameCopyWorkspaceFields.pricePaid,
  BoardGameCopyWorkspaceFields.rating,
  BoardGameCopyWorkspaceFields.wishlist,
  BoardGameCopyWorkspaceFields.updatedAt,
  BoardGameCopyWorkspaceFields.addedAt,
];

final boardgameCopyWorkspaceGroupDefinitions = [
  groupFromField<BoardGameKind, BoardGameWorkspaceDto, String?>(
    BoardGameCopyWorkspaceFields.location,
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
  groupFromField<BoardGameKind, BoardGameWorkspaceDto, String?>(
    BoardGameCopyWorkspaceFields.condition,
    sidebarTitle: 'Conditions',
    icon: Icons.verified_outlined,
  ),
];

final boardgameCopyWorkspaceSortDefinitions = [
  LibrarySortDefinition<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameSortIds.status,
    entityScope: LibraryEntityScope.copy,
    compare: (left, right) {
      int rank(LibraryProjectionContext<BoardGameWorkspaceDto> ctx) {
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

final boardgameCopyWorkspaceDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  BoardGameFieldIds.status,
  BoardGameFieldIds.rating,
  BoardGameFieldIds.condition,
  BoardGameFieldIds.pricePaid,
  BoardGameFieldIds.location,
  BoardGameFieldIds.wishlist,
  BoardGameFieldIds.updatedAt,
};

final boardgameCopyWorkspaceColumnDefinitions = [
  LibraryColumnDefinition<BoardGameKind, BoardGameWorkspaceDto, String?>(
    id: BoardGameFieldIds.status,
    label: 'Status',
    getValue: BoardGameCopyWorkspaceFields.status.getValue,
    cellValue: (context) => Text(context.source.isWishlisted
        ? 'Wishlist'
        : (context.source.isOwned ? 'Owned' : '')),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<BoardGameKind, BoardGameWorkspaceDto, bool>(
    id: BoardGameFieldIds.wishlist,
    label: 'Wishlist',
    getValue: BoardGameCopyWorkspaceFields.wishlist.getValue,
    cellValue: (context) => Text(context.source.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<BoardGameKind, BoardGameWorkspaceDto, DateTime>(
    id: BoardGameFieldIds.updatedAt,
    label: 'Updated',
    getValue: BoardGameCopyWorkspaceFields.updatedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<BoardGameKind, BoardGameWorkspaceDto, DateTime?>(
    id: BoardGameFieldIds.addedAt,
    label: 'Added',
    getValue: BoardGameCopyWorkspaceFields.addedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, String?>(
    BoardGameCopyWorkspaceFields.location,
    group: 'Personal',
    defaultWidth: 118,
  ),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, String?>(
    BoardGameCopyWorkspaceFields.condition,
    group: 'Value',
    defaultWidth: 124,
  ),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, int?>(
    BoardGameCopyWorkspaceFields.pricePaid,
    cellValue: (context) =>
        Text(_formatCents(context.source.pricePaidCents, context.dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  LibraryColumnDefinition<BoardGameKind, BoardGameWorkspaceDto, int?>(
    id: BoardGameFieldIds.rating,
    label: 'Rating',
    getValue: BoardGameCopyWorkspaceFields.rating.getValue,
    cellValue: (context) => Text(context.dto.personal.rating?.toString() ?? ''),
    defaultWidth: 80,
  ),
];

final boardgameCopyWorkspaceSchema =
    LibraryEntityWorkspaceSchema<BoardGameKind, BoardGameWorkspaceDto>(
  kindNamespace: 'boardgame',
  entityScope: LibraryEntityScope.copy,
  fields: boardgameCopyWorkspaceFieldDefinitions,
  columns: boardgameCopyWorkspaceColumnDefinitions,
  sorts: boardgameCopyWorkspaceSortDefinitions,
  groups: boardgameCopyWorkspaceGroupDefinitions,
  primaryColumn: BoardGameFieldIds.status,
  defaultVisibleColumns: boardgameCopyWorkspaceDefaultVisibleColumns,
  defaultSort: BoardGameSortIds.status,
  defaultGroup: BoardGameGroupIds.condition,
  preferenceCodec: const BoardGamePreferenceCodec(),
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
