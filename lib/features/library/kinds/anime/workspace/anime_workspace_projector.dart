import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_mapper.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/catalog/video_catalog_mapper.dart';
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
    final video =
        VideoCatalogMapper.mapMetadataItemToVideo(source.catalogItem!);
    final media = AnimeWorkspaceMapper.fromCatalogItem(source.catalogItem!);
    final km = source.catalogItem?.kindMetadata;
    final AnimeMetadata? metadata = km is AnimeMetadata
        ? km
        : (km != null ? AnimeMetadata.fromJson(km.toSyncPayload()) : null);
    return AnimeWorkspaceDto(
      common: WorkspaceCommonProjection.fromShelf(source, node),
      personal: PersonalCopyProjection.fromShelf(source),
      video: video,
      media: media,
      metadata: metadata,
    );
  }

  @override
  AnimeWorkspaceDto projectRelease({
    required ShelfEntry source,
    required LibraryReleaseNodeRef node,
    required LibraryReleaseState releaseState,
  }) {
    final video =
        VideoCatalogMapper.mapMetadataItemToVideo(source.catalogItem!);
    final media = AnimeWorkspaceMapper.fromCatalogItem(source.catalogItem!);
    final km = source.catalogItem?.kindMetadata;
    final AnimeMetadata? metadata = km is AnimeMetadata
        ? km
        : (km != null ? AnimeMetadata.fromJson(km.toSyncPayload()) : null);
    return AnimeWorkspaceDto(
      common: WorkspaceCommonProjection.fromShelf(source, node),
      personal: PersonalCopyProjection.fromShelf(source),
      video: video,
      media: media,
      metadata: metadata,
    );
  }

  @override
  AnimeWorkspaceDto projectCopy({
    required ShelfEntry source,
    required LibraryCopyNodeRef node,
  }) {
    final video =
        VideoCatalogMapper.mapMetadataItemToVideo(source.catalogItem!);
    final media = AnimeWorkspaceMapper.fromCatalogItem(source.catalogItem!);
    final km = source.catalogItem?.kindMetadata;
    final AnimeMetadata? metadata = km is AnimeMetadata
        ? km
        : (km != null ? AnimeMetadata.fromJson(km.toSyncPayload()) : null);
    return AnimeWorkspaceDto(
      common: WorkspaceCommonProjection.fromShelf(source, node),
      personal: PersonalCopyProjection.fromShelf(source),
      video: video,
      media: media,
      metadata: metadata,
    );
  }
}
