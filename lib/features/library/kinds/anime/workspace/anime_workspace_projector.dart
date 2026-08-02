import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/video/catalog/video_catalog_mapper.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class AnimeWorkspaceProjector
    implements LibraryWorkspaceProjector<AnimeWorkspaceDto> {
  const AnimeWorkspaceProjector();

  @override
  AnimeWorkspaceDto projectTitle({
    required ShelfEntry source,
    required LibraryTitleNodeRef node,
  }) {
    final anime =
        VideoCatalogMapper.mapMetadataItemToVideo(source.catalogItem!);
    return AnimeWorkspaceDto(
      common: WorkspaceCommonProjection.fromShelf(source, node),
      personal: PersonalCopyProjection.fromShelf(source),
      anime: anime,
    );
  }

  @override
  AnimeWorkspaceDto projectRelease({
    required ShelfEntry source,
    required LibraryReleaseNodeRef node,
    required LibraryReleaseState releaseState,
  }) {
    final anime =
        VideoCatalogMapper.mapMetadataItemToVideo(source.catalogItem!);
    return AnimeWorkspaceDto(
      common: WorkspaceCommonProjection.fromShelf(source, node),
      personal:
          PersonalCopyProjection.fromShelf(source, releaseState: releaseState),
      anime: anime,
    );
  }

  @override
  AnimeWorkspaceDto projectCopy({
    required ShelfEntry source,
    required LibraryCopyNodeRef node,
  }) {
    return projectTitle(
      source: source,
      node: LibraryTitleNodeRef(titleItemId: node.titleItemId),
    );
  }
}
