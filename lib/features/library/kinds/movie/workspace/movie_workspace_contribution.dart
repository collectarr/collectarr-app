import '../movie_module_dependencies.dart';
import '../config/movie_kind_capabilities.dart';

final movieKindWorkspace = TypedLibraryKindWorkspace<MovieWorkspaceDto>(
  entityWorkspaces: {
    LibraryEntityScope.work: TypedLibraryEntityWorkspace<MovieWorkspaceDto>(
      scope: LibraryEntityScope.work,
      fields: movieWorkWorkspaceSchema.toRegistry(),
      projector: const MovieWorkspaceProjector(
        expectedScope: LibraryEntityScope.work,
      ),
    ),
    LibraryEntityScope.release: TypedLibraryEntityWorkspace<MovieWorkspaceDto>(
      scope: LibraryEntityScope.release,
      fields: movieReleaseWorkspaceSchema.toRegistry(),
      projector: const MovieWorkspaceProjector(
        expectedScope: LibraryEntityScope.release,
      ),
    ),
    LibraryEntityScope.copy: TypedLibraryEntityWorkspace<MovieWorkspaceDto>(
      scope: LibraryEntityScope.copy,
      fields: movieCopyWorkspaceSchema.toRegistry(),
      projector: const MovieWorkspaceProjector(
        expectedScope: LibraryEntityScope.copy,
      ),
    ),
  },
  hierarchy: movieKindHierarchy,
  trackingTopology: movieKindTrackingTopology,
);
