import '../tv_module_dependencies.dart';
import '../config/tv_kind_capabilities.dart';

final tvKindWorkspace = TypedLibraryKindWorkspace<TvWorkspaceDto>(
  entityWorkspaces: {
    LibraryEntityScope.catalogItem: TypedLibraryEntityWorkspace<TvWorkspaceDto>(
      scope: LibraryEntityScope.catalogItem,
      fields: tvCatalogItemWorkspaceSchema.toRegistry(),
      projector: const TvWorkspaceProjector(
        expectedScope: LibraryEntityScope.catalogItem,
      ),
    ),
    LibraryEntityScope.libraryEntry: TypedLibraryEntityWorkspace<TvWorkspaceDto>(
      scope: LibraryEntityScope.libraryEntry,
      fields: tvLibraryEntryWorkspaceSchema.toRegistry(),
      projector: const TvWorkspaceProjector(
        expectedScope: LibraryEntityScope.libraryEntry,
      ),
    ),
  },
  hierarchy: tvKindHierarchy,
  trackingTopology: tvKindTrackingTopology,
);
