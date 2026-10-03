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
    LibraryEntityScope.libraryEntry: TypedLibraryEntityWorkspace<GameWorkspaceDto>(
      scope: LibraryEntityScope.libraryEntry,
      fields: gameLibraryEntryWorkspaceSchema.toRegistry(),
      projector: const GameWorkspaceProjector(
        expectedScope: LibraryEntityScope.libraryEntry,
      ),
    ),
  },
  hierarchy: gameKindHierarchy,
  trackingTopology: gameKindTrackingTopology,
);
