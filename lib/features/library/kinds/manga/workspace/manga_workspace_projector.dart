import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class MangaWorkspaceProjector
    implements LibraryWorkspaceProjector<MangaWorkspaceDto> {
  const MangaWorkspaceProjector();

  @override
  MangaWorkspaceDto projectTitle({
    required ShelfEntry source,
    required LibraryTitleNodeRef node,
  }) {
    final manga = BookCatalogMapper.mapMetadataItemToBook(source.catalogItem!);
    return MangaWorkspaceDto(
      common: WorkspaceCommonProjection.fromShelf(source, node),
      personal: PersonalCopyProjection.fromShelf(source),
      manga: manga,
    );
  }

  @override
  MangaWorkspaceDto projectRelease({
    required ShelfEntry source,
    required LibraryReleaseNodeRef node,
    required LibraryReleaseState releaseState,
  }) {
    final manga = BookCatalogMapper.mapMetadataItemToBook(source.catalogItem!);
    return MangaWorkspaceDto(
      common: WorkspaceCommonProjection.fromShelf(source, node),
      personal:
          PersonalCopyProjection.fromShelf(source, releaseState: releaseState),
      manga: manga,
    );
  }

  @override
  MangaWorkspaceDto projectCopy({
    required ShelfEntry source,
    required LibraryCopyNodeRef node,
  }) {
    return projectTitle(
      source: source,
      node: LibraryTitleNodeRef(titleItemId: node.titleItemId),
    );
  }
}
