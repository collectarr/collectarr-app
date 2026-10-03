import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_media.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_entity_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class AnimeWorkspaceProjector
    implements LibraryEntityWorkspaceProjector<AnimeWorkspaceDto> {
  const AnimeWorkspaceProjector({this.expectedScope});

  final LibraryEntityScope? expectedScope;

  @override
  AnimeWorkspaceDto project({
    required LibraryWorkspaceSource source,
    required LibraryEntityRef entity,
  }) {
    requireEntityBelongsToSource(source, entity);
    requireEntityScope(entity, expectedScope ?? entity.scope);
    final catalog = _catalogFor(source);
    return AnimeWorkspaceDto(
      common: _animeCommonProjection(
        source,
        entity,
        catalog.media,
        catalog.metadata,
      ),
      personal: PersonalCopyProjection.fromShelf(
        source,
      ),
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
  AnimeMedia media,
  AnimeMetadata? metadata,
) {
  return WorkspaceCommonProjection.fromStructuralShelf(
    source,
    node,
    overrideTitle: metadata?.title,
    overrideSynopsis: metadata?.synopsis,
    overrideReleaseDate:
        metadata?.releaseDate ?? metadata?.startDate ?? media.originalAirDate,
    overrideCoverImageUrl: media.coverImageUrl,
  );
}
