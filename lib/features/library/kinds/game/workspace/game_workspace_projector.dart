import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/game/catalog/game_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_entity_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class GameWorkspaceProjector
    implements LibraryEntityWorkspaceProjector<GameWorkspaceDto> {
  const GameWorkspaceProjector();

  @override
  GameWorkspaceDto project({
    required LibraryWorkspaceSource source,
    required LibraryEntityRef entity,
    LibraryReleaseState? releaseState,
  }) {
    final catalog = _catalogFor(source);
    return GameWorkspaceDto(
      common: _gameCommonProjection(source, entity, catalog.game),
      personal: PersonalCopyProjection.fromShelf(
        source,
        releaseState: releaseState,
      ),
      game: catalog.game,
      metadata: catalog.metadata,
    );
  }
}

GameWorkspaceCatalogData _catalogFor(LibraryWorkspaceSource source) {
  final data = source.catalogData;
  if (data case final GameWorkspaceCatalogData catalog) return catalog;
  throw StateError('Expected GameWorkspaceCatalogData for game workspace');
}

WorkspaceCommonProjection _gameCommonProjection(
  LibraryWorkspaceSource source,
  LibraryEntityRef node,
  GameCatalogItem game,
) {
  return WorkspaceCommonProjection.fromStructuralShelf(
    source,
    node,
    overrideTitle: game.title,
    overrideSynopsis: game.synopsis,
    overrideReleaseDate: game.releaseDate,
    overrideCoverImageUrl: game.coverImageUrl,
  );
}
