import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_ids.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:flutter/material.dart';

abstract final class AnimeReleaseWorkspaceFields {
  static final publisher = textField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.publisher,
    label: 'Publisher',
    getValue: (dto) => dto.publisher,
    entityScope: LibraryEntityScope.release,
  );

  static final releaseDate = dateField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.releaseDate,
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
    entityScope: LibraryEntityScope.release,
  );

  static final releaseYear = numberField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.releaseYear,
    label: 'Release Year',
    getValue: (dto) => dto.releaseDate?.year,
    entityScope: LibraryEntityScope.release,
  );

  static final barcode = textField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.barcode,
    label: 'UPC / Barcode',
    getValue: (dto) => dto.barcode,
    entityScope: LibraryEntityScope.release,
  );
}

final animeReleaseWorkspaceFieldDefinitions = [
  AnimeReleaseWorkspaceFields.publisher,
  AnimeReleaseWorkspaceFields.releaseDate,
  AnimeReleaseWorkspaceFields.releaseYear,
  AnimeReleaseWorkspaceFields.barcode,
];

final animeReleaseWorkspaceGroupDefinitions = [
  groupFromField<AnimeKind, AnimeWorkspaceDto, num?>(
    AnimeReleaseWorkspaceFields.releaseYear,
    sidebarTitle: 'Release Years',
    icon: Icons.calendar_today_outlined,
  ),
];

final animeReleaseWorkspaceSortDefinitions = [
  LibrarySortDefinition<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeSortIds.releaseTitle,
    label: 'Release title',
    entityScope: LibraryEntityScope.release,
    compare: (left, right) => left.dto.title.compareTo(right.dto.title),
  ),
  sortFromField<AnimeKind, AnimeWorkspaceDto, String>(
      AnimeReleaseWorkspaceFields.publisher),
  sortFromField<AnimeKind, AnimeWorkspaceDto, DateTime>(
      AnimeReleaseWorkspaceFields.releaseDate,
      defaultAscending: false),
];

final animeReleaseWorkspaceDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  AnimeFieldIds.publisher,
  AnimeFieldIds.releaseDate,
  AnimeFieldIds.barcode,
};

final animeReleaseWorkspaceColumnDefinitions = [
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
      AnimeReleaseWorkspaceFields.publisher,
      defaultWidth: 140),
  columnFromField<AnimeKind, AnimeWorkspaceDto, DateTime?>(
    AnimeReleaseWorkspaceFields.releaseDate,
    cellValue: (context) => Text(_formatDate(context.dto.releaseDate)),
    defaultWidth: 118,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeReleaseWorkspaceFields.barcode,
    group: 'Edition',
    defaultWidth: 160,
    maxWidth: 260,
  ),
];

final animeReleaseWorkspaceSchema =
    LibraryEntityWorkspaceSchema<AnimeKind, AnimeWorkspaceDto>(
  kindNamespace: 'anime',
  entityScope: LibraryEntityScope.release,
  fields: animeReleaseWorkspaceFieldDefinitions,
  columns: animeReleaseWorkspaceColumnDefinitions,
  sorts: animeReleaseWorkspaceSortDefinitions,
  groups: animeReleaseWorkspaceGroupDefinitions,
  primaryColumn: AnimeFieldIds.publisher,
  defaultVisibleColumns: animeReleaseWorkspaceDefaultVisibleColumns,
  defaultSort: AnimeSortIds.releaseDate,
  defaultGroup: AnimeGroupIds.releaseYear,
  preferenceCodec: const AnimePreferenceCodec(),
);

String _formatDate(DateTime? value) {
  if (value == null) return '';
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
