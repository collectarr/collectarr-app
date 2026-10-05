import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_ids.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_library_entry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_schema.dart';
import 'package:flutter/material.dart';

abstract final class BoardGameLibraryEntryWorkspaceFields {
  static final condition =
      LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto, String?>(
    id: BoardGameFieldIds.condition,
    label: 'Condition',
    getValue: (context) {
      final entry = BoardGameLibraryEntryProjection.fromDispatch(
          context.item.libraryEntryDispatch);
      return entry is BoardGameLibraryEntry ? entry.personal.condition : null;
    },
  );

  static final location =
      LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto, String?>(
    id: BoardGameFieldIds.location,
    label: 'Location',
    getValue: (context) => context.personal.locationPath,
  );

  static final pricePaid =
      LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto, int?>(
    id: BoardGameFieldIds.pricePaid,
    label: 'Purchase Price',
    getValue: (context) => context.item.entrySummary?.pricePaidCents,
  );

  static final status =
      LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto, String?>(
    id: BoardGameFieldIds.status,
    label: 'Status',
    getValue: (context) => context.personal.isWishlisted
        ? 'wishlist'
        : ((context.item.entrySummary != null) ? 'entry' : null),
  );

  static final rating =
      LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto, int?>(
    id: BoardGameFieldIds.rating,
    label: 'Rating',
    getValue: (context) => context.dto.personal.rating,
  );

  static final wishlist =
      LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto, bool>(
    id: BoardGameFieldIds.wishlist,
    label: 'Wishlist',
    getValue: (context) => context.personal.isWishlisted,
  );

  static final updatedAt =
      LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto, DateTime>(
    id: BoardGameFieldIds.updatedAt,
    label: 'Updated',
    getValue: (context) => context.updatedAt,
  );

  static final addedAt =
      LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto, DateTime?>(
    id: BoardGameFieldIds.addedAt,
    label: 'Added',
    getValue: (context) => context.addedAt,
  );
}

final boardgameLibraryEntryWorkspaceFieldDefinitions = [
  BoardGameLibraryEntryWorkspaceFields.status,
  BoardGameLibraryEntryWorkspaceFields.condition,
  BoardGameLibraryEntryWorkspaceFields.location,
  BoardGameLibraryEntryWorkspaceFields.pricePaid,
  BoardGameLibraryEntryWorkspaceFields.rating,
  BoardGameLibraryEntryWorkspaceFields.wishlist,
  BoardGameLibraryEntryWorkspaceFields.updatedAt,
  BoardGameLibraryEntryWorkspaceFields.addedAt,
];

final boardgameLibraryEntryWorkspaceGroupDefinitions = [
  groupFromField<BoardGameKind, BoardGameWorkspaceDto, String?>(
    BoardGameLibraryEntryWorkspaceFields.location,
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
  groupFromField<BoardGameKind, BoardGameWorkspaceDto, String?>(
    BoardGameLibraryEntryWorkspaceFields.condition,
    sidebarTitle: 'Conditions',
    icon: Icons.verified_outlined,
  ),
];

final boardgameLibraryEntryWorkspaceSortDefinitions = [
  LibrarySortDefinition<BoardGameKind, BoardGameWorkspaceDto>(
    id: BoardGameSortIds.status,
    compare: (left, right) {
      int rank(LibraryProjectionContext<BoardGameWorkspaceDto> ctx) {
        if ((ctx.item.entrySummary != null)) return 0;
        if (ctx.personal.isWishlisted) return 1;
        return 2;
      }

      final res = rank(left).compareTo(rank(right));
      return res != 0 ? res : left.dto.title.compareTo(right.dto.title);
    },
    label: 'Status',
  ),
];

final boardgameLibraryEntryWorkspaceDefaultVisibleColumns =
    <LibraryFieldIdRuntime>{
  BoardGameFieldIds.status,
  BoardGameFieldIds.rating,
  BoardGameFieldIds.condition,
  BoardGameFieldIds.pricePaid,
  BoardGameFieldIds.location,
  BoardGameFieldIds.wishlist,
  BoardGameFieldIds.updatedAt,
};

final boardgameLibraryEntryWorkspaceColumnDefinitions = [
  LibraryColumnDefinition<BoardGameKind, BoardGameWorkspaceDto, String?>(
    id: BoardGameFieldIds.status,
    label: 'Status',
    getValue: BoardGameLibraryEntryWorkspaceFields.status.getValue,
    cellValue: (context) => Text(context.personal.isWishlisted
        ? 'Wishlist'
        : ((context.item.entrySummary != null) ? 'Entry' : '')),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<BoardGameKind, BoardGameWorkspaceDto, bool>(
    id: BoardGameFieldIds.wishlist,
    label: 'Wishlist',
    getValue: BoardGameLibraryEntryWorkspaceFields.wishlist.getValue,
    cellValue: (context) => Text(context.personal.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<BoardGameKind, BoardGameWorkspaceDto, DateTime>(
    id: BoardGameFieldIds.updatedAt,
    label: 'Updated',
    getValue: BoardGameLibraryEntryWorkspaceFields.updatedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<BoardGameKind, BoardGameWorkspaceDto, DateTime?>(
    id: BoardGameFieldIds.addedAt,
    label: 'Added',
    getValue: BoardGameLibraryEntryWorkspaceFields.addedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, String?>(
    BoardGameLibraryEntryWorkspaceFields.location,
    group: 'Personal',
    defaultWidth: 118,
  ),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, String?>(
    BoardGameLibraryEntryWorkspaceFields.condition,
    group: 'Value',
    defaultWidth: 124,
  ),
  columnFromField<BoardGameKind, BoardGameWorkspaceDto, int?>(
    BoardGameLibraryEntryWorkspaceFields.pricePaid,
    cellValue: (context) =>
        Text(_formatCents(context.item.entrySummary?.pricePaidCents, context.dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  LibraryColumnDefinition<BoardGameKind, BoardGameWorkspaceDto, int?>(
    id: BoardGameFieldIds.rating,
    label: 'Rating',
    getValue: BoardGameLibraryEntryWorkspaceFields.rating.getValue,
    cellValue: (context) => Text(context.dto.personal.rating?.toString() ?? ''),
    defaultWidth: 80,
  ),
];

final boardgameLibraryEntryWorkspaceSchema =
    LibraryWorkspaceSchema<BoardGameKind, BoardGameWorkspaceDto>(
  kindNamespace: 'boardgame',
  fields: boardgameLibraryEntryWorkspaceFieldDefinitions,
  columns: boardgameLibraryEntryWorkspaceColumnDefinitions,
  sorts: boardgameLibraryEntryWorkspaceSortDefinitions,
  groups: boardgameLibraryEntryWorkspaceGroupDefinitions,
  primaryColumn: BoardGameFieldIds.status,
  defaultVisibleColumns: boardgameLibraryEntryWorkspaceDefaultVisibleColumns,
  defaultSort: BoardGameSortIds.status,
  defaultGroup: BoardGameGroupIds.condition,
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
