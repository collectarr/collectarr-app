import '../music_module_dependencies.dart';
import '../config/music_kind_capabilities.dart';

final musicKindWorkspace = TypedLibraryKindWorkspace<MusicWorkspaceProjection>(
  entityWorkspaces: {
    LibraryEntityScope.catalogItem:
        TypedLibraryEntityWorkspace<MusicWorkspaceProjection>(
      scope: LibraryEntityScope.catalogItem,
      fields: musicCatalogItemWorkspaceSchema.toRegistry(),
      projector: const MusicCatalogItemWorkspaceProjector(),
    ),
    LibraryEntityScope.collectionItem:
        TypedLibraryEntityWorkspace<MusicWorkspaceProjection>(
      scope: LibraryEntityScope.collectionItem,
      fields: musicCollectionItemWorkspaceSchema.toRegistry(),
      projector: const MusicCollectionItemWorkspaceProjector(),
    ),
  },
  hierarchy: musicKindHierarchy,
  trackingTopology: musicKindTrackingTopology,
);
