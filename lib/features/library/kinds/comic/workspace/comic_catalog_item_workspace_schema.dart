import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/config/comic_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/config/comic_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_facets.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_schema.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_bucket_mutators.dart';
import 'package:flutter/material.dart';

abstract final class ComicCatalogItemWorkspaceFields {
  static final title = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.title,
    metadata: ComicWorkspaceFieldMetadata.title,
    getValue: (dto) => dto.title,
  );

  static final series = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.series,
    metadata: ComicFieldIdentities.series,
    getValue: (dto) => dto.seriesTitle,
  );

  static final issueNumber = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.issueNumber,
    metadata: ComicFieldIdentities.issueNumber,
    getValue: (dto) => dto.itemNumber,
  );

  static final cover =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.cover,
    metadata: ComicWorkspaceFieldMetadata.cover,
    getValue: (context) => context.dto.coverImageUrl,
  );

  static final writer = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.writer,
    metadata: ComicWorkspaceFieldMetadata.writer,
    getValue: (dto) => dto.writer,
  );

  static final artist = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.artist,
    metadata: ComicWorkspaceFieldMetadata.artist,
    getValue: (dto) => dto.artist,
  );

  static final coverArtist = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.coverArtist,
    metadata: ComicWorkspaceFieldMetadata.coverArtist,
    getValue: (dto) => dto.coverArtist,
  );

  static final imprint = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.imprint,
    metadata: ComicFieldIdentities.imprint,
    getValue: (dto) => dto.imprint,
  );

  static final pageCount = numberField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.pageCount,
    metadata: ComicFieldIdentities.pageCount,
    getValue: (dto) => dto.pageCount,
  );

  static final publisher = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.publisher,
    metadata: ComicWorkspaceFieldMetadata.publisher,
    getValue: (dto) => dto.publisher,
  );

  static final releaseDate = dateField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.releaseDate,
    metadata: ComicWorkspaceFieldMetadata.releaseDate,
    getValue: (dto) => dto.releaseDate,
  );

  static final barcode = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.barcode,
    metadata: ComicWorkspaceFieldMetadata.barcode,
    getValue: (dto) => dto.barcode,
  );

  static final variant = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.variant,
    metadata: ComicFieldIdentities.variant,
    getValue: (dto) => dto.variant,
  );
}

final comicCatalogItemWorkspaceFieldDefinitions = [
  ComicCatalogItemWorkspaceFields.title,
  ComicCatalogItemWorkspaceFields.cover,
  ComicCatalogItemWorkspaceFields.series,
  ComicCatalogItemWorkspaceFields.issueNumber,
  ComicCatalogItemWorkspaceFields.writer,
  ComicCatalogItemWorkspaceFields.artist,
  ComicCatalogItemWorkspaceFields.coverArtist,
  ComicCatalogItemWorkspaceFields.imprint,
  ComicCatalogItemWorkspaceFields.pageCount,
  ComicCatalogItemWorkspaceFields.publisher,
  ComicCatalogItemWorkspaceFields.releaseDate,
  ComicCatalogItemWorkspaceFields.barcode,
  ComicCatalogItemWorkspaceFields.variant,
];

final comicCatalogItemWorkspaceGroupDefinitions = [
  if (ComicFieldIdentities.series.groupable)
    groupFromField<ComicKind, ComicWorkspaceDto, String?>(
      ComicCatalogItemWorkspaceFields.series,
      sidebarTitle: 'Series',
      category: 'Main',
      icon: Icons.collections_bookmark_outlined,
      supportsJump: true,
      sequenceValue: (context) => context.dto.itemNumber,
    ),
  groupFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicCatalogItemWorkspaceFields.publisher,
    sidebarTitle: 'Publishers',
    category: 'Main',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
    bucketValueMutator: catalogTransportStringBucketValueMutator(
      ['publisher'],
    ),
  ),
];

final comicCatalogItemWorkspaceSortDefinitions = [
  if (ComicFieldIdentities.series.sortable)
    sortFromField<ComicKind, ComicWorkspaceDto, String>(
      ComicCatalogItemWorkspaceFields.series,
    ),
  if (ComicFieldIdentities.issueNumber.sortable)
    sortFromField<ComicKind, ComicWorkspaceDto, String>(
      ComicCatalogItemWorkspaceFields.issueNumber,
    ),
  sortFromField<ComicKind, ComicWorkspaceDto, String>(
      ComicCatalogItemWorkspaceFields.title),
  sortFromField<ComicKind, ComicWorkspaceDto, String>(
      ComicCatalogItemWorkspaceFields.publisher),
  sortFromField<ComicKind, ComicWorkspaceDto, DateTime>(
    ComicCatalogItemWorkspaceFields.releaseDate,
    defaultAscending: false,
  ),
];

final comicCatalogItemWorkspaceDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  ComicFieldIds.cover,
  ComicFieldIds.series,
  ComicFieldIds.issueNumber,
  ComicFieldIds.title,
  ComicFieldIds.publisher,
  ComicFieldIds.releaseDate,
};

final comicCatalogItemWorkspaceColumnDefinitions = [
  LibraryColumnDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.cover,
    metadata: ComicWorkspaceFieldMetadata.cover,
    getValue: ComicCatalogItemWorkspaceFields.cover.getValue,
    cellValue: (context) => context.dto.coverImageUrl == null
        ? const SizedBox.shrink()
        : Image.network(
            context.dto.coverImageUrl!,
            width: 32,
            height: 32,
            fit: BoxFit.cover,
          ),
    allowSortInteraction: false,
    allowGroupInteraction: false,
    defaultWidth: 42,
    minWidth: 44,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
      ComicCatalogItemWorkspaceFields.series,
      defaultWidth: 160),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
      ComicCatalogItemWorkspaceFields.issueNumber,
      defaultWidth: 80),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
      ComicCatalogItemWorkspaceFields.title,
      defaultWidth: 260,
      maxWidth: 520),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicCatalogItemWorkspaceFields.writer,
    group: 'Credits',
    defaultWidth: 130,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicCatalogItemWorkspaceFields.artist,
    group: 'Credits',
    defaultWidth: 130,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicCatalogItemWorkspaceFields.coverArtist,
    group: 'Credits',
    defaultWidth: 130,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicCatalogItemWorkspaceFields.imprint,
    group: 'Publisher',
    defaultWidth: 120,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicCatalogItemWorkspaceFields.publisher,
    group: 'Publisher',
    defaultWidth: 140,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, DateTime?>(
    ComicCatalogItemWorkspaceFields.releaseDate,
    cellValue: (context) => Text(_formatDate(context.dto.releaseDate)),
    defaultWidth: 118,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicCatalogItemWorkspaceFields.barcode,
    group: 'Edition',
    defaultWidth: 160,
    maxWidth: 260,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicCatalogItemWorkspaceFields.variant,
    group: 'Edition',
    defaultWidth: 140,
  ),
];

final comicCatalogItemWorkspaceSchema =
    LibraryWorkspaceSchema<ComicKind, ComicWorkspaceDto>(
  kindNamespace: 'comic',
  fields: [
    ...comicCatalogItemWorkspaceFieldDefinitions,
    ...comicSmartListFacetFields,
  ],
  columns: comicCatalogItemWorkspaceColumnDefinitions,
  sorts: comicCatalogItemWorkspaceSortDefinitions,
  groups: comicCatalogItemWorkspaceGroupDefinitions,
  primaryColumn: ComicFieldIds.title,
  defaultVisibleColumns: comicCatalogItemWorkspaceDefaultVisibleColumns,
  defaultSort: ComicSortIds.releaseDate,
  defaultGroup: ComicGroupIds.series,
);

String _formatDate(DateTime? value) {
  if (value == null) return '—';
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
