import '../music_module_dependencies.dart';
import '../config/music_kind_capabilities.dart';

final musicKindWorkspace = TypedLibraryKindWorkspace<MusicWorkspaceProjection>(
  catalogItemWorkspace: TypedLibraryTargetWorkspace<MusicWorkspaceProjection>(
    fields: musicCatalogItemWorkspaceSchema.toRegistry(),
    projector: const MusicCatalogItemWorkspaceProjector(),
  ),
  libraryEntryWorkspace: TypedLibraryTargetWorkspace<MusicWorkspaceProjection>(
    fields: musicLibraryEntryWorkspaceSchema.toRegistry(),
    projector: const MusicLibraryEntryWorkspaceProjector(),
  ),
  trackingTopology: musicKindTrackingTopology,
);
