import '../boardgame_module_dependencies.dart';
import '../config/boardgame_kind_capabilities.dart';

final boardGameKindWorkspace = TypedLibraryKindWorkspace<BoardGameWorkspaceDto>(
  entityWorkspaces: {
    LibraryEntityScope.catalogItem: TypedLibraryEntityWorkspace<BoardGameWorkspaceDto>(
      scope: LibraryEntityScope.catalogItem,
      fields: boardgameCatalogItemWorkspaceSchema.toRegistry(),
      projector: const BoardGameWorkspaceProjector(
        expectedScope: LibraryEntityScope.catalogItem,
      ),
    ),
    LibraryEntityScope.collectionItem: TypedLibraryEntityWorkspace<BoardGameWorkspaceDto>(
      scope: LibraryEntityScope.collectionItem,
      fields: boardgameCopyWorkspaceSchema.toRegistry(),
      projector: const BoardGameWorkspaceProjector(
        expectedScope: LibraryEntityScope.collectionItem,
      ),
    ),
  },
  hierarchy: boardGameKindHierarchy,
  trackingTopology: boardGameKindTrackingTopology,
);
