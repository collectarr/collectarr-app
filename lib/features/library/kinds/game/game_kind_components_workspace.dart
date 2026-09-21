part of 'game_kind_components.dart';

final gameKindWorkspace = TypedLibraryKindWorkspace<GameWorkspaceDto>(
  entityWorkspaces: {
    LibraryEntityScope.work: TypedLibraryEntityWorkspace<GameWorkspaceDto>(
      scope: LibraryEntityScope.work,
      fields: gameLibraryEntityWorkspaceSchema
          .forScope(LibraryEntityScope.work)
          .toRegistry(),
      projector: const GameWorkspaceProjector(
        expectedScope: LibraryEntityScope.work,
      ),
    ),
    LibraryEntityScope.release: TypedLibraryEntityWorkspace<GameWorkspaceDto>(
      scope: LibraryEntityScope.release,
      fields: gameLibraryEntityWorkspaceSchema
          .forScope(
            LibraryEntityScope.release,
            defaultSort: GameSortIds.releaseDate,
            defaultGroup: GameGroupIds.publisher,
          )
          .toRegistry(),
      projector: const GameWorkspaceProjector(
        expectedScope: LibraryEntityScope.release,
      ),
    ),
    LibraryEntityScope.copy: TypedLibraryEntityWorkspace<GameWorkspaceDto>(
      scope: LibraryEntityScope.copy,
      fields: gameLibraryEntityWorkspaceSchema
          .forScope(
            LibraryEntityScope.copy,
            defaultSort: GameSortIds.status,
            defaultGroup: GameGroupIds.condition,
          )
          .toRegistry(),
      projector: const GameWorkspaceProjector(
        expectedScope: LibraryEntityScope.copy,
      ),
    ),
  },
  hierarchy: gameKindHierarchy,
  trackingTopology: gameKindTrackingTopology,
);
