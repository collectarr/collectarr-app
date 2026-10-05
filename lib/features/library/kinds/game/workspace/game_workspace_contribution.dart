import '../game_module_dependencies.dart';
import '../config/game_kind_capabilities.dart';

final gameKindWorkspace = TypedLibraryKindWorkspace<GameWorkspaceDto>(
  catalogItemWorkspace: TypedLibraryTargetWorkspace<GameWorkspaceDto>(
    fields: gameCatalogItemWorkspaceSchema.toRegistry(),
    projector: const GameWorkspaceProjector(),
  ),
  libraryEntryWorkspace: TypedLibraryTargetWorkspace<GameWorkspaceDto>(
    fields: gameLibraryEntryWorkspaceSchema.toRegistry(),
    projector: const GameWorkspaceProjector(),
  ),
  trackingTopology: gameKindTrackingTopology,
);
