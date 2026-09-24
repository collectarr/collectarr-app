import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_ids.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_bucket_mutators.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:flutter/material.dart';

abstract final class MovieReleaseWorkspaceFields {
  static final publisher = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.publisher,
    label: 'Studio / Publisher',
    getValue: (dto) => dto.studio ?? dto.publisher,
    entityScope: LibraryEntityScope.release,
  );

  static final releaseDate = dateField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.releaseDate,
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
    entityScope: LibraryEntityScope.release,
  );

  static final barcode = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.barcode,
    label: 'UPC / Barcode',
    getValue: (dto) => dto.barcode,
    entityScope: LibraryEntityScope.release,
  );

  static final format = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.format,
    label: 'Format',
    getValue: (dto) => dto.format,
    entityScope: LibraryEntityScope.release,
  );

  static final releaseYear = numberField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.releaseYear,
    label: 'Release Year',
    getValue: (dto) => dto.releaseDate?.year,
    entityScope: LibraryEntityScope.release,
  );

  static final edition = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.edition,
    label: 'Edition',
    getValue: (dto) => dto.release?.title,
    entityScope: LibraryEntityScope.release,
  );

  static final audioTracks = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.audioTracks,
    label: 'Audio Tracks',
    getValue: (dto) =>
        dto.release?.videoDetails?.audioTracks ??
        dto.release?.media.firstOrNull?.audioTracks.firstOrNull,
    entityScope: LibraryEntityScope.release,
  );

  static final editionReleaseDate = dateField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.editionReleaseDate,
    label: 'Edition Release Date',
    getValue: (dto) => dto.release?.releaseDate,
    entityScope: LibraryEntityScope.release,
  );
}

final movieReleaseWorkspaceFieldDefinitions = [
  MovieReleaseWorkspaceFields.publisher,
  MovieReleaseWorkspaceFields.releaseDate,
  MovieReleaseWorkspaceFields.format,
  MovieReleaseWorkspaceFields.barcode,
  MovieReleaseWorkspaceFields.releaseYear,
  MovieReleaseWorkspaceFields.audioTracks,
  MovieReleaseWorkspaceFields.editionReleaseDate,
];

final movieReleaseWorkspaceGroupDefinitions = [
  groupFromField<MovieKind, MovieWorkspaceDto, String?>(
    MovieReleaseWorkspaceFields.publisher,
    sidebarTitle: 'Studios',
    category: 'Main',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
    bucketValueMutator: catalogTransportStringBucketValueMutator(
      ['publisher', 'studio'],
    ),
  ),
  groupFromField<MovieKind, MovieWorkspaceDto, num?>(
    MovieReleaseWorkspaceFields.releaseYear,
    category: 'Main',
    icon: Icons.calendar_today_outlined,
  ),
  groupFromField<MovieKind, MovieWorkspaceDto, String?>(
    MovieReleaseWorkspaceFields.format,
    category: 'Edition',
    icon: Icons.album_outlined,
  ),
  groupFromField<MovieKind, MovieWorkspaceDto, String?>(
    MovieReleaseWorkspaceFields.audioTracks,
    category: 'Edition',
    icon: Icons.audiotrack_outlined,
  ),
  groupFromField<MovieKind, MovieWorkspaceDto, DateTime?>(
    MovieReleaseWorkspaceFields.editionReleaseDate,
    category: 'Edition',
    icon: Icons.calendar_today_outlined,
  ),
];

final movieReleaseWorkspaceSortDefinitions = [
  LibrarySortDefinition<MovieKind, MovieWorkspaceDto>(
    id: MovieSortIds.releaseTitle,
    label: 'Release title',
    entityScope: LibraryEntityScope.release,
    compare: (left, right) => left.dto.title.compareTo(right.dto.title),
  ),
  sortFromField<MovieKind, MovieWorkspaceDto, String>(
      MovieReleaseWorkspaceFields.publisher),
  sortFromField<MovieKind, MovieWorkspaceDto, DateTime>(
      MovieReleaseWorkspaceFields.releaseDate,
      defaultAscending: false),
];

final movieReleaseWorkspaceDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  MovieFieldIds.publisher,
  MovieFieldIds.releaseDate,
  MovieFieldIds.format,
  MovieFieldIds.barcode,
};

final movieReleaseWorkspaceColumnDefinitions = [
  columnFromField<MovieKind, MovieWorkspaceDto, String?>(
      MovieReleaseWorkspaceFields.publisher,
      defaultWidth: 140),
  columnFromField<MovieKind, MovieWorkspaceDto, DateTime?>(
    MovieReleaseWorkspaceFields.releaseDate,
    cellValue: (context) => Text(_formatDate(context.dto.releaseDate)),
    defaultWidth: 118,
  ),
  columnFromField<MovieKind, MovieWorkspaceDto, String?>(
      MovieReleaseWorkspaceFields.format,
      defaultWidth: 90),
  columnFromField<MovieKind, MovieWorkspaceDto, String?>(
    MovieReleaseWorkspaceFields.barcode,
    group: 'Edition',
    defaultWidth: 160,
    maxWidth: 260,
  ),
];

final movieReleaseWorkspaceSchema =
    LibraryEntityWorkspaceSchema<MovieKind, MovieWorkspaceDto>(
  kindNamespace: 'movie',
  entityScope: LibraryEntityScope.release,
  fields: movieReleaseWorkspaceFieldDefinitions,
  columns: movieReleaseWorkspaceColumnDefinitions,
  sorts: movieReleaseWorkspaceSortDefinitions,
  groups: movieReleaseWorkspaceGroupDefinitions,
  primaryColumn: MovieFieldIds.publisher,
  defaultVisibleColumns: movieReleaseWorkspaceDefaultVisibleColumns,
  defaultSort: MovieSortIds.releaseDate,
  defaultGroup: MovieGroupIds.releaseYear,
  preferenceCodec: const MoviePreferenceCodec(),
);

String _formatDate(DateTime? value) {
  if (value == null) return '';
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
