import 'package:collectarr_app/features/library/kinds/tv/data/tv_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_library_entry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:flutter/material.dart';

abstract final class TvLibraryEntryWorkspaceFields {
  static final condition =
      LibraryFieldDefinition<TvKind, TvWorkspaceDto, String?>(
    id: TvFieldIds.condition,
    label: 'Condition',
    getValue: (context) {
      final entry =
          TvLibraryEntryProjection.fromDispatch(context.source.libraryEntryDispatch);
      return entry is TvLibraryEntry ? entry.condition : null;
    },
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final location =
      LibraryFieldDefinition<TvKind, TvWorkspaceDto, String?>(
    id: TvFieldIds.location,
    label: 'Location',
    getValue: (context) => context.source.locationPath,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final pricePaid = LibraryFieldDefinition<TvKind, TvWorkspaceDto, int?>(
    id: TvFieldIds.pricePaid,
    label: 'Purchase Price',
    getValue: (context) => context.source.pricePaidCents,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final status = LibraryFieldDefinition<TvKind, TvWorkspaceDto, String?>(
    id: TvFieldIds.status,
    label: 'Status',
    getValue: (context) => context.source.isWishlisted
        ? 'wishlist'
        : (context.source.isEntry ? 'entry' : null),
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final rating = LibraryFieldDefinition<TvKind, TvWorkspaceDto, int?>(
    id: TvFieldIds.rating,
    label: 'Rating',
    getValue: (context) => context.dto.personal.rating,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final wishlist = LibraryFieldDefinition<TvKind, TvWorkspaceDto, bool>(
    id: TvFieldIds.wishlist,
    label: 'Wishlist',
    getValue: (context) => context.source.isWishlisted,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final updatedAt =
      LibraryFieldDefinition<TvKind, TvWorkspaceDto, DateTime>(
    id: TvFieldIds.updatedAt,
    label: 'Updated',
    getValue: (context) => context.source.updatedAt,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final addedAt =
      LibraryFieldDefinition<TvKind, TvWorkspaceDto, DateTime?>(
    id: TvFieldIds.addedAt,
    label: 'Added',
    getValue: (context) => context.source.addedAt,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final watchStatus =
      LibraryFieldDefinition<TvKind, TvWorkspaceDto, String?>(
    id: TvFieldIds.watchStatus,
    label: 'Watch Status',
    getValue: (context) => context.dto.personal.trackingStatus,
    entityScope: LibraryEntityScope.libraryEntry,
  );
}

final tvLibraryEntryWorkspaceFieldDefinitions = [
  TvLibraryEntryWorkspaceFields.condition,
  TvLibraryEntryWorkspaceFields.location,
  TvLibraryEntryWorkspaceFields.pricePaid,
];

final tvLibraryEntryWorkspaceGroupDefinitions = [
  groupFromField<TvKind, TvWorkspaceDto, String?>(
    TvLibraryEntryWorkspaceFields.condition,
    sidebarTitle: 'Conditions',
    icon: Icons.verified_outlined,
  ),
  groupFromField<TvKind, TvWorkspaceDto, String?>(
    TvLibraryEntryWorkspaceFields.location,
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
];

final tvLibraryEntryWorkspaceSortDefinitions = [
  LibrarySortDefinition<TvKind, TvWorkspaceDto>(
    id: TvSortIds.status,
    entityScope: LibraryEntityScope.libraryEntry,
    compare: (left, right) {
      int rank(LibraryProjectionContext<TvWorkspaceDto> ctx) {
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

final tvLibraryEntryWorkspaceDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  TvFieldIds.status,
  TvFieldIds.rating,
  TvFieldIds.condition,
  TvFieldIds.pricePaid,
  TvFieldIds.location,
  TvFieldIds.wishlist,
  TvFieldIds.updatedAt,
};

final tvLibraryEntryWorkspaceColumnDefinitions = [
  LibraryColumnDefinition<TvKind, TvWorkspaceDto, String?>(
    id: TvFieldIds.status,
    label: 'Status',
    getValue: TvLibraryEntryWorkspaceFields.status.getValue,
    cellValue: (context) => Text(context.source.isWishlisted
        ? 'Wishlist'
        : (context.source.isEntry ? 'Entry' : '')),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<TvKind, TvWorkspaceDto, bool>(
    id: TvFieldIds.wishlist,
    label: 'Wishlist',
    getValue: TvLibraryEntryWorkspaceFields.wishlist.getValue,
    cellValue: (context) => Text(context.source.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<TvKind, TvWorkspaceDto, DateTime>(
    id: TvFieldIds.updatedAt,
    label: 'Updated',
    getValue: TvLibraryEntryWorkspaceFields.updatedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<TvKind, TvWorkspaceDto, DateTime?>(
    id: TvFieldIds.addedAt,
    label: 'Added',
    getValue: TvLibraryEntryWorkspaceFields.addedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  columnFromField<TvKind, TvWorkspaceDto, String?>(
    TvLibraryEntryWorkspaceFields.location,
    group: 'Personal',
    defaultWidth: 118,
  ),
  columnFromField<TvKind, TvWorkspaceDto, String?>(
    TvLibraryEntryWorkspaceFields.condition,
    group: 'Value',
    defaultWidth: 124,
  ),
  columnFromField<TvKind, TvWorkspaceDto, int?>(
    TvLibraryEntryWorkspaceFields.pricePaid,
    cellValue: (context) =>
        Text(_formatCents(context.source.pricePaidCents, context.dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  LibraryColumnDefinition<TvKind, TvWorkspaceDto, int?>(
    id: TvFieldIds.rating,
    label: 'Rating',
    getValue: TvLibraryEntryWorkspaceFields.rating.getValue,
    cellValue: (context) => Text(context.dto.personal.rating?.toString() ?? ''),
    defaultWidth: 80,
  ),
];

final tvLibraryEntryWorkspaceSchema =
    LibraryEntityWorkspaceSchema<TvKind, TvWorkspaceDto>(
  kindNamespace: 'tv',
  entityScope: LibraryEntityScope.libraryEntry,
  fields: tvLibraryEntryWorkspaceFieldDefinitions,
  columns: tvLibraryEntryWorkspaceColumnDefinitions,
  sorts: tvLibraryEntryWorkspaceSortDefinitions,
  groups: tvLibraryEntryWorkspaceGroupDefinitions,
  primaryColumn: TvFieldIds.status,
  defaultVisibleColumns: tvLibraryEntryWorkspaceDefaultVisibleColumns,
  defaultSort: TvSortIds.status,
  defaultGroup: TvGroupIds.condition,
  preferenceCodec: const TvPreferenceCodec(),
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
