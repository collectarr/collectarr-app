import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_ids.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_library_entry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:flutter/material.dart';

abstract final class BoardGameLibraryEntryWorkspaceFields {
  static final condition =
      LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto, String?>(
    id: BoardGameFieldIds.condition,
    label: 'Condition',
    getValue: (context) {
      final entry = BoardGameLibraryEntryProjection.fromDispatch(
          context.source.libraryEntryDispatch);
      return entry is BoardGameLibraryEntry ? entry.personal.condition : null;
    },
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final location =
      LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto, String?>(
    id: BoardGameFieldIds.location,
    label: 'Location',
    getValue: (context) => context.source.locationPath,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final pricePaid =
      LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto, int?>(
    id: BoardGameFieldIds.pricePaid,
    label: 'Purchase Price',
    getValue: (context) => context.source.pricePaidCents,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final status =
      LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto, String?>(
    id: BoardGameFieldIds.status,
    label: 'Status',
    getValue: (context) => context.source.isWishlisted
        ? 'wishlist'
        : (context.source.isEntry ? 'entry' : null),
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final rating =
      LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto, int?>(
    id: BoardGameFieldIds.rating,
    label: 'Rating',
    getValue: (context) => context.dto.personal.rating,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final wishlist =
      LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto, bool>(
    id: BoardGameFieldIds.wishlist,
    label: 'Wishlist',
    getValue: (context) => context.source.isWishlisted,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final updatedAt =
      LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto, DateTime>(
    id: BoardGameFieldIds.updatedAt,
    label: 'Updated',
    getValue: (context) => context.source.updatedAt,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final addedAt =
      LibraryFieldDefinition<BoardGameKind, BoardGameWorkspaceDto, DateTime?>(
    id: BoardGameFieldIds.addedAt,
    label: 'Added',
    getValue: (context) => context.source.addedAt,
    entityScope: LibraryEntityScope.libraryEntry,
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
    entityScope: LibraryEntityScope.libraryEntry,
    compare: (left, right) {
      int rank(LibraryProjectionContext<BoardGameWorkspaceDto> ctx) {
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
    cellValue: (context) => Text(context.source.isWishlisted
        ? 'Wishlist'
        : (context.source.isEntry ? 'Entry' : '')),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<BoardGameKind, BoardGameWorkspaceDto, bool>(
    id: BoardGameFieldIds.wishlist,
    label: 'Wishlist',
    getValue: BoardGameLibraryEntryWorkspaceFields.wishlist.getValue,
    cellValue: (context) => Text(context.source.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<BoardGameKind, BoardGameWorkspaceDto, DateTime>(
    id: BoardGameFieldIds.updatedAt,
    label: 'Updated',
    getValue: BoardGameLibraryEntryWorkspaceFields.updatedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<BoardGameKind, BoardGameWorkspaceDto, DateTime?>(
    id: BoardGameFieldIds.addedAt,
    label: 'Added',
    getValue: BoardGameLibraryEntryWorkspaceFields.addedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.addedAt)),
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
        Text(_formatCents(context.source.pricePaidCents, context.dto.currency)),
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
    LibraryEntityWorkspaceSchema<BoardGameKind, BoardGameWorkspaceDto>(
  kindNamespace: 'boardgame',
  entityScope: LibraryEntityScope.libraryEntry,
  fields: boardgameLibraryEntryWorkspaceFieldDefinitions,
  columns: boardgameLibraryEntryWorkspaceColumnDefinitions,
  sorts: boardgameLibraryEntryWorkspaceSortDefinitions,
  groups: boardgameLibraryEntryWorkspaceGroupDefinitions,
  primaryColumn: BoardGameFieldIds.status,
  defaultVisibleColumns: boardgameLibraryEntryWorkspaceDefaultVisibleColumns,
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
