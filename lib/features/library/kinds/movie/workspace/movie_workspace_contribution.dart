import '../movie_module_dependencies.dart';
import '../config/movie_kind_capabilities.dart';
import 'movie_catalog_item_workspace_schema.dart';

final movieKindWorkspace = TypedLibraryKindWorkspace<MovieWorkspaceDto>(
  entityWorkspaces: {
    LibraryEntityScope.catalogItem:
        TypedLibraryEntityWorkspace<MovieWorkspaceDto>(
      scope: LibraryEntityScope.catalogItem,
      fields: movieCatalogItemWorkspaceSchema.toRegistry(),
      projector: const MovieWorkspaceProjector(
        expectedScope: LibraryEntityScope.catalogItem,
      ),
    ),
    LibraryEntityScope.libraryEntry:
        TypedLibraryEntityWorkspace<MovieWorkspaceDto>(
      scope: LibraryEntityScope.libraryEntry,
      fields: movieLibraryEntryWorkspaceSchema.toRegistry(),
      projector: const MovieWorkspaceProjector(
        expectedScope: LibraryEntityScope.libraryEntry,
      ),
    ),
  },
  hierarchy: movieKindHierarchy,
  trackingTopology: movieKindTrackingTopology,
);
