import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_entity_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

/// Projects a concrete Game Catalog Item and its App-collection item state.
final class GameWorkspaceProjector
    implements LibraryEntityWorkspaceProjector<GameWorkspaceDto> {
  const GameWorkspaceProjector({this.expectedScope});

  final LibraryEntityScope? expectedScope;

  @override
  GameWorkspaceDto project({
    required LibraryWorkspaceSource source,
    required LibraryEntityRef entity,
  }) {
    requireEntityBelongsToSource(source, entity);
    requireEntityScope(entity, expectedScope ?? entity.scope);
    final catalog = _catalogFor(source);
    return GameWorkspaceDto(
      common: WorkspaceCommonProjection.fromStructuralShelf(
        source,
        entity,
        overrideTitle: catalog.metadata.title,
        overrideSynopsis: catalog.metadata.synopsis,
        overrideReleaseDate: catalog.metadata.releaseDate,
        overrideCoverImageUrl: catalog.metadata.coverImageUrl,
      ),
      personal: PersonalCopyProjection.fromShelf(
        source,
      ),
      metadata: catalog.metadata,
    );
  }
}

GameWorkspaceCatalogData _catalogFor(LibraryWorkspaceSource source) {
  final data = source.catalogData;
  if (data case final GameWorkspaceCatalogData catalog) return catalog;
  throw StateError('Expected GameWorkspaceCatalogData for game workspace');
}
