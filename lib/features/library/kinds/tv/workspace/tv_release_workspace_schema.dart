import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:flutter/material.dart';

abstract final class TvReleaseWorkspaceFields {
  static final releaseDate = dateField<TvKind, TvWorkspaceDto>(
    id: TvFieldIds.releaseDate,
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
    entityScope: LibraryEntityScope.release,
  );

  static final releaseYear = numberField<TvKind, TvWorkspaceDto>(
    id: TvFieldIds.releaseYear,
    label: 'Release Year',
    getValue: (dto) => dto.releaseDate?.year,
    entityScope: LibraryEntityScope.release,
  );

  static final barcode = textField<TvKind, TvWorkspaceDto>(
    id: TvFieldIds.barcode,
    label: 'UPC / Barcode',
    getValue: (dto) => dto.barcode,
    entityScope: LibraryEntityScope.release,
  );
}

final tvReleaseWorkspaceFieldDefinitions = [
  TvReleaseWorkspaceFields.releaseDate,
  TvReleaseWorkspaceFields.releaseYear,
  TvReleaseWorkspaceFields.barcode,
];

final tvReleaseWorkspaceGroupDefinitions = [
  groupFromField<TvKind, TvWorkspaceDto, num?>(
    TvReleaseWorkspaceFields.releaseYear,
    sidebarTitle: 'Release Years',
    icon: Icons.calendar_today_outlined,
  ),
];

final tvReleaseWorkspaceSortDefinitions = [
  LibrarySortDefinition<TvKind, TvWorkspaceDto>(
    id: TvSortIds.releaseTitle,
    label: 'Release title',
    entityScope: LibraryEntityScope.release,
    compare: (left, right) => left.dto.title.compareTo(right.dto.title),
  ),
  sortFromField<TvKind, TvWorkspaceDto, DateTime>(
      TvReleaseWorkspaceFields.releaseDate,
      defaultAscending: false),
];

final tvReleaseWorkspaceDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  TvFieldIds.releaseDate,
  TvFieldIds.barcode,
};

final tvReleaseWorkspaceColumnDefinitions = [
  columnFromField<TvKind, TvWorkspaceDto, DateTime?>(
    TvReleaseWorkspaceFields.releaseDate,
    cellValue: (context) => Text(_formatDate(context.dto.releaseDate)),
    defaultWidth: 118,
  ),
  columnFromField<TvKind, TvWorkspaceDto, String?>(
    TvReleaseWorkspaceFields.barcode,
    group: 'Edition',
    defaultWidth: 160,
    maxWidth: 260,
  ),
];

final tvReleaseWorkspaceSchema =
    LibraryEntityWorkspaceSchema<TvKind, TvWorkspaceDto>(
  kindNamespace: 'tv',
  entityScope: LibraryEntityScope.release,
  fields: tvReleaseWorkspaceFieldDefinitions,
  columns: tvReleaseWorkspaceColumnDefinitions,
  sorts: tvReleaseWorkspaceSortDefinitions,
  groups: tvReleaseWorkspaceGroupDefinitions,
  primaryColumn: TvFieldIds.releaseDate,
  defaultVisibleColumns: tvReleaseWorkspaceDefaultVisibleColumns,
  defaultSort: TvSortIds.releaseDate,
  defaultGroup: TvGroupIds.releaseYear,
  preferenceCodec: const TvPreferenceCodec(),
);

String _formatDate(DateTime? value) {
  if (value == null) return '';
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
