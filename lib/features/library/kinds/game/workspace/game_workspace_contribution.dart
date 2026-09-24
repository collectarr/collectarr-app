import '../game_module_dependencies.dart';
import '../config/game_kind_capabilities.dart';

final gameKindWorkspace = TypedLibraryKindWorkspace<GameWorkspaceDto>(
  entityWorkspaces: {
    LibraryEntityScope.work: TypedLibraryEntityWorkspace<GameWorkspaceDto>(
      scope: LibraryEntityScope.work,
      fields: gameWorkWorkspaceSchema.toRegistry(),
      projector: const GameWorkspaceProjector(
        expectedScope: LibraryEntityScope.work,
      ),
    ),
    LibraryEntityScope.release: TypedLibraryEntityWorkspace<GameWorkspaceDto>(
      scope: LibraryEntityScope.release,
      fields: gameReleaseWorkspaceSchema.toRegistry(),
      projector: const GameWorkspaceProjector(
        expectedScope: LibraryEntityScope.release,
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
