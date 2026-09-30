import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_ids.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_bucket_mutators.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:flutter/material.dart';

abstract final class MovieCatalogEditionWorkspaceFields {
  static final publisher = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.publisher,
    label: 'Studio / Publisher',
    getValue: (dto) => dto.publisher,
    entityScope: LibraryEntityScope.work,
  );

  static final releaseDate = dateField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.releaseDate,
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
    entityScope: LibraryEntityScope.work,
  );

  static final barcode = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.barcode,
    label: 'UPC / Barcode',
    getValue: (dto) => dto.barcode,
    entityScope: LibraryEntityScope.work,
  );

  static final format = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.format,
    label: 'Format',
    getValue: (dto) => dto.format,
    entityScope: LibraryEntityScope.work,
  );

  static final releaseYear = numberField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.releaseYear,
    label: 'Release Year',
    getValue: (dto) => dto.releaseDate?.year,
    entityScope: LibraryEntityScope.work,
  );

  static final edition = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.edition,
    label: 'Edition',
    getValue: (dto) => dto.title,
    entityScope: LibraryEntityScope.work,
  );

  static final audioTracks = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.audioTracks,
    label: 'Audio Tracks',
    getValue: (dto) => dto.movie.audioTracks,
    entityScope: LibraryEntityScope.work,
  );

  static final editionReleaseDate = dateField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.editionReleaseDate,
    label: 'Edition Release Date',
    getValue: (dto) => dto.releaseDate,
    entityScope: LibraryEntityScope.work,
  );
}

final movieCatalogEditionFieldDefinitions = [
  MovieCatalogEditionWorkspaceFields.publisher,
  MovieCatalogEditionWorkspaceFields.releaseDate,
  MovieCatalogEditionWorkspaceFields.format,
  MovieCatalogEditionWorkspaceFields.barcode,
  MovieCatalogEditionWorkspaceFields.releaseYear,
  MovieCatalogEditionWorkspaceFields.audioTracks,
  MovieCatalogEditionWorkspaceFields.editionReleaseDate,
];

final movieCatalogEditionGroupDefinitions = [
  groupFromField<MovieKind, MovieWorkspaceDto, String?>(
    MovieCatalogEditionWorkspaceFields.publisher,
    sidebarTitle: 'Studios',
    category: 'Main',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
    bucketValueMutator: catalogTransportStringBucketValueMutator(
      ['publisher', 'studio'],
    ),
  ),
  groupFromField<MovieKind, MovieWorkspaceDto, num?>(
    MovieCatalogEditionWorkspaceFields.releaseYear,
    category: 'Main',
    icon: Icons.calendar_today_outlined,
  ),
  groupFromField<MovieKind, MovieWorkspaceDto, String?>(
    MovieCatalogEditionWorkspaceFields.format,
    category: 'Edition',
    icon: Icons.album_outlined,
  ),
  groupFromField<MovieKind, MovieWorkspaceDto, String?>(
    MovieCatalogEditionWorkspaceFields.audioTracks,
    category: 'Edition',
    icon: Icons.audiotrack_outlined,
  ),
  groupFromField<MovieKind, MovieWorkspaceDto, DateTime?>(
    MovieCatalogEditionWorkspaceFields.editionReleaseDate,
    category: 'Edition',
    icon: Icons.calendar_today_outlined,
  ),
];

final movieCatalogEditionSortDefinitions = [
  LibrarySortDefinition<MovieKind, MovieWorkspaceDto>(
    id: MovieSortIds.releaseTitle,
    label: 'Release title',
    entityScope: LibraryEntityScope.work,
    compare: (left, right) => left.dto.title.compareTo(right.dto.title),
  ),
  sortFromField<MovieKind, MovieWorkspaceDto, String>(
      MovieCatalogEditionWorkspaceFields.publisher),
  sortFromField<MovieKind, MovieWorkspaceDto, DateTime>(
      MovieCatalogEditionWorkspaceFields.releaseDate,
      defaultAscending: false),
];

final movieCatalogEditionDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  MovieFieldIds.publisher,
  MovieFieldIds.releaseDate,
  MovieFieldIds.format,
  MovieFieldIds.barcode,
};

final movieCatalogEditionColumnDefinitions = [
  columnFromField<MovieKind, MovieWorkspaceDto, String?>(
      MovieCatalogEditionWorkspaceFields.publisher,
      defaultWidth: 140),
  columnFromField<MovieKind, MovieWorkspaceDto, DateTime?>(
    MovieCatalogEditionWorkspaceFields.releaseDate,
    cellValue: (context) => Text(_formatDate(context.dto.releaseDate)),
    defaultWidth: 118,
  ),
  columnFromField<MovieKind, MovieWorkspaceDto, String?>(
      MovieCatalogEditionWorkspaceFields.format,
      defaultWidth: 90),
  columnFromField<MovieKind, MovieWorkspaceDto, String?>(
    MovieCatalogEditionWorkspaceFields.barcode,
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
