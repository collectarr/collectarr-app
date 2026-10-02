import '../game_module_dependencies.dart';
import '../config/game_kind_capabilities.dart';

final gameKindWorkspace = TypedLibraryKindWorkspace<GameWorkspaceDto>(
  entityWorkspaces: {
    LibraryEntityScope.catalogItem: TypedLibraryEntityWorkspace<GameWorkspaceDto>(
      scope: LibraryEntityScope.catalogItem,
      fields: gameCatalogItemWorkspaceSchema.toRegistry(),
      projector: const GameWorkspaceProjector(
        expectedScope: LibraryEntityScope.catalogItem,
      ),
    ),
    LibraryEntityScope.collectionItem: TypedLibraryEntityWorkspace<GameWorkspaceDto>(
      scope: LibraryEntityScope.collectionItem,
      fields: gameCopyWorkspaceSchema.toRegistry(),
      projector: const GameWorkspaceProjector(
        expectedScope: LibraryEntityScope.collectionItem,
      ),
    ),
  },
  hierarchy: gameKindHierarchy,
  trackingTopology: gameKindTrackingTopology,
);
