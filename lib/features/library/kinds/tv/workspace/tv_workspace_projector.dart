import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_mapper.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_dto.dart';
import 'package:collectarr_app/features/library/models/catalog/video_catalog_mapper.dart';
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
    final video =
        VideoCatalogMapper.mapMetadataItemToVideo(source.catalogItem!);
    final series = TvWorkspaceMapper.fromCatalogItem(source.catalogItem!);
    TvSeriesMetadata? metadata;
    final km = source.catalogItem?.kindMetadata;
    if (km is TvSeriesMetadata) {
      metadata = km;
    }
    return TvWorkspaceDto(
      common: WorkspaceCommonProjection.fromShelf(source, node),
      personal: PersonalCopyProjection.fromShelf(source),
      video: video,
      series: series,
      metadata: metadata,
    );
  }

  @override
  TvWorkspaceDto projectRelease({
    required ShelfEntry source,
    required LibraryReleaseNodeRef node,
    required LibraryReleaseState releaseState,
  }) {
    final video =
        VideoCatalogMapper.mapMetadataItemToVideo(source.catalogItem!);
    final series = TvWorkspaceMapper.fromCatalogItem(source.catalogItem!);
    TvSeriesMetadata? metadata;
    final km = source.catalogItem?.kindMetadata;
    if (km is TvSeriesMetadata) {
      metadata = km;
    }
    return TvWorkspaceDto(
      common: WorkspaceCommonProjection.fromShelf(source, node),
      personal: PersonalCopyProjection.fromShelf(source),
      video: video,
      series: series,
      metadata: metadata,
    );
  }

  @override
  TvWorkspaceDto projectCopy({
    required ShelfEntry source,
    required LibraryCopyNodeRef node,
  }) {
    final video =
        VideoCatalogMapper.mapMetadataItemToVideo(source.catalogItem!);
    final series = TvWorkspaceMapper.fromCatalogItem(source.catalogItem!);
    TvSeriesMetadata? metadata;
    final km = source.catalogItem?.kindMetadata;
    if (km is TvSeriesMetadata) {
      metadata = km;
    }
    return TvWorkspaceDto(
      common: WorkspaceCommonProjection.fromShelf(source, node),
      personal: PersonalCopyProjection.fromShelf(source),
      video: video,
      series: series,
      metadata: metadata,
    );
  }
}
