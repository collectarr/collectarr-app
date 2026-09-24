import 'package:collectarr_app/features/library/kinds/tv/data/tv_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_owned_item.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:flutter/material.dart';

abstract final class TvCopyWorkspaceFields {
  static final condition =
      LibraryFieldDefinition<TvKind, TvWorkspaceDto, String?>(
    id: TvFieldIds.condition,
    label: 'Condition',
    getValue: (context) {
      final owned =
          TvOwnedItemProjection.fromDispatch(context.source.ownedItemDispatch);
      return owned is TvOwnedItem ? owned.condition : null;
    },
    entityScope: LibraryEntityScope.copy,
  );

  static final location =
      LibraryFieldDefinition<TvKind, TvWorkspaceDto, String?>(
    id: TvFieldIds.location,
    label: 'Location',
    getValue: (context) => context.source.locationPath,
    entityScope: LibraryEntityScope.copy,
  );

  static final pricePaid = LibraryFieldDefinition<TvKind, TvWorkspaceDto, int?>(
    id: TvFieldIds.pricePaid,
    label: 'Purchase Price',
    getValue: (context) => context.source.pricePaidCents,
    entityScope: LibraryEntityScope.copy,
  );

  static final status = LibraryFieldDefinition<TvKind, TvWorkspaceDto, String?>(
    id: TvFieldIds.status,
    label: 'Status',
    getValue: (context) => context.source.isWishlisted
        ? 'wishlist'
        : (context.source.isOwned ? 'owned' : null),
    entityScope: LibraryEntityScope.copy,
  );

  static final rating = LibraryFieldDefinition<TvKind, TvWorkspaceDto, int?>(
    id: TvFieldIds.rating,
    label: 'Rating',
    getValue: (context) => context.dto.personal.rating,
    entityScope: LibraryEntityScope.copy,
  );

  static final wishlist = LibraryFieldDefinition<TvKind, TvWorkspaceDto, bool>(
    id: TvFieldIds.wishlist,
    label: 'Wishlist',
    getValue: (context) => context.source.isWishlisted,
    entityScope: LibraryEntityScope.copy,
  );

  static final updatedAt =
      LibraryFieldDefinition<TvKind, TvWorkspaceDto, DateTime>(
    id: TvFieldIds.updatedAt,
    label: 'Updated',
    getValue: (context) => context.source.updatedAt,
    entityScope: LibraryEntityScope.copy,
  );

  static final addedAt =
      LibraryFieldDefinition<TvKind, TvWorkspaceDto, DateTime?>(
    id: TvFieldIds.addedAt,
    label: 'Added',
    getValue: (context) => context.source.addedAt,
    entityScope: LibraryEntityScope.copy,
  );

  static final watchStatus =
      LibraryFieldDefinition<TvKind, TvWorkspaceDto, String?>(
    id: TvFieldIds.watchStatus,
    label: 'Watch Status',
    getValue: (context) => context.dto.personal.trackingStatus,
    entityScope: LibraryEntityScope.copy,
  );
}

final tvCopyWorkspaceFieldDefinitions = [
  TvCopyWorkspaceFields.condition,
  TvCopyWorkspaceFields.location,
  TvCopyWorkspaceFields.pricePaid,
];

final tvCopyWorkspaceGroupDefinitions = [
  groupFromField<TvKind, TvWorkspaceDto, String?>(
    TvCopyWorkspaceFields.condition,
    sidebarTitle: 'Conditions',
    icon: Icons.verified_outlined,
  ),
  groupFromField<TvKind, TvWorkspaceDto, String?>(
    TvCopyWorkspaceFields.location,
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
];

final tvCopyWorkspaceSortDefinitions = [
  LibrarySortDefinition<TvKind, TvWorkspaceDto>(
    id: TvSortIds.status,
    entityScope: LibraryEntityScope.copy,
    compare: (left, right) {
      int rank(LibraryProjectionContext<TvWorkspaceDto> ctx) {
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

final tvCopyWorkspaceDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  TvFieldIds.status,
  TvFieldIds.rating,
  TvFieldIds.condition,
  TvFieldIds.pricePaid,
  TvFieldIds.location,
  TvFieldIds.wishlist,
  TvFieldIds.updatedAt,
};

final tvCopyWorkspaceColumnDefinitions = [
  LibraryColumnDefinition<TvKind, TvWorkspaceDto, String?>(
    id: TvFieldIds.status,
    label: 'Status',
    getValue: TvCopyWorkspaceFields.status.getValue,
    cellValue: (context) => Text(context.source.isWishlisted
        ? 'Wishlist'
        : (context.source.isOwned ? 'Owned' : '')),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<TvKind, TvWorkspaceDto, bool>(
    id: TvFieldIds.wishlist,
    label: 'Wishlist',
    getValue: TvCopyWorkspaceFields.wishlist.getValue,
    cellValue: (context) => Text(context.source.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<TvKind, TvWorkspaceDto, DateTime>(
    id: TvFieldIds.updatedAt,
    label: 'Updated',
    getValue: TvCopyWorkspaceFields.updatedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<TvKind, TvWorkspaceDto, DateTime?>(
    id: TvFieldIds.addedAt,
    label: 'Added',
    getValue: TvCopyWorkspaceFields.addedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  columnFromField<TvKind, TvWorkspaceDto, String?>(
    TvCopyWorkspaceFields.location,
    group: 'Personal',
    defaultWidth: 118,
  ),
  columnFromField<TvKind, TvWorkspaceDto, String?>(
    TvCopyWorkspaceFields.condition,
    group: 'Value',
    defaultWidth: 124,
  ),
  columnFromField<TvKind, TvWorkspaceDto, int?>(
    TvCopyWorkspaceFields.pricePaid,
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
    getValue: TvCopyWorkspaceFields.rating.getValue,
    cellValue: (context) => Text(context.dto.personal.rating?.toString() ?? ''),
    defaultWidth: 80,
  ),
];

final tvCopyWorkspaceSchema =
    LibraryEntityWorkspaceSchema<TvKind, TvWorkspaceDto>(
  kindNamespace: 'tv',
  entityScope: LibraryEntityScope.copy,
  fields: tvCopyWorkspaceFieldDefinitions,
  columns: tvCopyWorkspaceColumnDefinitions,
  sorts: tvCopyWorkspaceSortDefinitions,
  groups: tvCopyWorkspaceGroupDefinitions,
  primaryColumn: TvFieldIds.status,
  defaultVisibleColumns: tvCopyWorkspaceDefaultVisibleColumns,
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
