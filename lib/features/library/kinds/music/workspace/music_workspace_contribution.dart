import '../music_module_dependencies.dart';
import '../config/music_kind_capabilities.dart';

final musicKindWorkspace = TypedLibraryKindWorkspace<MusicWorkspaceProjection>(
  entityWorkspaces: {
    LibraryEntityScope.work:
        TypedLibraryEntityWorkspace<MusicWorkspaceProjection>(
      scope: LibraryEntityScope.work,
      fields: musicCatalogItemWorkspaceSchema.toRegistry(),
      projector: const MusicCatalogItemWorkspaceProjector(),
    ),
    LibraryEntityScope.copy:
        TypedLibraryEntityWorkspace<MusicWorkspaceProjection>(
      scope: LibraryEntityScope.copy,
      fields: musicOwnedCopyWorkspaceSchema.toRegistry(),
      projector: const MusicOwnedCopyWorkspaceProjector(),
    ),
  },
  hierarchy: musicKindHierarchy,
  trackingTopology: musicKindTrackingTopology,
);
