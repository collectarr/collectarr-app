import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/anime/catalog/anime_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_entity_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class AnimeWorkspaceProjector
    implements LibraryEntityWorkspaceProjector<AnimeWorkspaceDto> {
  const AnimeWorkspaceProjector();

  @override
  AnimeWorkspaceDto project({
    required LibraryWorkspaceSource source,
    required LibraryEntityRef entity,
    LibraryReleaseState? releaseState,
  }) {
    final catalog = _catalogFor(source);
    return AnimeWorkspaceDto(
      common: _animeCommonProjection(source, entity, catalog.video),
      personal: PersonalCopyProjection.fromShelf(
        source,
        releaseState: releaseState,
      ),
      video: catalog.video,
      media: catalog.media,
      metadata: catalog.metadata,
    );
  }
}

AnimeWorkspaceCatalogData _catalogFor(LibraryWorkspaceSource source) {
  final data = source.catalogData;
  if (data case final AnimeWorkspaceCatalogData catalog) return catalog;
  throw StateError('Expected AnimeWorkspaceCatalogData for anime workspace');
}

WorkspaceCommonProjection _animeCommonProjection(
  LibraryWorkspaceSource source,
  LibraryEntityRef node,
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
