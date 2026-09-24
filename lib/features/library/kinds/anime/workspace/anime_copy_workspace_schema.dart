import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_ids.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_owned_item.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:flutter/material.dart';

abstract final class AnimeCopyWorkspaceFields {
  static final condition =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, String?>(
    id: AnimeFieldIds.condition,
    label: 'Condition',
    getValue: (context) {
      final owned = AnimeOwnedItemProjection.fromDispatch(
          context.source.ownedItemDispatch);
      return owned is AnimeOwnedItem ? owned.condition : null;
    },
    entityScope: LibraryEntityScope.copy,
  );

  static final location =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, String?>(
    id: AnimeFieldIds.location,
    label: 'Location',
    getValue: (context) => context.source.locationPath,
    entityScope: LibraryEntityScope.copy,
  );

  static final pricePaid =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, int?>(
    id: AnimeFieldIds.pricePaid,
    label: 'Purchase Price',
    getValue: (context) => context.source.pricePaidCents,
    entityScope: LibraryEntityScope.copy,
  );

  static final status =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, String?>(
    id: AnimeFieldIds.status,
    label: 'Status',
    getValue: (context) => context.source.isWishlisted
        ? 'wishlist'
        : (context.source.isOwned ? 'owned' : null),
    entityScope: LibraryEntityScope.copy,
  );

  static final rating =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, int?>(
    id: AnimeFieldIds.rating,
    label: 'Rating',
    getValue: (context) => context.dto.personal.rating,
    entityScope: LibraryEntityScope.copy,
  );

  static final wishlist =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, bool>(
    id: AnimeFieldIds.wishlist,
    label: 'Wishlist',
    getValue: (context) => context.source.isWishlisted,
    entityScope: LibraryEntityScope.copy,
  );

  static final updatedAt =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, DateTime>(
    id: AnimeFieldIds.updatedAt,
    label: 'Updated',
    getValue: (context) => context.source.updatedAt,
    entityScope: LibraryEntityScope.copy,
  );

  static final addedAt =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, DateTime?>(
    id: AnimeFieldIds.addedAt,
    label: 'Added',
    getValue: (context) => context.source.addedAt,
    entityScope: LibraryEntityScope.copy,
  );

  static final watchStatus =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, String?>(
    id: AnimeFieldIds.watchStatus,
    label: 'Watch Status',
    getValue: (context) => context.dto.personal.trackingStatus,
    entityScope: LibraryEntityScope.copy,
  );
}

final animeCopyWorkspaceFieldDefinitions = [
  AnimeCopyWorkspaceFields.condition,
  AnimeCopyWorkspaceFields.location,
  AnimeCopyWorkspaceFields.pricePaid,
];

final animeCopyWorkspaceGroupDefinitions = [
  groupFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeCopyWorkspaceFields.condition,
    sidebarTitle: 'Conditions',
    icon: Icons.verified_outlined,
  ),
  groupFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeCopyWorkspaceFields.location,
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
];

final animeCopyWorkspaceSortDefinitions = [
  LibrarySortDefinition<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeSortIds.status,
    entityScope: LibraryEntityScope.copy,
    compare: (left, right) {
      int rank(LibraryProjectionContext<AnimeWorkspaceDto> ctx) {
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

final animeCopyWorkspaceDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  AnimeFieldIds.status,
  AnimeFieldIds.rating,
  AnimeFieldIds.condition,
  AnimeFieldIds.pricePaid,
  AnimeFieldIds.location,
  AnimeFieldIds.wishlist,
  AnimeFieldIds.updatedAt,
};

final animeCopyWorkspaceColumnDefinitions = [
  LibraryColumnDefinition<AnimeKind, AnimeWorkspaceDto, String?>(
    id: AnimeFieldIds.status,
    label: 'Status',
    getValue: AnimeCopyWorkspaceFields.status.getValue,
    cellValue: (context) => Text(context.source.isWishlisted
        ? 'Wishlist'
        : (context.source.isOwned ? 'Owned' : '')),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<AnimeKind, AnimeWorkspaceDto, bool>(
    id: AnimeFieldIds.wishlist,
    label: 'Wishlist',
    getValue: AnimeCopyWorkspaceFields.wishlist.getValue,
    cellValue: (context) => Text(context.source.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<AnimeKind, AnimeWorkspaceDto, DateTime>(
    id: AnimeFieldIds.updatedAt,
    label: 'Updated',
    getValue: AnimeCopyWorkspaceFields.updatedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<AnimeKind, AnimeWorkspaceDto, DateTime?>(
    id: AnimeFieldIds.addedAt,
    label: 'Added',
    getValue: AnimeCopyWorkspaceFields.addedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeCopyWorkspaceFields.location,
    group: 'Personal',
    defaultWidth: 118,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeCopyWorkspaceFields.condition,
    group: 'Value',
    defaultWidth: 124,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, int?>(
    AnimeCopyWorkspaceFields.pricePaid,
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
    getValue: AnimeCopyWorkspaceFields.rating.getValue,
    cellValue: (context) => Text(context.dto.personal.rating?.toString() ?? ''),
    defaultWidth: 80,
  ),
];

final animeCopyWorkspaceSchema =
    LibraryEntityWorkspaceSchema<AnimeKind, AnimeWorkspaceDto>(
  kindNamespace: 'anime',
  entityScope: LibraryEntityScope.copy,
  fields: animeCopyWorkspaceFieldDefinitions,
  columns: animeCopyWorkspaceColumnDefinitions,
  sorts: animeCopyWorkspaceSortDefinitions,
  groups: animeCopyWorkspaceGroupDefinitions,
  primaryColumn: AnimeFieldIds.status,
  defaultVisibleColumns: animeCopyWorkspaceDefaultVisibleColumns,
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
