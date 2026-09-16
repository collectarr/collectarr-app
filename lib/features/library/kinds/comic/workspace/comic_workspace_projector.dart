import 'package:collectarr_app/features/library/kinds/comic/data/comic_owned_item_projection.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_entity_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class ComicWorkspaceProjector
    implements LibraryEntityWorkspaceProjector<ComicWorkspaceDto> {
  const ComicWorkspaceProjector();

  @override
  ComicWorkspaceDto project({
    required LibraryWorkspaceSource source,
    required LibraryEntityRef entity,
    LibraryReleaseState? releaseState,
  }) {
    final catalog = _catalogFor(source);
    final ownedItem =
        ComicOwnedItemProjection.fromDispatch(source.ownedItemDispatch);
    return ComicWorkspaceDto(
      common: _comicCommonProjection(source, entity, catalog.comic),
      personal: PersonalCopyProjection.fromShelf(
        source,
        releaseState: releaseState,
      ),
      comic: catalog.comic,
      ownedItem: ownedItem,
    );
  }
}

ComicWorkspaceCatalogData _catalogFor(LibraryWorkspaceSource source) {
  final data = source.catalogData;
  if (data case final ComicWorkspaceCatalogData catalog) return catalog;
  throw StateError('Expected ComicWorkspaceCatalogData for comic workspace');
}

WorkspaceCommonProjection _comicCommonProjection(
  LibraryWorkspaceSource source,
  LibraryEntityRef node,
  ComicMedia metadata,
) {
  return WorkspaceCommonProjection.fromStructuralShelf(
    source,
    node,
    overrideTitle: metadata.title,
    overrideSynopsis: metadata.synopsis,
    overrideReleaseDate: metadata.releaseDate,
  );
}
