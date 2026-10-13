import '../tv_module_dependencies.dart';
import '../config/tv_kind_capabilities.dart';

final tvKindWorkspace = TypedLibraryKindWorkspace<TvWorkspaceDto>(
  catalogItemWorkspace: TypedLibraryTargetWorkspace<TvWorkspaceDto>(
    fields: tvCatalogItemWorkspaceSchema.toRegistry(),
    projector: const TvWorkspaceProjector(),
  ),
  libraryEntryWorkspace: TypedLibraryTargetWorkspace<TvWorkspaceDto>(
    fields: tvLibraryEntryWorkspaceSchema.toRegistry(),
    projector: const TvWorkspaceProjector(),
  ),
  trackingTopology: tvKindTrackingTopology,
);
