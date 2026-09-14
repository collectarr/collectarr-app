import 'package:collectarr_app/features/library/kinds/comic/data/comic_owned_item_projection.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class ComicWorkspaceProjector
    implements LibraryWorkspaceProjector<ComicWorkspaceDto> {
  const ComicWorkspaceProjector();

  @override
  ComicWorkspaceDto projectTitle({
    required LibraryWorkspaceSource source,
    required LibraryTitleNodeRef node,
  }) {
    final catalog = _catalogFor(source);
    final ownedItem =
        ComicOwnedItemProjection.fromDispatch(source.ownedItemDispatch);
    return ComicWorkspaceDto(
      common: _comicCommonProjection(source, node, catalog.comic),
      personal: PersonalCopyProjection.fromShelf(source),
      comic: catalog.comic,
      ownedItem: ownedItem,
    );
  }

  @override
  ComicWorkspaceDto projectRelease({
    required LibraryWorkspaceSource source,
    required LibraryReleaseNodeRef node,
    required LibraryReleaseState releaseState,
  }) {
    throw UnsupportedError(
        'Release projection is not supported for ComicWorkspaceProjector');
  }

  @override
  ComicWorkspaceDto projectCopy({
    required LibraryWorkspaceSource source,
    required LibraryCopyNodeRef node,
  }) {
    throw UnsupportedError(
        'Copy projection is not supported for ComicWorkspaceProjector');
  }
}

ComicWorkspaceCatalogData _catalogFor(LibraryWorkspaceSource source) {
  final data = source.catalogData;
  if (data case final ComicWorkspaceCatalogData catalog) return catalog;
  throw StateError('Expected ComicWorkspaceCatalogData for comic workspace');
}

WorkspaceCommonProjection _comicCommonProjection(
  LibraryWorkspaceSource source,
  LibraryNodeRef node,
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
