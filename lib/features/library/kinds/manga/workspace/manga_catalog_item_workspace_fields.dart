import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_ids.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_bucket_mutators.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:flutter/material.dart';

abstract final class MangaCatalogItemWorkspaceFields {
  static final publisher = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.publisher,
    label: 'Publisher',
    getValue: (dto) => dto.publisher,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final releaseDate = dateField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.releaseDate,
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final barcode = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.barcode,
    label: 'ISBN / Barcode',
    getValue: (dto) => dto.barcode,
    entityScope: LibraryEntityScope.catalogItem,
  );
}

final mangaCatalogItemWorkspaceFieldDefinitions = [
  MangaCatalogItemWorkspaceFields.publisher,
  MangaCatalogItemWorkspaceFields.releaseDate,
  MangaCatalogItemWorkspaceFields.barcode,
];

final mangaCatalogItemWorkspaceGroupDefinitions = [
  groupFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaCatalogItemWorkspaceFields.publisher,
    sidebarTitle: 'Publishers',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
    bucketValueMutator: catalogTransportStringBucketValueMutator(
      ['publisher', 'original_publisher', 'localized_publisher'],
    ),
  ),
];

final mangaCatalogItemWorkspaceSortDefinitions = [
  LibrarySortDefinition<MangaKind, MangaWorkspaceDto>(
    id: MangaSortIds.releaseTitle,
    label: 'Release title',
    entityScope: LibraryEntityScope.catalogItem,
    compare: (left, right) => left.dto.title.compareTo(right.dto.title),
  ),
  sortFromField<MangaKind, MangaWorkspaceDto, String>(
      MangaCatalogItemWorkspaceFields.publisher),
  sortFromField<MangaKind, MangaWorkspaceDto, DateTime>(
      MangaCatalogItemWorkspaceFields.releaseDate,
      defaultAscending: false),
];

final mangaCatalogItemWorkspaceDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  MangaFieldIds.publisher,
  MangaFieldIds.releaseDate,
  MangaFieldIds.barcode,
};

final mangaCatalogItemWorkspaceColumnDefinitions = [
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
      MangaCatalogItemWorkspaceFields.publisher,
      defaultWidth: 140),
  columnFromField<MangaKind, MangaWorkspaceDto, DateTime?>(
    MangaCatalogItemWorkspaceFields.releaseDate,
    cellValue: (context) => Text(_formatDate(context.dto.releaseDate)),
    defaultWidth: 118,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaCatalogItemWorkspaceFields.barcode,
    group: 'Edition',
    defaultWidth: 160,
    maxWidth: 260,
  ),
];

String _formatDate(DateTime? value) {
  if (value == null) return '';
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
