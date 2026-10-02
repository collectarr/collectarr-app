import '../tv_module_dependencies.dart';
import '../config/tv_kind_capabilities.dart';

final tvKindWorkspace = TypedLibraryKindWorkspace<TvWorkspaceDto>(
  entityWorkspaces: {
    LibraryEntityScope.catalogItem: TypedLibraryEntityWorkspace<TvWorkspaceDto>(
      scope: LibraryEntityScope.catalogItem,
      fields: tvWorkWorkspaceSchema.toRegistry(),
      projector: const TvWorkspaceProjector(
        expectedScope: LibraryEntityScope.catalogItem,
      ),
    ),
    LibraryEntityScope.collectionItem: TypedLibraryEntityWorkspace<TvWorkspaceDto>(
      scope: LibraryEntityScope.collectionItem,
      fields: tvCopyWorkspaceSchema.toRegistry(),
      projector: const TvWorkspaceProjector(
        expectedScope: LibraryEntityScope.collectionItem,
      ),
    ),
  },
  hierarchy: tvKindHierarchy,
  trackingTopology: tvKindTrackingTopology,
);
