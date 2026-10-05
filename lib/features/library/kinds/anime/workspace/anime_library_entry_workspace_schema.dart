import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_ids.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_library_entry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_schema.dart';
import 'package:flutter/material.dart';

abstract final class AnimeLibraryEntryWorkspaceFields {
  static final condition =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, String?>(
    id: AnimeFieldIds.condition,
    label: 'Condition',
    getValue: (context) {
      final entry = AnimeLibraryEntryProjection.fromDispatch(
          context.item.libraryEntryDispatch);
      return entry is AnimeLibraryEntry ? entry.personal.condition : null;
    },
  );

  static final location =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, String?>(
    id: AnimeFieldIds.location,
    label: 'Location',
    getValue: (context) => context.personal.locationPath,
  );

  static final pricePaid =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, int?>(
    id: AnimeFieldIds.pricePaid,
    label: 'Purchase Price',
    getValue: (context) => context.item.entrySummary?.pricePaidCents,
  );

  static final status =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, String?>(
    id: AnimeFieldIds.status,
    label: 'Status',
    getValue: (context) => context.personal.isWishlisted
        ? 'wishlist'
        : ((context.item.entrySummary != null) ? 'entry' : null),
  );

  static final rating =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, int?>(
    id: AnimeFieldIds.rating,
    label: 'Rating',
    getValue: (context) => context.dto.personal.rating,
  );

  static final wishlist =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, bool>(
    id: AnimeFieldIds.wishlist,
    label: 'Wishlist',
    getValue: (context) => context.personal.isWishlisted,
  );

  static final updatedAt =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, DateTime>(
    id: AnimeFieldIds.updatedAt,
    label: 'Updated',
    getValue: (context) => context.updatedAt,
  );

  static final addedAt =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, DateTime?>(
    id: AnimeFieldIds.addedAt,
    label: 'Added',
    getValue: (context) => context.addedAt,
  );

  static final watchStatus =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, String?>(
    id: AnimeFieldIds.watchStatus,
    label: 'Watch Status',
    getValue: (context) => context.dto.personal.trackingStatus,
  );
}

final animeLibraryEntryWorkspaceFieldDefinitions = [
  AnimeLibraryEntryWorkspaceFields.condition,
  AnimeLibraryEntryWorkspaceFields.location,
  AnimeLibraryEntryWorkspaceFields.pricePaid,
];

final animeLibraryEntryWorkspaceGroupDefinitions = [
  groupFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeLibraryEntryWorkspaceFields.condition,
    sidebarTitle: 'Conditions',
    icon: Icons.verified_outlined,
  ),
  groupFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeLibraryEntryWorkspaceFields.location,
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
];

final animeLibraryEntryWorkspaceSortDefinitions = [
  LibrarySortDefinition<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeSortIds.status,
    compare: (left, right) {
      int rank(LibraryProjectionContext<AnimeWorkspaceDto> ctx) {
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

final animeLibraryEntryWorkspaceDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  AnimeFieldIds.status,
  AnimeFieldIds.rating,
  AnimeFieldIds.condition,
  AnimeFieldIds.pricePaid,
  AnimeFieldIds.location,
  AnimeFieldIds.wishlist,
  AnimeFieldIds.updatedAt,
};

final animeLibraryEntryWorkspaceColumnDefinitions = [
  LibraryColumnDefinition<AnimeKind, AnimeWorkspaceDto, String?>(
    id: AnimeFieldIds.status,
    label: 'Status',
    getValue: AnimeLibraryEntryWorkspaceFields.status.getValue,
    cellValue: (context) => Text(context.personal.isWishlisted
        ? 'Wishlist'
        : ((context.item.entrySummary != null) ? 'Entry' : '')),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<AnimeKind, AnimeWorkspaceDto, bool>(
    id: AnimeFieldIds.wishlist,
    label: 'Wishlist',
    getValue: AnimeLibraryEntryWorkspaceFields.wishlist.getValue,
    cellValue: (context) => Text(context.personal.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<AnimeKind, AnimeWorkspaceDto, DateTime>(
    id: AnimeFieldIds.updatedAt,
    label: 'Updated',
    getValue: AnimeLibraryEntryWorkspaceFields.updatedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<AnimeKind, AnimeWorkspaceDto, DateTime?>(
    id: AnimeFieldIds.addedAt,
    label: 'Added',
    getValue: AnimeLibraryEntryWorkspaceFields.addedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeLibraryEntryWorkspaceFields.location,
    group: 'Personal',
    defaultWidth: 118,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeLibraryEntryWorkspaceFields.condition,
    group: 'Value',
    defaultWidth: 124,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, int?>(
    AnimeLibraryEntryWorkspaceFields.pricePaid,
    cellValue: (context) =>
        Text(_formatCents(context.item.entrySummary?.pricePaidCents, context.dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  LibraryColumnDefinition<AnimeKind, AnimeWorkspaceDto, int?>(
    id: AnimeFieldIds.rating,
    label: 'Rating',
    getValue: AnimeLibraryEntryWorkspaceFields.rating.getValue,
    cellValue: (context) => Text(context.dto.personal.rating?.toString() ?? ''),
    defaultWidth: 80,
  ),
];

final animeLibraryEntryWorkspaceSchema =
    LibraryWorkspaceSchema<AnimeKind, AnimeWorkspaceDto>(
  kindNamespace: 'anime',
  fields: animeLibraryEntryWorkspaceFieldDefinitions,
  columns: animeLibraryEntryWorkspaceColumnDefinitions,
  sorts: animeLibraryEntryWorkspaceSortDefinitions,
  groups: animeLibraryEntryWorkspaceGroupDefinitions,
  primaryColumn: AnimeFieldIds.status,
  defaultVisibleColumns: animeLibraryEntryWorkspaceDefaultVisibleColumns,
  defaultSort: AnimeSortIds.status,
  defaultGroup: AnimeGroupIds.condition,
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
