import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_bucket_mutators.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_preference_codec.dart';
import 'package:flutter/material.dart';

abstract final class ComicReleaseWorkspaceFields {
  static final publisher = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.publisher,
    label: 'Publisher',
    getValue: (dto) => dto.publisher,
    entityScope: LibraryEntityScope.release,
  );

  static final releaseDate = dateField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.releaseDate,
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
    entityScope: LibraryEntityScope.release,
  );

  static final barcode = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.barcode,
    label: 'Barcode',
    getValue: (dto) => dto.barcode,
    entityScope: LibraryEntityScope.release,
  );

  static final variant = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.variant,
    label: 'Variant',
    getValue: (dto) => dto.variant,
    entityScope: LibraryEntityScope.release,
  );
}

final comicReleaseWorkspaceFieldDefinitions = [
  ComicReleaseWorkspaceFields.publisher,
  ComicReleaseWorkspaceFields.releaseDate,
  ComicReleaseWorkspaceFields.barcode,
  ComicReleaseWorkspaceFields.variant,
];

final comicReleaseWorkspaceGroupDefinitions = [
  groupFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicReleaseWorkspaceFields.publisher,
    sidebarTitle: 'Publishers',
    category: 'Main',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
    bucketValueMutator: catalogTransportStringBucketValueMutator(
      ['publisher', 'original_publisher'],
      nestedContainerKey: 'publishing',
      nestedValueKey: 'original_publisher',
    ),
  ),
];

final comicReleaseWorkspaceSortDefinitions = [
  LibrarySortDefinition<ComicKind, ComicWorkspaceDto>(
    id: ComicSortIds.releaseTitle,
    label: 'Release title',
    entityScope: LibraryEntityScope.release,
    compare: (left, right) => left.dto.title.compareTo(right.dto.title),
  ),
  sortFromField<ComicKind, ComicWorkspaceDto, String>(
      ComicReleaseWorkspaceFields.publisher),
  sortFromField<ComicKind, ComicWorkspaceDto, DateTime>(
      ComicReleaseWorkspaceFields.releaseDate,
      defaultAscending: false),
];

final comicReleaseWorkspaceDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  ComicFieldIds.publisher,
  ComicFieldIds.releaseDate,
};

final comicReleaseWorkspaceColumnDefinitions = [
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
      ComicReleaseWorkspaceFields.publisher,
      defaultWidth: 140),
  columnFromField<ComicKind, ComicWorkspaceDto, DateTime?>(
    ComicReleaseWorkspaceFields.releaseDate,
    cellValue: (context) => Text(_formatDate(context.dto.releaseDate)),
    defaultWidth: 118,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicReleaseWorkspaceFields.barcode,
    group: 'Edition',
    defaultWidth: 160,
    maxWidth: 260,
  ),
];

final comicReleaseWorkspaceSchema =
    LibraryEntityWorkspaceSchema<ComicKind, ComicWorkspaceDto>(
  kindNamespace: 'comic',
  entityScope: LibraryEntityScope.release,
  fields: comicReleaseWorkspaceFieldDefinitions,
  columns: comicReleaseWorkspaceColumnDefinitions,
  sorts: comicReleaseWorkspaceSortDefinitions,
  groups: comicReleaseWorkspaceGroupDefinitions,
  primaryColumn: ComicFieldIds.publisher,
  defaultVisibleColumns: comicReleaseWorkspaceDefaultVisibleColumns,
  defaultSort: ComicSortIds.releaseDate,
  defaultGroup: ComicGroupIds.publisher,
  preferenceCodec: const IdentityLibraryWorkspacePreferenceCodec<ComicKind>(),
);

String _formatDate(DateTime? value) {
  if (value == null) return '';
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
