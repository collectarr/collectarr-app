import '../anime_module_dependencies.dart';
import '../config/anime_kind_capabilities.dart';

final animeKindWorkspace = TypedLibraryKindWorkspace<AnimeWorkspaceDto>(
  catalogItemWorkspace: TypedLibraryTargetWorkspace<AnimeWorkspaceDto>(
    fields: animeCatalogItemWorkspaceSchema.toRegistry(),
    projector: const AnimeWorkspaceProjector(),
  ),
  libraryEntryWorkspace: TypedLibraryTargetWorkspace<AnimeWorkspaceDto>(
    fields: animeLibraryEntryWorkspaceSchema.toRegistry(),
    projector: const AnimeWorkspaceProjector(),
  ),
  trackingTopology: animeKindTrackingTopology,
);
