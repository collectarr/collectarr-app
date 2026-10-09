import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_ids.dart';
import 'package:collectarr_app/features/library/kinds/movie/config/movie_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/movie/config/movie_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_bucket_mutators.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:flutter/material.dart';

abstract final class MovieCatalogIdentityWorkspaceFields {
  static final title = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.title,
    metadata: MovieFieldIdentities.title,
    getValue: (dto) => dto.title,
  );

  static final director = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.director,
    metadata: MovieWorkspaceFieldMetadata.director,
    getValue: (dto) => dto.director,
  );

  static final studio = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.studio,
    metadata: MovieWorkspaceFieldMetadata.studio,
    getValue: (dto) => dto.studio,
  );

  static final cover =
      LibraryFieldDefinition<MovieKind, MovieWorkspaceDto, String?>(
    id: MovieFieldIds.cover,
    metadata: MovieWorkspaceFieldMetadata.cover,
    getValue: (context) => context.dto.coverImageUrl,
  );

  static final runtimeMinutes = numberField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.runtimeMinutes,
    metadata: MovieFieldIdentities.runtimeMinutes,
    getValue: (dto) => dto.runtimeMinutes,
  );

  static final genre = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.genre,
    metadata: MovieFieldIdentities.genre,
    getValue: (dto) => dto.genres.isNotEmpty ? dto.genres.join(', ') : null,
  );

  static final audienceRating = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.audienceRating,
    metadata: MovieFieldIdentities.audienceRating,
    getValue: (dto) => dto.audienceRating,
  );

  static final movieOrTvSeries = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.movieOrTvSeries,
    metadata: MovieWorkspaceFieldMetadata.movieOrTvSeries,
    getValue: (dto) => 'Movie',
  );

  static final originalTitle = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.originalTitle,
    metadata: MovieFieldIdentities.originalTitle,
    getValue: (dto) => dto.originalTitle,
  );

  static final writer = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.writer,
    metadata: MovieWorkspaceFieldMetadata.writer,
    getValue: (dto) => dto.writer,
  );

  static final producer = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.producer,
    metadata: MovieWorkspaceFieldMetadata.producer,
    getValue: (dto) => dto.producer,
  );

  static final ageRating = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.ageRating,
    metadata: MovieFieldIdentities.ageRating,
    getValue: (dto) => dto.ageRating,
  );
}

final movieCatalogIdentityFieldDefinitions = [
  MovieCatalogIdentityWorkspaceFields.title,
  MovieCatalogIdentityWorkspaceFields.director,
  MovieCatalogIdentityWorkspaceFields.studio,
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
  if (MovieFieldIdentities.genre.groupable)
    groupFromField<MovieKind, MovieWorkspaceDto, String?>(
      MovieCatalogIdentityWorkspaceFields.genre,
      sidebarTitle: 'Genres',
      category: 'Main',
      icon: Icons.category_outlined,
      supportsBucketManagement: true,
      bucketValueMutator:
          catalogTransportStringListBucketValueMutator('genres'),
    ),
  if (MovieFieldIdentities.audienceRating.groupable)
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
  if (MovieFieldIdentities.title.sortable)
    sortFromField<MovieKind, MovieWorkspaceDto, String>(
      MovieCatalogIdentityWorkspaceFields.title,
    ),
  if (MovieFieldIdentities.runtimeMinutes.sortable)
    sortFromField<MovieKind, MovieWorkspaceDto, num>(
      MovieCatalogIdentityWorkspaceFields.runtimeMinutes,
      defaultAscending: false,
    ),
];

final movieCatalogIdentityDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  MovieFieldIds.cover,
  MovieFieldIds.director,
  MovieFieldIds.title,
};

final movieCatalogIdentityColumnDefinitions = [
  LibraryColumnDefinition<MovieKind, MovieWorkspaceDto, String?>(
    id: MovieFieldIds.cover,
    metadata: MovieWorkspaceFieldMetadata.cover,
    getValue: MovieCatalogIdentityWorkspaceFields.cover.getValue,
    cellValue: (context) => context.dto.coverImageUrl == null
        ? const SizedBox.shrink()
        : Image.network(
            context.dto.coverImageUrl!,
            width: 32,
            height: 32,
            fit: BoxFit.cover,
          ),
    allowSortInteraction: false,
    allowGroupInteraction: false,
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
