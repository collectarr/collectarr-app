import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_preference_codec.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_bucket_mutators.dart';
import 'package:flutter/material.dart';

abstract final class ComicCatalogItemWorkspaceFields {
  static final title = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.title,
    label: 'Title',
    getValue: (dto) => dto.title,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final series = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.series,
    label: 'Series',
    getValue: (dto) => dto.seriesTitle,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final issueNumber = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.issueNumber,
    label: 'Issue Number',
    getValue: (dto) => dto.itemNumber,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final cover =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.cover,
    label: 'Cover',
    getValue: (context) => context.dto.coverImageUrl,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final writer = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.writer,
    label: 'Writer',
    getValue: (dto) => dto.writer,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final artist = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.artist,
    label: 'Artist',
    getValue: (dto) => dto.artist,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final coverArtist = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.coverArtist,
    label: 'Cover Artist',
    getValue: (dto) => dto.coverArtist,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final imprint = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.imprint,
    label: 'Imprint',
    getValue: (dto) => dto.imprint,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final pageCount = numberField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.pageCount,
    label: 'Page Count',
    getValue: (dto) => dto.pageCount,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final publisher = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.publisher,
    label: 'Publisher',
    getValue: (dto) => dto.publisher,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final releaseDate = dateField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.releaseDate,
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final barcode = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.barcode,
    label: 'Barcode',
    getValue: (dto) => dto.barcode,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final variant = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.variant,
    label: 'Variant',
    getValue: (dto) => dto.variant,
    entityScope: LibraryEntityScope.catalogItem,
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
  sortFromField<ComicKind, ComicWorkspaceDto, String>(
      ComicCatalogItemWorkspaceFields.series),
  sortFromField<ComicKind, ComicWorkspaceDto, String>(
      ComicCatalogItemWorkspaceFields.issueNumber),
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
    label: '',
    getValue: ComicCatalogItemWorkspaceFields.cover.getValue,
    cellValue: (context) => context.dto.coverImageUrl == null
        ? const SizedBox.shrink()
        : Image.network(
            context.dto.coverImageUrl!,
            width: 32,
            height: 32,
            fit: BoxFit.cover,
          ),
    sortable: false,
    groupable: false,
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
    LibraryEntityWorkspaceSchema<ComicKind, ComicWorkspaceDto>(
  kindNamespace: 'comic',
  entityScope: LibraryEntityScope.catalogItem,
  fields: comicCatalogItemWorkspaceFieldDefinitions,
  columns: comicCatalogItemWorkspaceColumnDefinitions,
  sorts: comicCatalogItemWorkspaceSortDefinitions,
  groups: comicCatalogItemWorkspaceGroupDefinitions,
  primaryColumn: ComicFieldIds.title,
  defaultVisibleColumns: comicCatalogItemWorkspaceDefaultVisibleColumns,
  defaultSort: ComicSortIds.releaseDate,
  defaultGroup: ComicGroupIds.series,
  preferenceCodec: const IdentityLibraryWorkspacePreferenceCodec<ComicKind>(),
);

String _formatDate(DateTime? value) {
  if (value == null) return '—';
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
