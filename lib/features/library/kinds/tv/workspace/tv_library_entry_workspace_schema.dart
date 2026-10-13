import 'package:collectarr_app/features/library/kinds/tv/data/tv_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/tv/config/tv_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_library_entry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_schema.dart';
import 'package:flutter/material.dart';

abstract final class TvLibraryEntryWorkspaceFields {
  static final condition =
      LibraryFieldDefinition<TvKind, TvWorkspaceDto, String?>(
    id: TvFieldIds.condition,
    metadata: TvWorkspaceFieldMetadata.condition,
    getValue: (context) {
      final entry = TvLibraryEntryProjection.fromDispatch(
          context.item.libraryEntryDispatch);
      return entry is TvLibraryEntry ? entry.personal.condition : null;
    },
  );

  static final location =
      LibraryFieldDefinition<TvKind, TvWorkspaceDto, String?>(
    id: TvFieldIds.location,
    metadata: TvWorkspaceFieldMetadata.location,
    getValue: (context) => context.personal.locationPath,
  );

  static final pricePaid = LibraryFieldDefinition<TvKind, TvWorkspaceDto, int?>(
    id: TvFieldIds.pricePaid,
    metadata: TvWorkspaceFieldMetadata.pricePaid,
    getValue: (context) => context.item.entrySummary?.pricePaidCents,
  );

  static final status = LibraryFieldDefinition<TvKind, TvWorkspaceDto, String?>(
    id: TvFieldIds.status,
    metadata: TvWorkspaceFieldMetadata.status,
    getValue: (context) => context.personal.isWishlisted
        ? 'wishlist'
        : ((context.item.entrySummary != null) ? 'entry' : null),
  );

  static final rating = LibraryFieldDefinition<TvKind, TvWorkspaceDto, int?>(
    id: TvFieldIds.rating,
    metadata: TvWorkspaceFieldMetadata.rating,
    getValue: (context) => context.dto.personal.rating,
  );

  static final wishlist = LibraryFieldDefinition<TvKind, TvWorkspaceDto, bool>(
    id: TvFieldIds.wishlist,
    metadata: TvWorkspaceFieldMetadata.wishlist,
    getValue: (context) => context.personal.isWishlisted,
  );

  static final updatedAt =
      LibraryFieldDefinition<TvKind, TvWorkspaceDto, DateTime>(
    id: TvFieldIds.updatedAt,
    metadata: TvWorkspaceFieldMetadata.updatedAt,
    getValue: (context) => context.updatedAt,
  );

  static final addedAt =
      LibraryFieldDefinition<TvKind, TvWorkspaceDto, DateTime?>(
    id: TvFieldIds.addedAt,
    metadata: TvWorkspaceFieldMetadata.addedAt,
    getValue: (context) => context.addedAt,
  );

  static final watchStatus =
      LibraryFieldDefinition<TvKind, TvWorkspaceDto, String?>(
    id: TvFieldIds.watchStatus,
    metadata: TvWorkspaceFieldMetadata.watchStatus,
    getValue: (context) => context.dto.personal.trackingStatus,
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
    compare: (left, right) {
      int rank(LibraryProjectionContext<TvWorkspaceDto> ctx) {
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
    metadata: TvWorkspaceFieldMetadata.status,
    getValue: TvLibraryEntryWorkspaceFields.status.getValue,
    cellValue: (context) => Text(context.personal.isWishlisted
        ? 'Wishlist'
        : ((context.item.entrySummary != null) ? 'Entry' : '')),
    allowSortInteraction: false,
    allowGroupInteraction: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<TvKind, TvWorkspaceDto, bool>(
    id: TvFieldIds.wishlist,
    metadata: TvWorkspaceFieldMetadata.wishlist,
    getValue: TvLibraryEntryWorkspaceFields.wishlist.getValue,
    cellValue: (context) =>
        Text(context.personal.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<TvKind, TvWorkspaceDto, DateTime>(
    id: TvFieldIds.updatedAt,
    metadata: TvWorkspaceFieldMetadata.updatedAt,
    getValue: TvLibraryEntryWorkspaceFields.updatedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<TvKind, TvWorkspaceDto, DateTime?>(
    id: TvFieldIds.addedAt,
    metadata: TvWorkspaceFieldMetadata.addedAt,
    getValue: TvLibraryEntryWorkspaceFields.addedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.addedAt)),
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
    cellValue: (context) => Text(_formatCents(
        context.item.entrySummary?.pricePaidCents, context.dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  LibraryColumnDefinition<TvKind, TvWorkspaceDto, int?>(
    id: TvFieldIds.rating,
    metadata: TvWorkspaceFieldMetadata.rating,
    getValue: TvLibraryEntryWorkspaceFields.rating.getValue,
    cellValue: (context) => Text(context.dto.personal.rating?.toString() ?? ''),
    defaultWidth: 80,
  ),
];

final tvLibraryEntryWorkspaceSchema =
    LibraryWorkspaceSchema<TvKind, TvWorkspaceDto>(
  kindNamespace: 'tv',
  fields: tvLibraryEntryWorkspaceFieldDefinitions,
  columns: tvLibraryEntryWorkspaceColumnDefinitions,
  sorts: tvLibraryEntryWorkspaceSortDefinitions,
  groups: tvLibraryEntryWorkspaceGroupDefinitions,
  primaryColumn: TvFieldIds.status,
  defaultVisibleColumns: tvLibraryEntryWorkspaceDefaultVisibleColumns,
  defaultSort: TvSortIds.status,
  defaultGroup: TvGroupIds.condition,
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
