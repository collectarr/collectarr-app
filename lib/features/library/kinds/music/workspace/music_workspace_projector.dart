import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class MusicWorkspaceProjector
    implements LibraryWorkspaceProjector<MusicWorkspaceDto> {
  const MusicWorkspaceProjector();

  @override
  MusicWorkspaceDto projectTitle({
    required ShelfEntry source,
    required LibraryTitleNodeRef node,
  }) {
    final music =
        MusicCatalogMapper.mapMetadataItemToMusic(source.catalogItem!);
    return MusicWorkspaceDto(
      common: WorkspaceCommonProjection.fromShelf(source, node),
      personal: PersonalCopyProjection.fromShelf(source),
      music: music,
    );
  }

  @override
  MusicWorkspaceDto projectRelease({
    required ShelfEntry source,
    required LibraryReleaseNodeRef node,
    required LibraryReleaseState releaseState,
  }) {
    final music =
        MusicCatalogMapper.mapMetadataItemToMusic(source.catalogItem!);
    return MusicWorkspaceDto(
      common: WorkspaceCommonProjection.fromShelf(source, node),
      personal:
          PersonalCopyProjection.fromShelf(source, releaseState: releaseState),
      music: music,
    );
  }

  @override
  MusicWorkspaceDto projectCopy({
    required ShelfEntry source,
    required LibraryCopyNodeRef node,
  }) {
    return projectTitle(
      source: source,
      node: LibraryTitleNodeRef(titleItemId: node.titleItemId),
    );
  }
}
