import '../game_module_dependencies.dart';
import '../config/game_kind_capabilities.dart';

final gameKindWorkspace = TypedLibraryKindWorkspace<GameWorkspaceDto>(
  entityWorkspaces: {
    LibraryEntityScope.work: TypedLibraryEntityWorkspace<GameWorkspaceDto>(
      scope: LibraryEntityScope.work,
      fields: gameCatalogItemWorkspaceSchema.toRegistry(),
      projector: const GameWorkspaceProjector(
        expectedScope: LibraryEntityScope.work,
      ),
    ),
    LibraryEntityScope.copy: TypedLibraryEntityWorkspace<GameWorkspaceDto>(
      scope: LibraryEntityScope.copy,
      fields: gameCopyWorkspaceSchema.toRegistry(),
      projector: const GameWorkspaceProjector(
        expectedScope: LibraryEntityScope.copy,
      ),
    ),
  },
  hierarchy: gameKindHierarchy,
  trackingTopology: gameKindTrackingTopology,
);
