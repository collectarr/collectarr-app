import '../movie_module_dependencies.dart';
import '../config/movie_kind_capabilities.dart';
import 'movie_catalog_item_workspace_schema.dart';

final movieKindWorkspace = TypedLibraryKindWorkspace<MovieWorkspaceDto>(
  entityWorkspaces: {
    LibraryEntityScope.work: TypedLibraryEntityWorkspace<MovieWorkspaceDto>(
      scope: LibraryEntityScope.work,
      fields: movieCatalogItemWorkspaceSchema.toRegistry(),
      projector: const MovieWorkspaceProjector(
        expectedScope: LibraryEntityScope.work,
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
