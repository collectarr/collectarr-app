import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_ids.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_bucket_mutators.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:flutter/material.dart';

abstract final class MangaReleaseWorkspaceFields {
  static final publisher = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.publisher,
    label: 'Publisher',
    getValue: (dto) => dto.publisher,
    entityScope: LibraryEntityScope.release,
  );

  static final releaseDate = dateField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.releaseDate,
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
    entityScope: LibraryEntityScope.release,
  );

  static final barcode = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.barcode,
    label: 'ISBN / Barcode',
    getValue: (dto) => dto.barcode,
    entityScope: LibraryEntityScope.release,
  );
}

final mangaReleaseWorkspaceFieldDefinitions = [
  MangaReleaseWorkspaceFields.publisher,
  MangaReleaseWorkspaceFields.releaseDate,
  MangaReleaseWorkspaceFields.barcode,
];

final mangaReleaseWorkspaceGroupDefinitions = [
  groupFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaReleaseWorkspaceFields.publisher,
    sidebarTitle: 'Publishers',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
    bucketValueMutator: catalogTransportStringBucketValueMutator(
      ['publisher', 'original_publisher', 'localized_publisher'],
    ),
  ),
];

final mangaReleaseWorkspaceSortDefinitions = [
  LibrarySortDefinition<MangaKind, MangaWorkspaceDto>(
    id: MangaSortIds.releaseTitle,
    label: 'Release title',
    entityScope: LibraryEntityScope.release,
    compare: (left, right) => left.dto.title.compareTo(right.dto.title),
  ),
  sortFromField<MangaKind, MangaWorkspaceDto, String>(
      MangaReleaseWorkspaceFields.publisher),
  sortFromField<MangaKind, MangaWorkspaceDto, DateTime>(
      MangaReleaseWorkspaceFields.releaseDate,
      defaultAscending: false),
];

final mangaReleaseWorkspaceDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  MangaFieldIds.publisher,
  MangaFieldIds.releaseDate,
  MangaFieldIds.barcode,
};

final mangaReleaseWorkspaceColumnDefinitions = [
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
      MangaReleaseWorkspaceFields.publisher,
      defaultWidth: 140),
  columnFromField<MangaKind, MangaWorkspaceDto, DateTime?>(
    MangaReleaseWorkspaceFields.releaseDate,
    cellValue: (context) => Text(_formatDate(context.dto.releaseDate)),
    defaultWidth: 118,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaReleaseWorkspaceFields.barcode,
    group: 'Edition',
    defaultWidth: 160,
    maxWidth: 260,
  ),
];

final mangaReleaseWorkspaceSchema =
    LibraryEntityWorkspaceSchema<MangaKind, MangaWorkspaceDto>(
  kindNamespace: 'manga',
  entityScope: LibraryEntityScope.release,
  fields: mangaReleaseWorkspaceFieldDefinitions,
  columns: mangaReleaseWorkspaceColumnDefinitions,
  sorts: mangaReleaseWorkspaceSortDefinitions,
  groups: mangaReleaseWorkspaceGroupDefinitions,
  primaryColumn: MangaFieldIds.publisher,
  defaultVisibleColumns: mangaReleaseWorkspaceDefaultVisibleColumns,
  defaultSort: MangaSortIds.releaseDate,
  defaultGroup: MangaGroupIds.publisher,
  preferenceCodec: const MangaPreferenceCodec(),
);

String _formatDate(DateTime? value) {
  if (value == null) return '';
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
