import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_ids.dart';
import 'package:collectarr_app/features/library/kinds/manga/config/manga_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/config/manga_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_bucket_mutators.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:flutter/material.dart';

abstract final class MangaAdditionalCatalogItemWorkspaceFields {
  static final publisher = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.publisher,
    metadata: MangaFieldIdentities.publisher,
    getValue: (dto) => dto.publisher,
  );

  static final releaseDate = dateField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.releaseDate,
    metadata: MangaWorkspaceFieldMetadata.releaseDate,
    getValue: (dto) => dto.releaseDate,
  );

  static final barcode = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.barcode,
    metadata: MangaWorkspaceFieldMetadata.barcode,
    getValue: (dto) => dto.barcode,
  );
}

final mangaAdditionalCatalogItemWorkspaceFieldDefinitions = [
  MangaAdditionalCatalogItemWorkspaceFields.publisher,
  MangaAdditionalCatalogItemWorkspaceFields.releaseDate,
  MangaAdditionalCatalogItemWorkspaceFields.barcode,
];

final mangaAdditionalCatalogItemWorkspaceGroupDefinitions = [
  if (MangaFieldIdentities.publisher.groupable)
    groupFromField<MangaKind, MangaWorkspaceDto, String?>(
      MangaAdditionalCatalogItemWorkspaceFields.publisher,
      sidebarTitle: 'Publishers',
      icon: Icons.business_outlined,
      supportsBucketManagement: true,
      bucketValueMutator: catalogTransportStringBucketValueMutator(
        ['publisher', 'original_publisher', 'localized_publisher'],
      ),
    ),
];

final mangaAdditionalCatalogItemWorkspaceSortDefinitions = [
  LibrarySortDefinition<MangaKind, MangaWorkspaceDto>(
    id: MangaSortIds.releaseTitle,
    label: 'Release title',
    compare: (left, right) => left.dto.title.compareTo(right.dto.title),
  ),
  if (MangaFieldIdentities.publisher.sortable)
    sortFromField<MangaKind, MangaWorkspaceDto, String>(
      MangaAdditionalCatalogItemWorkspaceFields.publisher,
    ),
  sortFromField<MangaKind, MangaWorkspaceDto, DateTime>(
      MangaAdditionalCatalogItemWorkspaceFields.releaseDate,
      defaultAscending: false),
];

final mangaAdditionalCatalogItemWorkspaceDefaultVisibleColumns =
    <LibraryFieldIdRuntime>{
  MangaFieldIds.publisher,
  MangaFieldIds.releaseDate,
  MangaFieldIds.barcode,
};

final mangaAdditionalCatalogItemWorkspaceColumnDefinitions = [
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
      MangaAdditionalCatalogItemWorkspaceFields.publisher,
      defaultWidth: 140),
  columnFromField<MangaKind, MangaWorkspaceDto, DateTime?>(
    MangaAdditionalCatalogItemWorkspaceFields.releaseDate,
    cellValue: (context) => Text(_formatDate(context.dto.releaseDate)),
    defaultWidth: 118,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaAdditionalCatalogItemWorkspaceFields.barcode,
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
