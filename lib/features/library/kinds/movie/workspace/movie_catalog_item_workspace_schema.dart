import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_ids.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_work_workspace_schema.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_release_workspace_schema.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';

/// One field set for a concrete Movie catalog item.
///
/// The previous work and release field groups now describe the same item and
/// are registered together at its root workspace scope.
final movieCatalogItemWorkspaceSchema =
    LibraryEntityWorkspaceSchema<MovieKind, MovieWorkspaceDto>(
  kindNamespace: 'movie',
  entityScope: LibraryEntityScope.work,
  fields: [
    ...movieWorkWorkspaceFieldDefinitions,
    ...movieReleaseWorkspaceFieldDefinitions,
  ],
  columns: [
    ...movieWorkWorkspaceColumnDefinitions,
    ...movieReleaseWorkspaceColumnDefinitions,
  ],
  sorts: [
    ...movieWorkWorkspaceSortDefinitions,
    ...movieReleaseWorkspaceSortDefinitions,
  ],
  groups: [
    ...movieWorkWorkspaceGroupDefinitions,
    ...movieReleaseWorkspaceGroupDefinitions,
  ],
  primaryColumn: MovieFieldIds.title,
  defaultVisibleColumns: {
    ...movieWorkWorkspaceDefaultVisibleColumns,
    ...movieReleaseWorkspaceDefaultVisibleColumns,
  },
  defaultSort: MovieSortIds.director,
  defaultGroup: MovieGroupIds.director,
  preferenceCodec: const MoviePreferenceCodec(),
);
