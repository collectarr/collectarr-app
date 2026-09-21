import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/game/catalog/game_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_release.dart';
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
    requireEntityBelongsToSource(source, entity);
    final catalog = _catalogFor(source);
    final release = _releaseForEntity(catalog.game, entity);
    return GameWorkspaceDto(
      common: _gameCommonProjection(source, entity, catalog.game, release),
      personal: PersonalCopyProjection.fromShelf(
        source,
        releaseState: releaseState,
      ),
      game: catalog.game,
      release: release,
      metadata: catalog.metadata,
    );
  }
}

GameRelease? _releaseForEntity(
  GameCatalogItem game,
  LibraryEntityRef entity,
) {
  final releaseId = switch (entity) {
    LibraryWorkRef() => null,
    LibraryReleaseRef(:final releaseId) => releaseId,
    LibraryCopyRef(:final releaseId) => releaseId,
  };
  if (releaseId == null) return null;
  for (final release in game.releases) {
    if (release.id == releaseId) return release;
  }
  throw StateError(
    'Game release "$releaseId" is not present in the canonical work graph',
  );
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
  GameRelease? release,
) {
  final isWork = node is LibraryWorkRef;
  final title = isWork ? game.title : release!.title;
  return WorkspaceCommonProjection.fromStructuralShelf(
    source,
    node,
    overrideTitle: title,
    overrideSynopsis: isWork ? game.synopsis : null,
    overrideReleaseDate:
        release?.releaseDate ?? (isWork ? game.work.releaseDate : null),
    overrideCoverImageUrl:
        release?.coverImageUrl ?? (isWork ? game.coverImageUrl : null),
  );
}
