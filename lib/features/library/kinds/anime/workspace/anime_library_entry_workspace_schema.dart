import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_ids.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_library_entry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:flutter/material.dart';

abstract final class AnimeLibraryEntryWorkspaceFields {
  static final condition =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, String?>(
    id: AnimeFieldIds.condition,
    label: 'Condition',
    getValue: (context) {
      final entry = AnimeLibraryEntryProjection.fromDispatch(
          context.source.libraryEntryDispatch);
      return entry is AnimeLibraryEntry ? entry.personal.condition : null;
    },
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final location =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, String?>(
    id: AnimeFieldIds.location,
    label: 'Location',
    getValue: (context) => context.source.locationPath,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final pricePaid =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, int?>(
    id: AnimeFieldIds.pricePaid,
    label: 'Purchase Price',
    getValue: (context) => context.source.pricePaidCents,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final status =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, String?>(
    id: AnimeFieldIds.status,
    label: 'Status',
    getValue: (context) => context.source.isWishlisted
        ? 'wishlist'
        : (context.source.isEntry ? 'entry' : null),
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final rating =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, int?>(
    id: AnimeFieldIds.rating,
    label: 'Rating',
    getValue: (context) => context.dto.personal.rating,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final wishlist =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, bool>(
    id: AnimeFieldIds.wishlist,
    label: 'Wishlist',
    getValue: (context) => context.source.isWishlisted,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final updatedAt =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, DateTime>(
    id: AnimeFieldIds.updatedAt,
    label: 'Updated',
    getValue: (context) => context.source.updatedAt,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final addedAt =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, DateTime?>(
    id: AnimeFieldIds.addedAt,
    label: 'Added',
    getValue: (context) => context.source.addedAt,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final watchStatus =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, String?>(
    id: AnimeFieldIds.watchStatus,
    label: 'Watch Status',
    getValue: (context) => context.dto.personal.trackingStatus,
    entityScope: LibraryEntityScope.libraryEntry,
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
    entityScope: LibraryEntityScope.libraryEntry,
    compare: (left, right) {
      int rank(LibraryProjectionContext<AnimeWorkspaceDto> ctx) {
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
    cellValue: (context) => Text(context.source.isWishlisted
        ? 'Wishlist'
        : (context.source.isEntry ? 'Entry' : '')),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<AnimeKind, AnimeWorkspaceDto, bool>(
    id: AnimeFieldIds.wishlist,
    label: 'Wishlist',
    getValue: AnimeLibraryEntryWorkspaceFields.wishlist.getValue,
    cellValue: (context) => Text(context.source.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<AnimeKind, AnimeWorkspaceDto, DateTime>(
    id: AnimeFieldIds.updatedAt,
    label: 'Updated',
    getValue: AnimeLibraryEntryWorkspaceFields.updatedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<AnimeKind, AnimeWorkspaceDto, DateTime?>(
    id: AnimeFieldIds.addedAt,
    label: 'Added',
    getValue: AnimeLibraryEntryWorkspaceFields.addedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.addedAt)),
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
        Text(_formatCents(context.source.pricePaidCents, context.dto.currency)),
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
    LibraryEntityWorkspaceSchema<AnimeKind, AnimeWorkspaceDto>(
  kindNamespace: 'anime',
  entityScope: LibraryEntityScope.libraryEntry,
  fields: animeLibraryEntryWorkspaceFieldDefinitions,
  columns: animeLibraryEntryWorkspaceColumnDefinitions,
  sorts: animeLibraryEntryWorkspaceSortDefinitions,
  groups: animeLibraryEntryWorkspaceGroupDefinitions,
  primaryColumn: AnimeFieldIds.status,
  defaultVisibleColumns: animeLibraryEntryWorkspaceDefaultVisibleColumns,
  defaultSort: AnimeSortIds.status,
  defaultGroup: AnimeGroupIds.condition,
  preferenceCodec: const AnimePreferenceCodec(),
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
