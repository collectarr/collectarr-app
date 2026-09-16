import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_entity_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class BoardGameWorkspaceProjector
    implements LibraryEntityWorkspaceProjector<BoardGameWorkspaceDto> {
  const BoardGameWorkspaceProjector();

  @override
  BoardGameWorkspaceDto project({
    required LibraryWorkspaceSource source,
    required LibraryEntityRef entity,
    LibraryReleaseState? releaseState,
  }) {
    final catalog = _catalogFor(source);
    return BoardGameWorkspaceDto(
      common: _boardGameCommonProjection(source, entity, catalog.boardgame),
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

WorkspaceCommonProjection _boardGameCommonProjection(
  LibraryWorkspaceSource source,
  LibraryEntityRef node,
  BoardGameCatalogItem boardgame,
) {
  return WorkspaceCommonProjection.fromStructuralShelf(
    source,
    node,
    overrideTitle: boardgame.title,
    overrideSynopsis: boardgame.synopsis,
    overrideReleaseDate: boardgame.releaseDate,
    overrideCoverImageUrl: boardgame.coverImageUrl,
  );
}
