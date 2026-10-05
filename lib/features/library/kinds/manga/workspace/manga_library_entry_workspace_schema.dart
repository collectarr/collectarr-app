import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_ids.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_library_entry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_schema.dart';
import 'package:flutter/material.dart';

abstract final class MangaLibraryEntryWorkspaceFields {
  static final condition =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.condition,
    label: 'Condition',
    getValue: (context) {
      final entry = MangaLibraryEntryProjection.fromDispatch(
          context.item.libraryEntryDispatch);
      return entry is MangaLibraryEntry ? entry.personal.condition : null;
    },
  );

  static final location =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.location,
    label: 'Location',
    getValue: (context) => context.personal.locationPath,
  );

  static final pricePaid =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, int?>(
    id: MangaFieldIds.pricePaid,
    label: 'Purchase Price',
    getValue: (context) => context.item.entrySummary?.pricePaidCents,
  );

  static final status =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.status,
    label: 'Status',
    getValue: (context) => context.personal.isWishlisted
        ? 'wishlist'
        : ((context.item.entrySummary != null) ? 'entry' : null),
  );

  static final rating =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, int?>(
    id: MangaFieldIds.rating,
    label: 'Rating',
    getValue: (context) => context.dto.personal.rating,
  );

  static final wishlist =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, bool>(
    id: MangaFieldIds.wishlist,
    label: 'Wishlist',
    getValue: (context) => context.personal.isWishlisted,
  );

  static final updatedAt =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, DateTime>(
    id: MangaFieldIds.updatedAt,
    label: 'Updated',
    getValue: (context) => context.updatedAt,
  );

  static final addedAt =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, DateTime?>(
    id: MangaFieldIds.addedAt,
    label: 'Added',
    getValue: (context) => context.addedAt,
  );

  static final obiStripPresent =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, bool>(
    id: MangaFieldIds.obiStripPresent,
    label: 'Obi Strip Present',
    getValue: (context) => context.dto.entryDetails?.obiStripPresent ?? false,
  );

  static final slipcoverPresent =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, bool>(
    id: MangaFieldIds.slipcoverPresent,
    label: 'Slipcover Present',
    getValue: (context) => context.dto.entryDetails?.slipcoverPresent ?? false,
  );

  static final dustJacketPresent =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, bool>(
    id: MangaFieldIds.dustJacketPresent,
    label: 'Dust Jacket Present',
    getValue: (context) => context.dto.entryDetails?.dustJacketPresent ?? false,
  );

  static final dustJacketCondition =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.dustJacketCondition,
    label: 'Dust Jacket Condition',
    getValue: (context) => context.dto.entryDetails?.dustJacketCondition,
  );

  static final boxSetOuterCondition =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.boxSetOuterCondition,
    label: 'Box Set Outer Condition',
    getValue: (context) => context.dto.entryDetails?.boxSetOuterCondition,
  );

  static final insertsPresent =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, bool>(
    id: MangaFieldIds.insertsPresent,
    label: 'Inserts Present',
    getValue: (context) => context.dto.entryDetails?.insertsPresent ?? false,
  );

  static final printing =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.printing,
    label: 'Printing',
    getValue: (context) => context.dto.entryDetails?.printing,
  );

  static final localizedEdition =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.localizedEdition,
    label: 'Localized Edition',
    getValue: (context) => context.dto.entryDetails?.localizedEdition,
  );

  static final signedBy =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.signedBy,
    label: 'Signed By',
    getValue: (context) => context.dto.entryDetails?.signedBy,
  );
}

final mangaLibraryEntryWorkspaceFieldDefinitions = [
  MangaLibraryEntryWorkspaceFields.status,
  MangaLibraryEntryWorkspaceFields.condition,
  MangaLibraryEntryWorkspaceFields.location,
  MangaLibraryEntryWorkspaceFields.pricePaid,
  MangaLibraryEntryWorkspaceFields.rating,
  MangaLibraryEntryWorkspaceFields.wishlist,
  MangaLibraryEntryWorkspaceFields.updatedAt,
  MangaLibraryEntryWorkspaceFields.addedAt,
  MangaLibraryEntryWorkspaceFields.obiStripPresent,
  MangaLibraryEntryWorkspaceFields.slipcoverPresent,
  MangaLibraryEntryWorkspaceFields.dustJacketPresent,
  MangaLibraryEntryWorkspaceFields.dustJacketCondition,
  MangaLibraryEntryWorkspaceFields.boxSetOuterCondition,
  MangaLibraryEntryWorkspaceFields.insertsPresent,
  MangaLibraryEntryWorkspaceFields.printing,
  MangaLibraryEntryWorkspaceFields.localizedEdition,
  MangaLibraryEntryWorkspaceFields.signedBy,
];

final mangaLibraryEntryWorkspaceGroupDefinitions = [
  groupFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaLibraryEntryWorkspaceFields.location,
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
  groupFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaLibraryEntryWorkspaceFields.condition,
    sidebarTitle: 'Conditions',
    icon: Icons.verified_outlined,
  ),
];

final mangaLibraryEntryWorkspaceSortDefinitions = [
  LibrarySortDefinition<MangaKind, MangaWorkspaceDto>(
    id: MangaSortIds.status,
    compare: (left, right) {
      int rank(LibraryProjectionContext<MangaWorkspaceDto> ctx) {
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

final mangaLibraryEntryWorkspaceDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  MangaFieldIds.status,
  MangaFieldIds.rating,
  MangaFieldIds.condition,
  MangaFieldIds.pricePaid,
  MangaFieldIds.location,
  MangaFieldIds.wishlist,
  MangaFieldIds.updatedAt,
};

final mangaLibraryEntryWorkspaceColumnDefinitions = [
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.status,
    label: 'Status',
    getValue: MangaLibraryEntryWorkspaceFields.status.getValue,
    cellValue: (context) => Text(context.personal.isWishlisted
        ? 'Wishlist'
        : ((context.item.entrySummary != null) ? 'Entry' : '')),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, bool>(
    id: MangaFieldIds.wishlist,
    label: 'Wishlist',
    getValue: MangaLibraryEntryWorkspaceFields.wishlist.getValue,
    cellValue: (context) => Text(context.personal.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, DateTime>(
    id: MangaFieldIds.updatedAt,
    label: 'Updated',
    getValue: MangaLibraryEntryWorkspaceFields.updatedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, DateTime?>(
    id: MangaFieldIds.addedAt,
    label: 'Added',
    getValue: MangaLibraryEntryWorkspaceFields.addedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaLibraryEntryWorkspaceFields.location,
    group: 'Personal',
    defaultWidth: 118,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaLibraryEntryWorkspaceFields.condition,
    group: 'Value',
    defaultWidth: 124,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, int?>(
    MangaLibraryEntryWorkspaceFields.pricePaid,
    cellValue: (context) =>
        Text(_formatCents(context.item.entrySummary?.pricePaidCents, context.dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, int?>(
    id: MangaFieldIds.rating,
    label: 'Rating',
    getValue: MangaLibraryEntryWorkspaceFields.rating.getValue,
    cellValue: (context) => Text(context.dto.personal.rating?.toString() ?? ''),
    defaultWidth: 80,
  ),
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, bool>(
    id: MangaFieldIds.obiStripPresent,
    label: 'Obi Strip',
    getValue: MangaLibraryEntryWorkspaceFields.obiStripPresent.getValue,
    cellValue: (context) => Text(
      (context.dto.entryDetails?.obiStripPresent ?? false) ? 'Yes' : 'No',
    ),
    group: 'Condition',
    defaultWidth: 90,
  ),
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, bool>(
    id: MangaFieldIds.slipcoverPresent,
    label: 'Slipcover',
    getValue: MangaLibraryEntryWorkspaceFields.slipcoverPresent.getValue,
    cellValue: (context) => Text(
      (context.dto.entryDetails?.slipcoverPresent ?? false) ? 'Yes' : 'No',
    ),
    group: 'Condition',
    defaultWidth: 90,
  ),
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, bool>(
    id: MangaFieldIds.dustJacketPresent,
    label: 'Dust Jacket',
    getValue: MangaLibraryEntryWorkspaceFields.dustJacketPresent.getValue,
    cellValue: (context) => Text(
      (context.dto.entryDetails?.dustJacketPresent ?? false) ? 'Yes' : 'No',
    ),
    group: 'Condition',
    defaultWidth: 90,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaLibraryEntryWorkspaceFields.printing,
    group: 'Edition',
    defaultWidth: 100,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaLibraryEntryWorkspaceFields.localizedEdition,
    group: 'Edition',
    defaultWidth: 130,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaLibraryEntryWorkspaceFields.signedBy,
    group: 'Condition',
    defaultWidth: 130,
  ),
];

final mangaLibraryEntryWorkspaceSchema =
    LibraryWorkspaceSchema<MangaKind, MangaWorkspaceDto>(
  kindNamespace: 'manga',
  fields: mangaLibraryEntryWorkspaceFieldDefinitions,
  columns: mangaLibraryEntryWorkspaceColumnDefinitions,
  sorts: mangaLibraryEntryWorkspaceSortDefinitions,
  groups: mangaLibraryEntryWorkspaceGroupDefinitions,
  primaryColumn: MangaFieldIds.status,
  defaultVisibleColumns: mangaLibraryEntryWorkspaceDefaultVisibleColumns,
  defaultSort: MangaSortIds.status,
  defaultGroup: MangaGroupIds.condition,
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
