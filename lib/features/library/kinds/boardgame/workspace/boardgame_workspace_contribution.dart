import '../boardgame_module_dependencies.dart';
import '../config/boardgame_kind_capabilities.dart';

final boardGameKindWorkspace = TypedLibraryKindWorkspace<BoardGameWorkspaceDto>(
  entityWorkspaces: {
    LibraryEntityScope.work: TypedLibraryEntityWorkspace<BoardGameWorkspaceDto>(
      scope: LibraryEntityScope.work,
      fields: boardgameCatalogItemWorkspaceSchema.toRegistry(),
      projector: const BoardGameWorkspaceProjector(
        expectedScope: LibraryEntityScope.work,
      ),
    ),
    LibraryEntityScope.copy: TypedLibraryEntityWorkspace<BoardGameWorkspaceDto>(
      scope: LibraryEntityScope.copy,
      fields: boardgameCopyWorkspaceSchema.toRegistry(),
      projector: const BoardGameWorkspaceProjector(
        expectedScope: LibraryEntityScope.copy,
      ),
    ),
  },
  hierarchy: boardGameKindHierarchy,
  trackingTopology: boardGameKindTrackingTopology,
);
