import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_ids.dart';
import 'package:collectarr_app/features/library/kinds/manga/config/manga_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_facets.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_library_entry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_schema.dart';
import 'package:flutter/material.dart';

abstract final class MangaLibraryEntryWorkspaceFields {
  static final condition =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.condition,
    metadata: MangaWorkspaceFieldMetadata.condition,
    getValue: (context) {
      final entry = MangaLibraryEntryProjection.fromDispatch(
          context.item.libraryEntryDispatch);
      return entry is MangaLibraryEntry ? entry.personal.condition : null;
    },
  );

  static final location =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.location,
    metadata: MangaWorkspaceFieldMetadata.location,
    getValue: (context) => context.personal.locationPath,
  );

  static final pricePaid =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, int?>(
    id: MangaFieldIds.pricePaid,
    metadata: MangaWorkspaceFieldMetadata.pricePaid,
    getValue: (context) => context.item.entrySummary?.pricePaidCents,
  );

  static final status =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.status,
    metadata: MangaWorkspaceFieldMetadata.status,
    getValue: (context) => context.personal.isWishlisted
        ? 'wishlist'
        : ((context.item.entrySummary != null) ? 'entry' : null),
  );

  static final rating =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, int?>(
    id: MangaFieldIds.rating,
    metadata: MangaWorkspaceFieldMetadata.rating,
    getValue: (context) => context.dto.personal.rating,
  );

  static final wishlist =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, bool>(
    id: MangaFieldIds.wishlist,
    metadata: MangaWorkspaceFieldMetadata.wishlist,
    getValue: (context) => context.personal.isWishlisted,
  );

  static final updatedAt =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, DateTime>(
    id: MangaFieldIds.updatedAt,
    metadata: MangaWorkspaceFieldMetadata.updatedAt,
    getValue: (context) => context.updatedAt,
  );

  static final addedAt =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, DateTime?>(
    id: MangaFieldIds.addedAt,
    metadata: MangaWorkspaceFieldMetadata.addedAt,
    getValue: (context) => context.addedAt,
  );

  static final obiStripPresent =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, bool>(
    id: MangaFieldIds.obiStripPresent,
    metadata: MangaWorkspaceFieldMetadata.obiStripPresent,
    getValue: (context) => context.dto.entryDetails?.obiStripPresent ?? false,
  );

  static final slipcoverPresent =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, bool>(
    id: MangaFieldIds.slipcoverPresent,
    metadata: MangaWorkspaceFieldMetadata.slipcoverPresent,
    getValue: (context) => context.dto.entryDetails?.slipcoverPresent ?? false,
  );

  static final dustJacketPresent =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, bool>(
    id: MangaFieldIds.dustJacketPresent,
    metadata: MangaWorkspaceFieldMetadata.dustJacketPresent,
    getValue: (context) => context.dto.entryDetails?.dustJacketPresent ?? false,
  );

  static final dustJacketCondition =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.dustJacketCondition,
    metadata: MangaWorkspaceFieldMetadata.dustJacketCondition,
    getValue: (context) => context.dto.entryDetails?.dustJacketCondition,
  );

  static final boxSetOuterCondition =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.boxSetOuterCondition,
    metadata: MangaWorkspaceFieldMetadata.boxSetOuterCondition,
    getValue: (context) => context.dto.entryDetails?.boxSetOuterCondition,
  );

  static final insertsPresent =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, bool>(
    id: MangaFieldIds.insertsPresent,
    metadata: MangaWorkspaceFieldMetadata.insertsPresent,
    getValue: (context) => context.dto.entryDetails?.insertsPresent ?? false,
  );

  static final printing =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.printing,
    metadata: MangaWorkspaceFieldMetadata.printing,
    getValue: (context) => context.dto.entryDetails?.printing,
  );

  static final localizedEdition =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.localizedEdition,
    metadata: MangaWorkspaceFieldMetadata.localizedEdition,
    getValue: (context) => context.dto.entryDetails?.localizedEdition,
  );

  static final signedBy =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.signedBy,
    metadata: MangaWorkspaceFieldMetadata.signedBy,
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
    metadata: MangaWorkspaceFieldMetadata.status,
    getValue: MangaLibraryEntryWorkspaceFields.status.getValue,
    cellValue: (context) => Text(context.personal.isWishlisted
        ? 'Wishlist'
        : ((context.item.entrySummary != null) ? 'Entry' : '')),
    allowSortInteraction: false,
    allowGroupInteraction: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, bool>(
    id: MangaFieldIds.wishlist,
    metadata: MangaWorkspaceFieldMetadata.wishlist,
    getValue: MangaLibraryEntryWorkspaceFields.wishlist.getValue,
    cellValue: (context) =>
        Text(context.personal.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, DateTime>(
    id: MangaFieldIds.updatedAt,
    metadata: MangaWorkspaceFieldMetadata.updatedAt,
    getValue: MangaLibraryEntryWorkspaceFields.updatedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, DateTime?>(
    id: MangaFieldIds.addedAt,
    metadata: MangaWorkspaceFieldMetadata.addedAt,
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
    cellValue: (context) => Text(_formatCents(
        context.item.entrySummary?.pricePaidCents, context.dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, int?>(
    id: MangaFieldIds.rating,
    metadata: MangaWorkspaceFieldMetadata.rating,
    getValue: MangaLibraryEntryWorkspaceFields.rating.getValue,
    cellValue: (context) => Text(context.dto.personal.rating?.toString() ?? ''),
    defaultWidth: 80,
  ),
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, bool>(
    id: MangaFieldIds.obiStripPresent,
    metadata: MangaWorkspaceFieldMetadata.obiStripPresent,
    getValue: MangaLibraryEntryWorkspaceFields.obiStripPresent.getValue,
    cellValue: (context) => Text(
      (context.dto.entryDetails?.obiStripPresent ?? false) ? 'Yes' : 'No',
    ),
    group: 'Condition',
    defaultWidth: 90,
  ),
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, bool>(
    id: MangaFieldIds.slipcoverPresent,
    metadata: MangaWorkspaceFieldMetadata.slipcoverPresent,
    getValue: MangaLibraryEntryWorkspaceFields.slipcoverPresent.getValue,
    cellValue: (context) => Text(
      (context.dto.entryDetails?.slipcoverPresent ?? false) ? 'Yes' : 'No',
    ),
    group: 'Condition',
    defaultWidth: 90,
  ),
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, bool>(
    id: MangaFieldIds.dustJacketPresent,
    metadata: MangaWorkspaceFieldMetadata.dustJacketPresent,
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
  fields: [
    ...mangaLibraryEntryWorkspaceFieldDefinitions,
    ...mangaSmartListFacetFields,
  ],
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
