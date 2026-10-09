import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/config/comic_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_facets.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_schema.dart';
import 'package:flutter/material.dart';

abstract final class ComicLibraryEntryWorkspaceFields {
  static final condition =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.condition,
    metadata: ComicWorkspaceFieldMetadata.condition,
    getValue: (context) => _entry(context)?.personal.condition,
  );

  static final location =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.location,
    metadata: ComicWorkspaceFieldMetadata.location,
    getValue: (context) => context.personal.locationPath,
  );

  static final pricePaid =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, int?>(
    id: ComicFieldIds.pricePaid,
    metadata: ComicWorkspaceFieldMetadata.pricePaid,
    getValue: (context) => _entry(context)?.personal.pricePaidCents,
  );

  static final status =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.status,
    metadata: ComicWorkspaceFieldMetadata.status,
    getValue: (context) => context.personal.isWishlisted
        ? 'wishlist'
        : ((context.item.entrySummary != null) ? 'entry' : null),
  );

  static final rating =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, int?>(
    id: ComicFieldIds.rating,
    metadata: ComicWorkspaceFieldMetadata.rating,
    getValue: (context) => _entry(context)?.personal.reading.rating,
  );

  static final wishlist =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, bool>(
    id: ComicFieldIds.wishlist,
    metadata: ComicWorkspaceFieldMetadata.wishlist,
    getValue: (context) => context.personal.isWishlisted,
  );

  static final updatedAt =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, DateTime>(
    id: ComicFieldIds.updatedAt,
    metadata: ComicWorkspaceFieldMetadata.updatedAt,
    getValue: (context) => context.updatedAt,
  );

  static final addedAt =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, DateTime?>(
    id: ComicFieldIds.addedAt,
    metadata: ComicWorkspaceFieldMetadata.addedAt,
    getValue: (context) => context.addedAt,
  );

  static final grade =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.grade,
    metadata: ComicWorkspaceFieldMetadata.grade,
    getValue: (context) => _entry(context)?.personal.grade,
  );

  static final keyComic =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, bool>(
    id: ComicFieldIds.keyComic,
    metadata: ComicWorkspaceFieldMetadata.keyComic,
    getValue: (context) => _entryDetails(context)?.keyComic == true,
  );

  static final keyReason =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.keyReason,
    metadata: ComicWorkspaceFieldMetadata.keyReason,
    getValue: (context) => _entryDetails(context)?.keyReason,
  );

  static final keyCategory =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.keyCategory,
    metadata: ComicWorkspaceFieldMetadata.keyCategory,
    getValue: (context) => _entryDetails(context)?.keyCategory,
  );

  static final keySeverity =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.keySeverity,
    metadata: ComicWorkspaceFieldMetadata.keySeverity,
    getValue: (context) => _entryDetails(context)?.keySeverity,
  );

  static final rawOrSlabbed =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.rawOrSlabbed,
    metadata: ComicWorkspaceFieldMetadata.rawOrSlabbed,
    getValue: (context) => _entryDetails(context)?.rawOrSlabbed,
  );

  static final gradingCompany =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.gradingCompany,
    metadata: ComicWorkspaceFieldMetadata.gradingCompany,
    getValue: (context) => _entryDetails(context)?.gradingCompany,
  );

  static final graderNotes =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.graderNotes,
    metadata: ComicWorkspaceFieldMetadata.graderNotes,
    getValue: (context) => _entryDetails(context)?.graderNotes,
  );

  static final signedBy =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.signedBy,
    metadata: ComicWorkspaceFieldMetadata.signedBy,
    getValue: (context) => _entryDetails(context)?.signedBy,
  );

  static final labelType =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.labelType,
    metadata: ComicWorkspaceFieldMetadata.labelType,
    getValue: (context) => _entryDetails(context)?.labelType,
  );

  static final customLabel =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.customLabel,
    metadata: ComicWorkspaceFieldMetadata.customLabel,
    getValue: (context) => _entryDetails(context)?.customLabel,
  );

  static final pageQuality =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.pageQuality,
    metadata: ComicWorkspaceFieldMetadata.pageQuality,
    getValue: (context) => _entryDetails(context)?.pageQuality,
  );

  static final certificationNumber =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.certificationNumber,
    metadata: ComicWorkspaceFieldMetadata.certificationNumber,
    getValue: (context) => _entryDetails(context)?.certificationNumber,
  );

  static final coverPrice =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, int?>(
    id: ComicFieldIds.coverPrice,
    metadata: ComicWorkspaceFieldMetadata.coverPrice,
    getValue: (context) => _entryDetails(context)?.coverPriceCents,
  );

  static final lastBagBoardDate =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, DateTime?>(
    id: ComicFieldIds.lastBagBoardDate,
    metadata: ComicWorkspaceFieldMetadata.lastBagBoardDate,
    getValue: (context) => _entryDetails(context)?.lastBagBoardDate,
  );
}

ComicLibraryEntry? _entry(
        LibraryProjectionContext<ComicWorkspaceDto> context) =>
    context.dto.libraryEntry;

ComicEntryDetails? _entryDetails(
  LibraryProjectionContext<ComicWorkspaceDto> context,
) =>
    _entry(context)?.personal.details;

final comicLibraryEntryWorkspaceFieldDefinitions = [
  ComicLibraryEntryWorkspaceFields.status,
  ComicLibraryEntryWorkspaceFields.condition,
  ComicLibraryEntryWorkspaceFields.location,
  ComicLibraryEntryWorkspaceFields.pricePaid,
  ComicLibraryEntryWorkspaceFields.rating,
  ComicLibraryEntryWorkspaceFields.wishlist,
  ComicLibraryEntryWorkspaceFields.updatedAt,
  ComicLibraryEntryWorkspaceFields.addedAt,
  ComicLibraryEntryWorkspaceFields.grade,
  ComicLibraryEntryWorkspaceFields.keyComic,
  ComicLibraryEntryWorkspaceFields.keyReason,
  ComicLibraryEntryWorkspaceFields.keyCategory,
  ComicLibraryEntryWorkspaceFields.rawOrSlabbed,
  ComicLibraryEntryWorkspaceFields.gradingCompany,
  ComicLibraryEntryWorkspaceFields.signedBy,
];

final comicLibraryEntryWorkspaceGroupDefinitions = [
  groupFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicLibraryEntryWorkspaceFields.location,
    sidebarTitle: 'Locations',
    category: 'Personal',
    icon: Icons.place_outlined,
  ),
  groupFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicLibraryEntryWorkspaceFields.condition,
    sidebarTitle: 'Conditions',
    category: 'Personal',
    icon: Icons.verified_outlined,
  ),
];

final comicLibraryEntryWorkspaceSortDefinitions = [
  LibrarySortDefinition<ComicKind, ComicWorkspaceDto>(
    id: ComicSortIds.status,
    compare: (left, right) {
      int rank(LibraryProjectionContext<ComicWorkspaceDto> ctx) {
        if ((ctx.item.entrySummary != null)) return 0;
        if (ctx.personal.isWishlisted) return 1;
        return 2;
      }

      final res = rank(left).compareTo(rank(right));
      return res != 0 ? res : left.dto.title.compareTo(right.dto.title);
    },
    label: 'Status',
  ),
  sortFromField<ComicKind, ComicWorkspaceDto, String>(
      ComicLibraryEntryWorkspaceFields.condition),
  sortFromField<ComicKind, ComicWorkspaceDto, int>(
      ComicLibraryEntryWorkspaceFields.rating,
      defaultAscending: false),
  sortFromField<ComicKind, ComicWorkspaceDto, int>(
      ComicLibraryEntryWorkspaceFields.pricePaid,
      defaultAscending: false),
  sortFromField<ComicKind, ComicWorkspaceDto, DateTime>(
      ComicLibraryEntryWorkspaceFields.updatedAt,
      defaultAscending: false),
];

final comicLibraryEntryWorkspaceDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  ComicFieldIds.status,
  ComicFieldIds.grade,
  ComicFieldIds.keyComic,
  ComicFieldIds.condition,
  ComicFieldIds.pricePaid,
  ComicFieldIds.location,
  ComicFieldIds.wishlist,
  ComicFieldIds.updatedAt,
};

final comicLibraryEntryWorkspaceColumnDefinitions = [
  LibraryColumnDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.status,
    metadata: ComicWorkspaceFieldMetadata.status,
    getValue: ComicLibraryEntryWorkspaceFields.status.getValue,
    cellValue: (context) => Text(context.personal.isWishlisted
        ? 'Wishlist'
        : ((context.item.entrySummary != null) ? 'Entry' : '')),
    allowSortInteraction: false,
    allowGroupInteraction: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicLibraryEntryWorkspaceFields.grade,
    group: 'Grading',
    defaultWidth: 80,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, bool>(
    ComicLibraryEntryWorkspaceFields.keyComic,
    group: 'Key Info',
    defaultWidth: 90,
  ),
  LibraryColumnDefinition<ComicKind, ComicWorkspaceDto, bool>(
    id: ComicFieldIds.wishlist,
    metadata: ComicWorkspaceFieldMetadata.wishlist,
    getValue: ComicLibraryEntryWorkspaceFields.wishlist.getValue,
    cellValue: (context) =>
        Text(context.personal.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<ComicKind, ComicWorkspaceDto, DateTime>(
    id: ComicFieldIds.updatedAt,
    metadata: ComicWorkspaceFieldMetadata.updatedAt,
    getValue: ComicLibraryEntryWorkspaceFields.updatedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<ComicKind, ComicWorkspaceDto, DateTime?>(
    id: ComicFieldIds.addedAt,
    metadata: ComicWorkspaceFieldMetadata.addedAt,
    getValue: ComicLibraryEntryWorkspaceFields.addedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicLibraryEntryWorkspaceFields.location,
    group: 'Personal',
    defaultWidth: 118,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicLibraryEntryWorkspaceFields.condition,
    group: 'Value',
    defaultWidth: 124,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, int?>(
    ComicLibraryEntryWorkspaceFields.pricePaid,
    cellValue: (context) => Text(_formatCents(
        _entry(context)?.personal.pricePaidCents, context.dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  LibraryColumnDefinition<ComicKind, ComicWorkspaceDto, int?>(
    id: ComicFieldIds.rating,
    metadata: ComicWorkspaceFieldMetadata.rating,
    getValue: ComicLibraryEntryWorkspaceFields.rating.getValue,
    cellValue: (context) =>
        Text(_entry(context)?.personal.reading.rating?.toString() ?? ''),
    defaultWidth: 80,
  ),
];

final comicLibraryEntryWorkspaceSchema =
    LibraryWorkspaceSchema<ComicKind, ComicWorkspaceDto>(
  kindNamespace: 'comic',
  fields: [
    ...comicLibraryEntryWorkspaceFieldDefinitions,
    ...comicSmartListFacetFields,
  ],
  columns: comicLibraryEntryWorkspaceColumnDefinitions,
  sorts: comicLibraryEntryWorkspaceSortDefinitions,
  groups: comicLibraryEntryWorkspaceGroupDefinitions,
  primaryColumn: ComicFieldIds.status,
  defaultVisibleColumns: comicLibraryEntryWorkspaceDefaultVisibleColumns,
  defaultSort: ComicSortIds.status,
  defaultGroup: ComicGroupIds.condition,
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
