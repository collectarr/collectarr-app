import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_ids.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_bucket_mutators.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:flutter/material.dart';

abstract final class MovieCatalogIdentityWorkspaceFields {
  static final title = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.title,
    label: 'Title',
    getValue: (dto) => dto.title,
  );

  static final director = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.director,
    label: 'Director',
    getValue: (dto) => dto.director,
  );

  static final cover =
      LibraryFieldDefinition<MovieKind, MovieWorkspaceDto, String?>(
    id: MovieFieldIds.cover,
    label: 'Cover',
    getValue: (context) => context.dto.coverImageUrl,
  );

  static final runtimeMinutes = numberField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.runtimeMinutes,
    label: 'Runtime (min)',
    getValue: (dto) => dto.runtimeMinutes,
  );

  static final genre = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.genre,
    label: 'Genre',
    getValue: (dto) => dto.genres.isNotEmpty ? dto.genres.join(', ') : null,
  );

  static final audienceRating = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.audienceRating,
    label: 'Audience Rating',
    getValue: (dto) => dto.audienceRating,
  );

  static final movieOrTvSeries = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.movieOrTvSeries,
    label: 'Movie / TV Series',
    getValue: (dto) => 'Movie',
  );

  static final originalTitle = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.originalTitle,
    label: 'Original Title',
    getValue: (dto) => dto.originalTitle,
  );

  static final writer = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.writer,
    label: 'Writer',
    getValue: (dto) => dto.writer,
  );

  static final producer = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.producer,
    label: 'Producer',
    getValue: (dto) => dto.producer,
  );

  static final ageRating = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.ageRating,
    label: 'Age Rating',
    getValue: (dto) => dto.ageRating,
  );
}

final movieCatalogIdentityFieldDefinitions = [
  MovieCatalogIdentityWorkspaceFields.title,
  MovieCatalogIdentityWorkspaceFields.director,
  MovieCatalogIdentityWorkspaceFields.runtimeMinutes,
  MovieCatalogIdentityWorkspaceFields.genre,
  MovieCatalogIdentityWorkspaceFields.audienceRating,
  MovieCatalogIdentityWorkspaceFields.movieOrTvSeries,
  MovieCatalogIdentityWorkspaceFields.originalTitle,
  MovieCatalogIdentityWorkspaceFields.writer,
  MovieCatalogIdentityWorkspaceFields.producer,
  MovieCatalogIdentityWorkspaceFields.ageRating,
];

final movieCatalogIdentityGroupDefinitions = [
  groupFromField<MovieKind, MovieWorkspaceDto, String?>(
    MovieCatalogIdentityWorkspaceFields.director,
    category: 'Cast & Crew',
    icon: Icons.movie_creation_outlined,
  ),
  groupFromField<MovieKind, MovieWorkspaceDto, String?>(
    MovieCatalogIdentityWorkspaceFields.genre,
    sidebarTitle: 'Genres',
    category: 'Main',
    icon: Icons.category_outlined,
    supportsBucketManagement: true,
    bucketValueMutator: catalogTransportStringListBucketValueMutator('genres'),
  ),
  groupFromField<MovieKind, MovieWorkspaceDto, String?>(
    MovieCatalogIdentityWorkspaceFields.audienceRating,
    category: 'Main',
    icon: Icons.star_outline,
  ),
  groupFromField<MovieKind, MovieWorkspaceDto, String?>(
    MovieCatalogIdentityWorkspaceFields.movieOrTvSeries,
    category: 'Main',
    icon: Icons.tv_outlined,
  ),
];

final movieCatalogIdentitySortDefinitions = [
  sortFromField<MovieKind, MovieWorkspaceDto, String>(
      MovieCatalogIdentityWorkspaceFields.director),
  sortFromField<MovieKind, MovieWorkspaceDto, String>(
      MovieCatalogIdentityWorkspaceFields.title),
  sortFromField<MovieKind, MovieWorkspaceDto, num>(
      MovieCatalogIdentityWorkspaceFields.runtimeMinutes,
      defaultAscending: false),
];

final movieCatalogIdentityDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  MovieFieldIds.cover,
  MovieFieldIds.director,
  MovieFieldIds.title,
};

final movieCatalogIdentityColumnDefinitions = [
  LibraryColumnDefinition<MovieKind, MovieWorkspaceDto, String?>(
    id: MovieFieldIds.cover,
    label: '',
    getValue: MovieCatalogIdentityWorkspaceFields.cover.getValue,
    cellValue: (context) => context.dto.coverImageUrl == null
        ? const SizedBox.shrink()
        : Image.network(
            context.dto.coverImageUrl!,
            width: 32,
            height: 32,
            fit: BoxFit.cover,
          ),
    sortable: false,
    groupable: false,
    defaultWidth: 42,
    minWidth: 44,
  ),
  columnFromField<MovieKind, MovieWorkspaceDto, String?>(
      MovieCatalogIdentityWorkspaceFields.director,
      defaultWidth: 150),
  columnFromField<MovieKind, MovieWorkspaceDto, String?>(
      MovieCatalogIdentityWorkspaceFields.title,
      defaultWidth: 260,
      maxWidth: 520),
  columnFromField<MovieKind, MovieWorkspaceDto, num?>(
    MovieCatalogIdentityWorkspaceFields.runtimeMinutes,
    group: 'Technical',
    isNumeric: true,
    defaultWidth: 100,
  ),
  columnFromField<MovieKind, MovieWorkspaceDto, String?>(
    MovieCatalogIdentityWorkspaceFields.writer,
    group: 'Cast & Crew',
    defaultWidth: 130,
  ),
  columnFromField<MovieKind, MovieWorkspaceDto, String?>(
    MovieCatalogIdentityWorkspaceFields.producer,
    group: 'Cast & Crew',
    defaultWidth: 130,
  ),
];
