import '../comic_module_dependencies.dart';
import '../config/comic_kind_capabilities.dart';

final comicKindWorkspace = TypedLibraryKindWorkspace<ComicWorkspaceDto>(
  catalogItemWorkspace: TypedLibraryTargetWorkspace<ComicWorkspaceDto>(
    fields: comicCatalogItemWorkspaceSchema.toRegistry(),
    projector: const ComicWorkspaceProjector(),
  ),
  libraryEntryWorkspace: TypedLibraryTargetWorkspace<ComicWorkspaceDto>(
    fields: comicLibraryEntryWorkspaceSchema.toRegistry(),
    projector: const ComicWorkspaceProjector(),
  ),
  trackingTopology: comicKindTrackingTopology,
);
