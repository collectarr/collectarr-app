import 'boardgame_module_dependencies.dart';
import 'boardgame_kind_components_capabilities.dart';

final boardGameKindWorkspace = TypedLibraryKindWorkspace<BoardGameWorkspaceDto>(
  entityWorkspaces: {
    LibraryEntityScope.work: TypedLibraryEntityWorkspace<BoardGameWorkspaceDto>(
      scope: LibraryEntityScope.work,
      fields: boardgameLibraryEntityWorkspaceSchema
          .forScope(LibraryEntityScope.work)
          .toRegistry(),
      projector: const BoardGameWorkspaceProjector(
        expectedScope: LibraryEntityScope.work,
      ),
    ),
    LibraryEntityScope.release:
        TypedLibraryEntityWorkspace<BoardGameWorkspaceDto>(
      scope: LibraryEntityScope.release,
      fields: boardgameLibraryEntityWorkspaceSchema
          .forScope(
            LibraryEntityScope.release,
            defaultSort: BoardGameSortIds.releaseDate,
            defaultGroup: BoardGameGroupIds.publisher,
          )
          .toRegistry(),
      projector: const BoardGameWorkspaceProjector(
        expectedScope: LibraryEntityScope.release,
      ),
    ),
    LibraryEntityScope.copy: TypedLibraryEntityWorkspace<BoardGameWorkspaceDto>(
      scope: LibraryEntityScope.copy,
      fields: boardgameLibraryEntityWorkspaceSchema
          .forScope(
            LibraryEntityScope.copy,
            defaultSort: BoardGameSortIds.status,
            defaultGroup: BoardGameGroupIds.condition,
          )
          .toRegistry(),
      projector: const BoardGameWorkspaceProjector(
        expectedScope: LibraryEntityScope.copy,
      ),
    ),
  },
  hierarchy: boardGameKindHierarchy,
  trackingTopology: boardGameKindTrackingTopology,
);
