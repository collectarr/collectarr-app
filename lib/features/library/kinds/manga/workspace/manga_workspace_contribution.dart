import '../manga_module_dependencies.dart';
import '../config/manga_kind_capabilities.dart';

final mangaKindWorkspace = TypedLibraryKindWorkspace<MangaWorkspaceDto>(
  catalogItemWorkspace: TypedLibraryTargetWorkspace<MangaWorkspaceDto>(
    fields: mangaCatalogItemWorkspaceSchema.toRegistry(),
    projector: const MangaWorkspaceProjector(),
  ),
  libraryEntryWorkspace: TypedLibraryTargetWorkspace<MangaWorkspaceDto>(
    fields: mangaLibraryEntryWorkspaceSchema.toRegistry(),
    projector: const MangaWorkspaceProjector(),
  ),
  trackingTopology: mangaKindTrackingTopology,
);
