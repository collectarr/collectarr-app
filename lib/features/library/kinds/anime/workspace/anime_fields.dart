import 'package:collectarr_app/features/library/config/common_fields.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_fields.dart'
    as movie_workspace;
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

final animeLibraryFieldDefinitions = [
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('anime.title'),
    label: 'Title',
    getValue: (dto) => dto.title,
  ),
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('anime.series'),
    label: 'Series',
    getValue: (dto) => dto.seriesTitle,
  ),
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('anime.number'),
    label: 'Number',
    getValue: (dto) => dto.itemNumber,
  ),
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('anime.publisher'),
    label: 'Publisher',
    getValue: (dto) => dto.publisher,
  ),
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('anime.release_date'),
    label: 'Release date',
    getValue: (dto) => dto.releaseDate,
  ),
];

const animeLibraryGroupModes = movie_workspace.movieLibraryGroupModes;

final animeLibraryGroupDefinitions =
    movie_workspace.movieLibraryGroupDefinitions;

final animeLibrarySortDefinitions =
    movie_workspace.movieLibrarySortDefinitions;

const animeLibrarySortColumns = [
  LibrarySortColumn.series,
  LibrarySortColumn.publisher,
  LibrarySortColumn.status,
  LibrarySortColumn.title,
  LibrarySortColumn.releaseDate,
  LibrarySortColumn.country,
  LibrarySortColumn.language,
  LibrarySortColumn.ageRating,
  LibrarySortColumn.collectionStatus,
  LibrarySortColumn.added,
  LibrarySortColumn.updated,
];

const animeLibraryTableColumns = [
  LibraryTableColumn.status,
  LibraryTableColumn.cover,
  LibraryTableColumn.title,
  LibraryTableColumn.publisher,
  LibraryTableColumn.releaseDate,
  LibraryTableColumn.country,
  LibraryTableColumn.language,
  LibraryTableColumn.ageRating,
  LibraryTableColumn.wishlist,
  LibraryTableColumn.updated,
];

const animeLibraryDefaultVisibleColumns = {
  LibraryTableColumn.status,
  LibraryTableColumn.cover,
  LibraryTableColumn.title,
  LibraryTableColumn.publisher,
  LibraryTableColumn.releaseDate,
  LibraryTableColumn.country,
  LibraryTableColumn.language,
  LibraryTableColumn.ageRating,
  LibraryTableColumn.wishlist,
  LibraryTableColumn.updated,
};

final animeLibraryColumnDefinitions = [
  ...commonColumnDefinitions,
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('variant'),
    label: 'Edition / Release',
    getValue: (entry) => entry.variant,
    cellValue: (entry) => Text(entry.variant ?? ''),
    defaultWidth: 170,
    maxWidth: 420,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('barcode'),
    label: 'UPC / Barcode',
    getValue: (entry) => entry.barcode,
    cellValue: (entry) => Text(entry.barcode ?? ''),
    group: 'Edition',
    defaultWidth: 160,
    maxWidth: 260,
  ),
];

const animeLibraryDefaultVisibleColumnIds = {
  'status',
  'cover',
  'title',
  'publisher',
  'release_date',
  'country',
  'language',
  'age_rating',
  'wishlist',
  'updated'
};
