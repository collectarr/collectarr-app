import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/video/catalog/video_catalog_mapper.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class TvWorkspaceProjector
    implements LibraryWorkspaceProjector<TvWorkspaceDto> {
  const TvWorkspaceProjector();

  @override
  TvWorkspaceDto projectTitle({
    required ShelfEntry source,
    required LibraryTitleNodeRef node,
  }) {
    final tv = VideoCatalogMapper.mapMetadataItemToVideo(source.catalogItem!);
    return TvWorkspaceDto(
      common: WorkspaceCommonProjection.fromShelf(source, node),
      personal: PersonalCopyProjection.fromShelf(source),
      tv: tv,
    );
  }

  @override
  TvWorkspaceDto projectRelease({
    required ShelfEntry source,
    required LibraryReleaseNodeRef node,
    required LibraryReleaseState releaseState,
  }) {
    final tv = VideoCatalogMapper.mapMetadataItemToVideo(source.catalogItem!);
    return TvWorkspaceDto(
      common: WorkspaceCommonProjection.fromShelf(source, node),
      personal:
          PersonalCopyProjection.fromShelf(source, releaseState: releaseState),
      tv: tv,
    );
  }

  @override
  TvWorkspaceDto projectCopy({
    required ShelfEntry source,
    required LibraryCopyNodeRef node,
  }) {
    return projectTitle(
      source: source,
      node: LibraryTitleNodeRef(titleItemId: node.titleItemId),
    );
  }
}
