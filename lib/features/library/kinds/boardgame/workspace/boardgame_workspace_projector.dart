import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_edition.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_entity_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

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
    final release = _releaseForEntity(catalog.boardgame, entity);
    return BoardGameWorkspaceDto(
      common: _boardGameCommonProjection(
        source,
        entity,
        catalog.boardgame,
        release,
      ),
      personal: PersonalCopyProjection.fromShelf(
        source,
        releaseState: releaseState,
      ),
      boardgame: catalog.boardgame,
      release: release,
      metadata: catalog.metadata,
    );
  }
}

BoardGameEdition? _releaseForEntity(
  BoardGameCatalogItem boardgame,
  LibraryEntityRef entity,
) {
  final releaseId = switch (entity) {
    LibraryWorkRef() => null,
    LibraryReleaseRef(:final releaseId) => releaseId,
    LibraryCopyRef(:final releaseId) => releaseId,
  };
  if (releaseId == null) return null;
  for (final release in boardgame.releases) {
    if (release.id == releaseId) return release;
  }
  throw StateError(
    'Board game release "$releaseId" is not present in the canonical work graph',
  );
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
  BoardGameEdition? release,
) {
  final isWork = node is LibraryWorkRef;
  final title = isWork ? boardgame.title : release!.title;
  return WorkspaceCommonProjection.fromStructuralShelf(
    source,
    node,
    overrideTitle: title,
    overrideSynopsis: isWork ? boardgame.synopsis : release?.description,
    overrideReleaseDate:
        release?.releaseDate ?? (isWork ? boardgame.work.releaseDate : null),
    overrideCoverImageUrl:
        release?.coverImageUrl ?? (isWork ? boardgame.coverImageUrl : null),
  );
}
