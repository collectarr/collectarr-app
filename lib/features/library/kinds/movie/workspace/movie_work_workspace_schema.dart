import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_ids.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_bucket_mutators.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:flutter/material.dart';

abstract final class MovieWorkWorkspaceFields {
  static final title = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.title,
    label: 'Title',
    getValue: (dto) => dto.title,
    entityScope: LibraryEntityScope.work,
  );

  static final director = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.director,
    label: 'Director',
    getValue: (dto) => dto.director,
    entityScope: LibraryEntityScope.work,
  );

  static final cover =
      LibraryFieldDefinition<MovieKind, MovieWorkspaceDto, String?>(
    id: MovieFieldIds.cover,
    label: 'Cover',
    getValue: (context) => context.dto.coverImageUrl,
    entityScope: LibraryEntityScope.work,
  );

  static final runtimeMinutes = numberField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.runtimeMinutes,
    label: 'Runtime (min)',
    getValue: (dto) => dto.runtimeMinutes ?? dto.movie.technical.runtimeMinutes,
    entityScope: LibraryEntityScope.work,
  );

  static final genre = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.genre,
    label: 'Genre',
    getValue: (dto) => dto.genres.isNotEmpty ? dto.genres.join(', ') : null,
    entityScope: LibraryEntityScope.work,
  );

  static final audienceRating = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.audienceRating,
    label: 'Audience Rating',
    getValue: (dto) => dto.audienceRating,
    entityScope: LibraryEntityScope.work,
  );

  static final movieOrTvSeries = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.movieOrTvSeries,
    label: 'Movie / TV Series',
    getValue: (dto) => 'Movie',
    entityScope: LibraryEntityScope.work,
  );

  static final originalTitle = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.originalTitle,
    label: 'Original Title',
    getValue: (dto) => dto.originalTitle,
    entityScope: LibraryEntityScope.work,
  );

  static final writer = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.writer,
    label: 'Writer',
    getValue: (dto) => dto.writer,
    entityScope: LibraryEntityScope.work,
  );

  static final producer = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.producer,
    label: 'Producer',
    getValue: (dto) => dto.producer,
    entityScope: LibraryEntityScope.work,
  );

  static final ageRating = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.ageRating,
    label: 'Age Rating',
    getValue: (dto) => dto.ageRating,
    entityScope: LibraryEntityScope.work,
  );
}

final movieWorkWorkspaceFieldDefinitions = [
  MovieWorkWorkspaceFields.title,
  MovieWorkWorkspaceFields.director,
  MovieWorkWorkspaceFields.runtimeMinutes,
  MovieWorkWorkspaceFields.genre,
  MovieWorkWorkspaceFields.audienceRating,
  MovieWorkWorkspaceFields.movieOrTvSeries,
  MovieWorkWorkspaceFields.originalTitle,
  MovieWorkWorkspaceFields.writer,
  MovieWorkWorkspaceFields.producer,
  MovieWorkWorkspaceFields.ageRating,
];

final movieWorkWorkspaceGroupDefinitions = [
  groupFromField<MovieKind, MovieWorkspaceDto, String?>(
    MovieWorkWorkspaceFields.director,
    category: 'Cast & Crew',
    icon: Icons.movie_creation_outlined,
  ),
  groupFromField<MovieKind, MovieWorkspaceDto, String?>(
    MovieWorkWorkspaceFields.genre,
    sidebarTitle: 'Genres',
    category: 'Main',
    icon: Icons.category_outlined,
    supportsBucketManagement: true,
    bucketValueMutator: catalogTransportStringListBucketValueMutator('genres'),
  ),
  groupFromField<MovieKind, MovieWorkspaceDto, String?>(
    MovieWorkWorkspaceFields.audienceRating,
    category: 'Main',
    icon: Icons.star_outline,
  ),
  groupFromField<MovieKind, MovieWorkspaceDto, String?>(
    MovieWorkWorkspaceFields.movieOrTvSeries,
    category: 'Main',
    icon: Icons.tv_outlined,
  ),
];

final movieWorkWorkspaceSortDefinitions = [
  sortFromField<MovieKind, MovieWorkspaceDto, String>(
      MovieWorkWorkspaceFields.director),
  sortFromField<MovieKind, MovieWorkspaceDto, String>(
      MovieWorkWorkspaceFields.title),
  sortFromField<MovieKind, MovieWorkspaceDto, num>(
      MovieWorkWorkspaceFields.runtimeMinutes,
      defaultAscending: false),
];

final movieWorkWorkspaceDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  MovieFieldIds.cover,
  MovieFieldIds.director,
  MovieFieldIds.title,
};

final movieWorkWorkspaceColumnDefinitions = [
  LibraryColumnDefinition<MovieKind, MovieWorkspaceDto, String?>(
    id: MovieFieldIds.cover,
    label: '',
    getValue: MovieWorkWorkspaceFields.cover.getValue,
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
      MovieWorkWorkspaceFields.director,
      defaultWidth: 150),
  columnFromField<MovieKind, MovieWorkspaceDto, String?>(
      MovieWorkWorkspaceFields.title,
      defaultWidth: 260,
      maxWidth: 520),
  columnFromField<MovieKind, MovieWorkspaceDto, num?>(
    MovieWorkWorkspaceFields.runtimeMinutes,
    group: 'Technical',
    isNumeric: true,
    defaultWidth: 100,
  ),
  columnFromField<MovieKind, MovieWorkspaceDto, String?>(
    MovieWorkWorkspaceFields.writer,
    group: 'Cast & Crew',
    defaultWidth: 130,
  ),
  columnFromField<MovieKind, MovieWorkspaceDto, String?>(
    MovieWorkWorkspaceFields.producer,
    group: 'Cast & Crew',
    defaultWidth: 130,
  ),
];

final movieWorkWorkspaceSchema =
    LibraryEntityWorkspaceSchema<MovieKind, MovieWorkspaceDto>(
  kindNamespace: 'movie',
  entityScope: LibraryEntityScope.work,
  fields: movieWorkWorkspaceFieldDefinitions,
  columns: movieWorkWorkspaceColumnDefinitions,
  sorts: movieWorkWorkspaceSortDefinitions,
  groups: movieWorkWorkspaceGroupDefinitions,
  primaryColumn: MovieFieldIds.title,
  defaultVisibleColumns: movieWorkWorkspaceDefaultVisibleColumns,
  defaultSort: MovieSortIds.director,
  defaultGroup: MovieGroupIds.director,
  preferenceCodec: const MoviePreferenceCodec(),
);
