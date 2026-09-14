import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/anime/catalog/anime_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class AnimeWorkspaceProjector
    implements LibraryWorkspaceProjector<AnimeWorkspaceDto> {
  const AnimeWorkspaceProjector();

  @override
  AnimeWorkspaceDto projectTitle({
    required LibraryWorkspaceSource source,
    required LibraryTitleNodeRef node,
  }) {
    final catalog = _catalogFor(source);
    return AnimeWorkspaceDto(
      common: _animeCommonProjection(source, node, catalog.video),
      personal: PersonalCopyProjection.fromShelf(source),
      video: catalog.video,
      media: catalog.media,
      metadata: catalog.metadata,
    );
  }

  @override
  AnimeWorkspaceDto projectRelease({
    required LibraryWorkspaceSource source,
    required LibraryReleaseNodeRef node,
    required LibraryReleaseState releaseState,
  }) {
    final catalog = _catalogFor(source);
    return AnimeWorkspaceDto(
      common: _animeCommonProjection(source, node, catalog.video),
      personal: PersonalCopyProjection.fromShelf(source),
      video: catalog.video,
      media: catalog.media,
      metadata: catalog.metadata,
    );
  }

  @override
  AnimeWorkspaceDto projectCopy({
    required LibraryWorkspaceSource source,
    required LibraryCopyNodeRef node,
  }) {
    final catalog = _catalogFor(source);
    return AnimeWorkspaceDto(
      common: _animeCommonProjection(source, node, catalog.video),
      personal: PersonalCopyProjection.fromShelf(source),
      video: catalog.video,
      media: catalog.media,
      metadata: catalog.metadata,
    );
  }
}

AnimeWorkspaceCatalogData _catalogFor(LibraryWorkspaceSource source) {
  final data = source.catalogData;
  if (data case final AnimeWorkspaceCatalogData catalog) return catalog;
  final transport = source.catalogTransport;
  if (transport != null) {
    return AnimeWorkspaceCatalogData.fromTransport(
      transport.mapTransport((item) => item),
    );
  }
  throw StateError('Expected AnimeWorkspaceCatalogData for anime workspace');
}

WorkspaceCommonProjection _animeCommonProjection(
  LibraryWorkspaceSource source,
  LibraryNodeRef node,
  AnimeCatalogItem video,
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
