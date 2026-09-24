import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_ids.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_owned_item.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:flutter/material.dart';

abstract final class MangaCopyWorkspaceFields {
  static final condition =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.condition,
    label: 'Condition',
    getValue: (context) {
      final owned = MangaOwnedItemProjection.fromDispatch(
          context.source.ownedItemDispatch);
      return owned is MangaOwnedItem ? owned.condition : null;
    },
    entityScope: LibraryEntityScope.copy,
  );

  static final location =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.location,
    label: 'Location',
    getValue: (context) => context.source.locationPath,
    entityScope: LibraryEntityScope.copy,
  );

  static final pricePaid =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, int?>(
    id: MangaFieldIds.pricePaid,
    label: 'Purchase Price',
    getValue: (context) => context.source.pricePaidCents,
    entityScope: LibraryEntityScope.copy,
  );

  static final status =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.status,
    label: 'Status',
    getValue: (context) => context.source.isWishlisted
        ? 'wishlist'
        : (context.source.isOwned ? 'owned' : null),
    entityScope: LibraryEntityScope.copy,
  );

  static final rating =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, int?>(
    id: MangaFieldIds.rating,
    label: 'Rating',
    getValue: (context) => context.dto.personal.rating,
    entityScope: LibraryEntityScope.copy,
  );

  static final wishlist =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, bool>(
    id: MangaFieldIds.wishlist,
    label: 'Wishlist',
    getValue: (context) => context.source.isWishlisted,
    entityScope: LibraryEntityScope.copy,
  );

  static final updatedAt =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, DateTime>(
    id: MangaFieldIds.updatedAt,
    label: 'Updated',
    getValue: (context) => context.source.updatedAt,
    entityScope: LibraryEntityScope.copy,
  );

  static final addedAt =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, DateTime?>(
    id: MangaFieldIds.addedAt,
    label: 'Added',
    getValue: (context) => context.source.addedAt,
    entityScope: LibraryEntityScope.copy,
  );

  static final obiStripPresent =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, bool>(
    id: MangaFieldIds.obiStripPresent,
    label: 'Obi Strip Present',
    getValue: (context) => context.dto.ownedDetails?.obiStripPresent ?? false,
    entityScope: LibraryEntityScope.copy,
  );

  static final slipcoverPresent =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, bool>(
    id: MangaFieldIds.slipcoverPresent,
    label: 'Slipcover Present',
    getValue: (context) => context.dto.ownedDetails?.slipcoverPresent ?? false,
    entityScope: LibraryEntityScope.copy,
  );

  static final dustJacketPresent =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, bool>(
    id: MangaFieldIds.dustJacketPresent,
    label: 'Dust Jacket Present',
    getValue: (context) => context.dto.ownedDetails?.dustJacketPresent ?? false,
    entityScope: LibraryEntityScope.copy,
  );

  static final dustJacketCondition =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.dustJacketCondition,
    label: 'Dust Jacket Condition',
    getValue: (context) => context.dto.ownedDetails?.dustJacketCondition,
    entityScope: LibraryEntityScope.copy,
  );

  static final boxSetOuterCondition =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.boxSetOuterCondition,
    label: 'Box Set Outer Condition',
    getValue: (context) => context.dto.ownedDetails?.boxSetOuterCondition,
    entityScope: LibraryEntityScope.copy,
  );

  static final insertsPresent =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, bool>(
    id: MangaFieldIds.insertsPresent,
    label: 'Inserts Present',
    getValue: (context) => context.dto.ownedDetails?.insertsPresent ?? false,
    entityScope: LibraryEntityScope.copy,
  );

  static final printing =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.printing,
    label: 'Printing',
    getValue: (context) => context.dto.ownedDetails?.printing,
    entityScope: LibraryEntityScope.copy,
  );

  static final localizedEdition =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.localizedEdition,
    label: 'Localized Edition',
    getValue: (context) => context.dto.ownedDetails?.localizedEdition,
    entityScope: LibraryEntityScope.copy,
  );

  static final signedBy =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.signedBy,
    label: 'Signed By',
    getValue: (context) => context.dto.ownedDetails?.signedBy,
    entityScope: LibraryEntityScope.copy,
  );
}

final mangaCopyWorkspaceFieldDefinitions = [
  MangaCopyWorkspaceFields.status,
  MangaCopyWorkspaceFields.condition,
  MangaCopyWorkspaceFields.location,
  MangaCopyWorkspaceFields.pricePaid,
  MangaCopyWorkspaceFields.rating,
  MangaCopyWorkspaceFields.wishlist,
  MangaCopyWorkspaceFields.updatedAt,
  MangaCopyWorkspaceFields.addedAt,
  MangaCopyWorkspaceFields.obiStripPresent,
  MangaCopyWorkspaceFields.slipcoverPresent,
  MangaCopyWorkspaceFields.dustJacketPresent,
  MangaCopyWorkspaceFields.dustJacketCondition,
  MangaCopyWorkspaceFields.boxSetOuterCondition,
  MangaCopyWorkspaceFields.insertsPresent,
  MangaCopyWorkspaceFields.printing,
  MangaCopyWorkspaceFields.localizedEdition,
  MangaCopyWorkspaceFields.signedBy,
];

final mangaCopyWorkspaceGroupDefinitions = [
  groupFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaCopyWorkspaceFields.location,
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
  groupFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaCopyWorkspaceFields.condition,
    sidebarTitle: 'Conditions',
    icon: Icons.verified_outlined,
  ),
];

final mangaCopyWorkspaceSortDefinitions = [
  LibrarySortDefinition<MangaKind, MangaWorkspaceDto>(
    id: MangaSortIds.status,
    entityScope: LibraryEntityScope.copy,
    compare: (left, right) {
      int rank(LibraryProjectionContext<MangaWorkspaceDto> ctx) {
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

final mangaCopyWorkspaceDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  MangaFieldIds.status,
  MangaFieldIds.rating,
  MangaFieldIds.condition,
  MangaFieldIds.pricePaid,
  MangaFieldIds.location,
  MangaFieldIds.wishlist,
  MangaFieldIds.updatedAt,
};

final mangaCopyWorkspaceColumnDefinitions = [
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.status,
    label: 'Status',
    getValue: MangaCopyWorkspaceFields.status.getValue,
    cellValue: (context) => Text(context.source.isWishlisted
        ? 'Wishlist'
        : (context.source.isOwned ? 'Owned' : '')),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, bool>(
    id: MangaFieldIds.wishlist,
    label: 'Wishlist',
    getValue: MangaCopyWorkspaceFields.wishlist.getValue,
    cellValue: (context) => Text(context.source.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, DateTime>(
    id: MangaFieldIds.updatedAt,
    label: 'Updated',
    getValue: MangaCopyWorkspaceFields.updatedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, DateTime?>(
    id: MangaFieldIds.addedAt,
    label: 'Added',
    getValue: MangaCopyWorkspaceFields.addedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaCopyWorkspaceFields.location,
    group: 'Personal',
    defaultWidth: 118,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaCopyWorkspaceFields.condition,
    group: 'Value',
    defaultWidth: 124,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, int?>(
    MangaCopyWorkspaceFields.pricePaid,
    cellValue: (context) =>
        Text(_formatCents(context.source.pricePaidCents, context.dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, int?>(
    id: MangaFieldIds.rating,
    label: 'Rating',
    getValue: MangaCopyWorkspaceFields.rating.getValue,
    cellValue: (context) => Text(context.dto.personal.rating?.toString() ?? ''),
    defaultWidth: 80,
  ),
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, bool>(
    id: MangaFieldIds.obiStripPresent,
    label: 'Obi Strip',
    getValue: MangaCopyWorkspaceFields.obiStripPresent.getValue,
    cellValue: (context) => Text(
      (context.dto.ownedDetails?.obiStripPresent ?? false) ? 'Yes' : 'No',
    ),
    group: 'Condition',
    defaultWidth: 90,
  ),
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, bool>(
    id: MangaFieldIds.slipcoverPresent,
    label: 'Slipcover',
    getValue: MangaCopyWorkspaceFields.slipcoverPresent.getValue,
    cellValue: (context) => Text(
      (context.dto.ownedDetails?.slipcoverPresent ?? false) ? 'Yes' : 'No',
    ),
    group: 'Condition',
    defaultWidth: 90,
  ),
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, bool>(
    id: MangaFieldIds.dustJacketPresent,
    label: 'Dust Jacket',
    getValue: MangaCopyWorkspaceFields.dustJacketPresent.getValue,
    cellValue: (context) => Text(
      (context.dto.ownedDetails?.dustJacketPresent ?? false) ? 'Yes' : 'No',
    ),
    group: 'Condition',
    defaultWidth: 90,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaCopyWorkspaceFields.printing,
    group: 'Edition',
    defaultWidth: 100,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaCopyWorkspaceFields.localizedEdition,
    group: 'Edition',
    defaultWidth: 130,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaCopyWorkspaceFields.signedBy,
    group: 'Condition',
    defaultWidth: 130,
  ),
];

final mangaCopyWorkspaceSchema =
    LibraryEntityWorkspaceSchema<MangaKind, MangaWorkspaceDto>(
  kindNamespace: 'manga',
  entityScope: LibraryEntityScope.copy,
  fields: mangaCopyWorkspaceFieldDefinitions,
  columns: mangaCopyWorkspaceColumnDefinitions,
  sorts: mangaCopyWorkspaceSortDefinitions,
  groups: mangaCopyWorkspaceGroupDefinitions,
  primaryColumn: MangaFieldIds.status,
  defaultVisibleColumns: mangaCopyWorkspaceDefaultVisibleColumns,
  defaultSort: MangaSortIds.status,
  defaultGroup: MangaGroupIds.condition,
  preferenceCodec: const MangaPreferenceCodec(),
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
