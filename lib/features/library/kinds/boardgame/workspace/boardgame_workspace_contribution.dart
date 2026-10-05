import '../boardgame_module_dependencies.dart';
import '../config/boardgame_kind_capabilities.dart';

final boardGameKindWorkspace = TypedLibraryKindWorkspace<BoardGameWorkspaceDto>(
  catalogItemWorkspace: TypedLibraryTargetWorkspace<BoardGameWorkspaceDto>(
    fields: boardgameCatalogItemWorkspaceSchema.toRegistry(),
    projector: const BoardGameWorkspaceProjector(),
  ),
  libraryEntryWorkspace: TypedLibraryTargetWorkspace<BoardGameWorkspaceDto>(
    fields: boardgameLibraryEntryWorkspaceSchema.toRegistry(),
    projector: const BoardGameWorkspaceProjector(),
  ),
  trackingTopology: boardGameKindTrackingTopology,
);
