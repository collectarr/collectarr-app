import 'package:collectarr_app/features/library/kinds/comic/workspace/ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/catalog_schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/collection_fields.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/columns/columns.dart';
import 'package:collectarr_app/features/library/kinds/comic/config/comic_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/facets.dart';
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

/// Reference defaults: the list shows Series, Issue, Variant Description,
/// Publisher, Release Date, Storage Box, Format and Added Date, sorted by
/// Series then Issue, with Series folders.
final comicLibraryEntryWorkspaceSchema =
    LibraryWorkspaceSchema<ComicKind, ComicWorkspaceDto>(
  kindNamespace: 'comic',
  // Collection comics carry their catalog fields, as in Music and Games: the
  // table resolves columns from this registry alone.
  fields: [
    ...comicCollectionWorkspaceFieldDefinitions,
    ...comicSmartListFacetFields,
  ],
  columns: comicCollectionWorkspaceColumns,
  sorts: comicCollectionWorkspaceSorts,
  groups: [
    ...comicCatalogItemWorkspaceGroupDefinitions,
    ...comicLibraryEntryWorkspaceGroupDefinitions,
  ],
  primaryColumn: ComicFieldIds.series,
  defaultVisibleColumns: {
    ComicFieldIds.series,
    ComicCollectionWorkspaceFields.issue.id,
    ComicCollectionWorkspaceFields.variantDescription.id,
    ComicFieldIds.publisher,
    ComicCollectionWorkspaceFields.releaseDate.id,
    ComicFieldIds.location,
    ComicCollectionWorkspaceFields.format.id,
    ComicFieldIds.addedAt,
  },
  defaultSort: ComicSortIds.series,
  defaultThenSort: LibrarySortId(ComicCollectionWorkspaceFields.issue.id.value),
  defaultGroup: ComicGroupIds.series,
);
