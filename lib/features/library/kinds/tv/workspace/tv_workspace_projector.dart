import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/tv/catalog/tv_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class TvWorkspaceProjector
    implements LibraryWorkspaceProjector<TvWorkspaceDto> {
  const TvWorkspaceProjector();

  @override
  TvWorkspaceDto projectTitle({
    required LibraryWorkspaceSource source,
    required LibraryTitleNodeRef node,
  }) {
    final catalog = _catalogFor(source);
    return TvWorkspaceDto(
      common: _tvCommonProjection(source, node, catalog.video),
      personal: PersonalCopyProjection.fromShelf(source),
      video: catalog.video,
      series: catalog.series,
      metadata: catalog.metadata,
    );
  }

  @override
  TvWorkspaceDto projectRelease({
    required LibraryWorkspaceSource source,
    required LibraryReleaseNodeRef node,
    required LibraryReleaseState releaseState,
  }) {
    final catalog = _catalogFor(source);
    return TvWorkspaceDto(
      common: _tvCommonProjection(source, node, catalog.video),
      personal: PersonalCopyProjection.fromShelf(source),
      video: catalog.video,
      series: catalog.series,
      metadata: catalog.metadata,
    );
  }

  @override
  TvWorkspaceDto projectCopy({
    required LibraryWorkspaceSource source,
    required LibraryCopyNodeRef node,
  }) {
    final catalog = _catalogFor(source);
    return TvWorkspaceDto(
      common: _tvCommonProjection(source, node, catalog.video),
      personal: PersonalCopyProjection.fromShelf(source),
      video: catalog.video,
      series: catalog.series,
      metadata: catalog.metadata,
    );
  }
}

TvWorkspaceCatalogData _catalogFor(LibraryWorkspaceSource source) {
  final data = source.catalogData;
  if (data case final TvWorkspaceCatalogData catalog) return catalog;
  throw StateError('Expected TvWorkspaceCatalogData for TV workspace');
}

WorkspaceCommonProjection _tvCommonProjection(
  LibraryWorkspaceSource source,
  LibraryNodeRef node,
  TvCatalogItem video,
) {
  return WorkspaceCommonProjection.fromStructuralShelf(
    source,
    node,
    overrideTitle: video.work.title,
    overrideSynopsis: video.work.synopsis,
    overrideReleaseDate: video.work.releaseDate,
    overrideCoverImageUrl: video.primaryRelease?.frontCoverUrl,
  );
}
