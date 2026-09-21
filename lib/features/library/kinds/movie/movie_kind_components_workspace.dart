part of 'movie_kind_components.dart';

final movieKindWorkspace = TypedLibraryKindWorkspace<MovieWorkspaceDto>(
  entityWorkspaces: {
    LibraryEntityScope.work: TypedLibraryEntityWorkspace<MovieWorkspaceDto>(
      scope: LibraryEntityScope.work,
      fields: movieLibraryEntityWorkspaceSchema
          .forScope(LibraryEntityScope.work)
          .toRegistry(),
      projector: const MovieWorkspaceProjector(
        expectedScope: LibraryEntityScope.work,
      ),
    ),
    LibraryEntityScope.release: TypedLibraryEntityWorkspace<MovieWorkspaceDto>(
      scope: LibraryEntityScope.release,
      fields: movieLibraryEntityWorkspaceSchema
          .forScope(
            LibraryEntityScope.release,
            defaultSort: MovieSortIds.releaseDate,
            defaultGroup: MovieGroupIds.releaseYear,
          )
          .toRegistry(),
      projector: const MovieWorkspaceProjector(
        expectedScope: LibraryEntityScope.release,
      ),
    ),
    LibraryEntityScope.copy: TypedLibraryEntityWorkspace<MovieWorkspaceDto>(
      scope: LibraryEntityScope.copy,
      fields: movieLibraryEntityWorkspaceSchema
          .forScope(
            LibraryEntityScope.copy,
            defaultSort: MovieSortIds.status,
            defaultGroup: MovieGroupIds.condition,
          )
          .toRegistry(),
      projector: const MovieWorkspaceProjector(
        expectedScope: LibraryEntityScope.copy,
      ),
    ),
  },
  hierarchy: movieKindHierarchy,
  trackingTopology: movieKindTrackingTopology,
);
