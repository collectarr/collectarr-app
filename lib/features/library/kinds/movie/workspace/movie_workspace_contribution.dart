import '../movie_module_dependencies.dart';
import '../config/movie_kind_capabilities.dart';
import 'movie_catalog_item_workspace_schema.dart';

final movieKindWorkspace = TypedLibraryKindWorkspace<MovieWorkspaceDto>(
  catalogItemWorkspace: TypedLibraryTargetWorkspace<MovieWorkspaceDto>(
    fields: movieCatalogItemWorkspaceSchema.toRegistry(),
    projector: const MovieWorkspaceProjector(),
  ),
  libraryEntryWorkspace: TypedLibraryTargetWorkspace<MovieWorkspaceDto>(
    fields: movieLibraryEntryWorkspaceSchema.toRegistry(),
    projector: const MovieWorkspaceProjector(),
  ),
  trackingTopology: movieKindTrackingTopology,
);
