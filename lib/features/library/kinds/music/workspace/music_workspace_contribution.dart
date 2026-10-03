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
    LibraryEntityScope.libraryEntry:
        TypedLibraryEntityWorkspace<MusicWorkspaceProjection>(
      scope: LibraryEntityScope.libraryEntry,
      fields: musicLibraryEntryWorkspaceSchema.toRegistry(),
      projector: const MusicLibraryEntryWorkspaceProjector(),
    ),
  },
  hierarchy: musicKindHierarchy,
  trackingTopology: musicKindTrackingTopology,
);
