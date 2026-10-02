import '../movie_module_dependencies.dart';
import '../config/movie_kind_capabilities.dart';
import 'movie_catalog_item_workspace_schema.dart';

final movieKindWorkspace = TypedLibraryKindWorkspace<MovieWorkspaceDto>(
  entityWorkspaces: {
    LibraryEntityScope.catalogItem: TypedLibraryEntityWorkspace<MovieWorkspaceDto>(
      scope: LibraryEntityScope.catalogItem,
      fields: movieCatalogItemWorkspaceSchema.toRegistry(),
      projector: const MovieWorkspaceProjector(
        expectedScope: LibraryEntityScope.catalogItem,
      ),
    ),
    LibraryEntityScope.collectionItem: TypedLibraryEntityWorkspace<MovieWorkspaceDto>(
      scope: LibraryEntityScope.collectionItem,
      fields: movieCopyWorkspaceSchema.toRegistry(),
      projector: const MovieWorkspaceProjector(
        expectedScope: LibraryEntityScope.collectionItem,
      ),
    ),
  },
  hierarchy: movieKindHierarchy,
  trackingTopology: movieKindTrackingTopology,
);
