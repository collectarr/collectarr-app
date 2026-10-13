import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_ids.dart';
import 'package:collectarr_app/features/library/kinds/movie/config/movie_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/movie/config/movie_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_bucket_mutators.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:flutter/material.dart';

abstract final class MovieCatalogEditionWorkspaceFields {
  static final publisher = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.publisher,
    metadata: MovieWorkspaceFieldMetadata.publisher,
    getValue: (dto) => dto.publisher,
  );

  static final releaseDate = dateField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.releaseDate,
    metadata: MovieFieldIdentities.releaseDate,
    getValue: (dto) => dto.releaseDate,
  );

  static final barcode = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.barcode,
    metadata: MovieFieldIdentities.barcode,
    getValue: (dto) => dto.barcode,
  );

  static final format = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.format,
    metadata: MovieFieldIdentities.format,
    getValue: (dto) => dto.format,
  );

  static final releaseYear = numberField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.releaseYear,
    metadata: MovieWorkspaceFieldMetadata.releaseYear,
    getValue: (dto) => dto.releaseDate?.year,
  );

  static final edition = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.edition,
    metadata: MovieWorkspaceFieldMetadata.edition,
    getValue: (dto) => dto.title,
  );

  static final audioTracks = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.audioTracks,
    metadata: MovieWorkspaceFieldMetadata.audioTracks,
    getValue: (dto) => dto.metadata.audioTracks,
  );

  static final editionReleaseDate = dateField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.editionReleaseDate,
    metadata: MovieWorkspaceFieldMetadata.editionReleaseDate,
    getValue: (dto) => dto.releaseDate,
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
  if (MovieFieldIdentities.format.groupable)
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
    compare: (left, right) => left.dto.title.compareTo(right.dto.title),
  ),
  sortFromField<MovieKind, MovieWorkspaceDto, String>(
      MovieCatalogEditionWorkspaceFields.publisher),
  if (MovieFieldIdentities.releaseDate.sortable)
    sortFromField<MovieKind, MovieWorkspaceDto, DateTime>(
      MovieCatalogEditionWorkspaceFields.releaseDate,
      defaultAscending: false,
    ),
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
