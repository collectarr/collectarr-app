import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class BoardGameWorkspaceProjector
    implements LibraryWorkspaceProjector<BoardGameWorkspaceDto> {
  const BoardGameWorkspaceProjector();

  @override
  BoardGameWorkspaceDto projectTitle({
    required LibraryWorkspaceSource source,
    required LibraryTitleNodeRef node,
  }) {
    final catalog = _catalogFor(source);
    return BoardGameWorkspaceDto(
      common: _boardGameCommonProjection(source, node, catalog.boardgame),
      personal: PersonalCopyProjection.fromShelf(source),
      boardgame: catalog.boardgame,
      metadata: catalog.metadata,
    );
  }

  @override
  BoardGameWorkspaceDto projectRelease({
    required LibraryWorkspaceSource source,
    required LibraryReleaseNodeRef node,
    required LibraryReleaseState releaseState,
  }) {
    final catalog = _catalogFor(source);
    return BoardGameWorkspaceDto(
      common: _boardGameCommonProjection(source, node, catalog.boardgame),
      personal:
          PersonalCopyProjection.fromShelf(source, releaseState: releaseState),
      boardgame: catalog.boardgame,
      metadata: catalog.metadata,
    );
  }

  @override
  BoardGameWorkspaceDto projectCopy({
    required LibraryWorkspaceSource source,
    required LibraryCopyNodeRef node,
  }) {
    return projectTitle(
      source: source,
      node: LibraryTitleNodeRef(titleItemId: node.titleItemId),
    );
  }
}

BoardGameWorkspaceCatalogData _catalogFor(LibraryWorkspaceSource source) {
  final data = source.catalogData;
  if (data case final BoardGameWorkspaceCatalogData catalog) return catalog;
  final snapshot = source.catalogSnapshot;
  if (snapshot != null) {
    return snapshot.mapTransport(
      BoardGameWorkspaceCatalogData.fromTransport,
    );
  }
  throw StateError(
    'Expected BoardGameWorkspaceCatalogData for board game workspace',
  );
}

WorkspaceCommonProjection _boardGameCommonProjection(
  LibraryWorkspaceSource source,
  LibraryNodeRef node,
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
