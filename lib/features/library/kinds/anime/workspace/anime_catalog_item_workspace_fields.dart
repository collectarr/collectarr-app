import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_ids.dart';
import 'package:collectarr_app/features/library/kinds/anime/config/anime_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:flutter/material.dart';

abstract final class AnimeAdditionalCatalogItemWorkspaceFields {
  static final publisher = textField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.publisher,
    label: 'Publisher',
    getValue: (dto) => dto.publisher,
    searchable: true,
  );

  static final releaseDate = dateField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.releaseDate,
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
  );

  static final releaseYear = numberField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.releaseYear,
    label: 'Release Year',
    getValue: (dto) => dto.releaseDate?.year,
  );

  static final barcode = textField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.barcode,
    label: AnimeFieldIdentities.barcodeLabel,
    getValue: (dto) => dto.barcode,
    searchable: AnimeFieldIdentities.barcode.searchable,
  );
}

final animeAdditionalCatalogItemWorkspaceFieldDefinitions = [
  AnimeAdditionalCatalogItemWorkspaceFields.publisher,
  AnimeAdditionalCatalogItemWorkspaceFields.releaseDate,
  AnimeAdditionalCatalogItemWorkspaceFields.releaseYear,
  AnimeAdditionalCatalogItemWorkspaceFields.barcode,
];

final animeAdditionalCatalogItemWorkspaceGroupDefinitions = [
  groupFromField<AnimeKind, AnimeWorkspaceDto, num?>(
    AnimeAdditionalCatalogItemWorkspaceFields.releaseYear,
    sidebarTitle: 'Release Years',
    icon: Icons.calendar_today_outlined,
  ),
];

final animeAdditionalCatalogItemWorkspaceSortDefinitions = [
  LibrarySortDefinition<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeSortIds.releaseTitle,
    label: 'Release title',
    compare: (left, right) => left.dto.title.compareTo(right.dto.title),
  ),
  sortFromField<AnimeKind, AnimeWorkspaceDto, String>(
      AnimeAdditionalCatalogItemWorkspaceFields.publisher),
  sortFromField<AnimeKind, AnimeWorkspaceDto, DateTime>(
      AnimeAdditionalCatalogItemWorkspaceFields.releaseDate,
      defaultAscending: false),
];

final animeAdditionalCatalogItemWorkspaceDefaultVisibleColumns =
    <LibraryFieldIdRuntime>{
  AnimeFieldIds.publisher,
  AnimeFieldIds.releaseDate,
  AnimeFieldIds.barcode,
};

final animeAdditionalCatalogItemWorkspaceColumnDefinitions = [
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
      AnimeAdditionalCatalogItemWorkspaceFields.publisher,
      defaultWidth: 140),
  columnFromField<AnimeKind, AnimeWorkspaceDto, DateTime?>(
    AnimeAdditionalCatalogItemWorkspaceFields.releaseDate,
    cellValue: (context) => Text(_formatDate(context.dto.releaseDate)),
    defaultWidth: 118,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeAdditionalCatalogItemWorkspaceFields.barcode,
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
