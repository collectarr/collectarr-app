import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_entity_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

/// Projects a concrete Board Game Catalog Item and its App-owned copy state.
final class BoardGameWorkspaceProjector
    implements LibraryEntityWorkspaceProjector<BoardGameWorkspaceDto> {
  const BoardGameWorkspaceProjector({this.expectedScope});

  final LibraryEntityScope? expectedScope;

  @override
  BoardGameWorkspaceDto project({
    required LibraryWorkspaceSource source,
    required LibraryEntityRef entity,
    LibraryReleaseState? releaseState,
  }) {
    requireEntityBelongsToSource(source, entity);
    requireEntityScope(entity, expectedScope ?? entity.scope);
    final catalog = _catalogFor(source);
    return BoardGameWorkspaceDto(
      common: WorkspaceCommonProjection.fromStructuralShelf(
        source,
        entity,
        overrideTitle: catalog.boardgame.title,
        overrideSynopsis: catalog.boardgame.synopsis,
        overrideReleaseDate: catalog.boardgame.releaseDate,
        overrideCoverImageUrl: catalog.boardgame.coverImageUrl,
      ),
      personal: PersonalCopyProjection.fromShelf(
        source,
        releaseState: releaseState,
      ),
      boardgame: catalog.boardgame,
      metadata: catalog.metadata,
    );
  }
}

BoardGameWorkspaceCatalogData _catalogFor(LibraryWorkspaceSource source) {
  final data = source.catalogData;
  if (data case final BoardGameWorkspaceCatalogData catalog) return catalog;
  throw StateError(
    'Expected BoardGameWorkspaceCatalogData for board game workspace',
  );
}
