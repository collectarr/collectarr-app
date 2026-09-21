import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/anime/catalog/anime_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_media.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_release.dart';
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
    LibraryReleaseState? releaseState,
  }) {
    requireEntityBelongsToSource(source, entity);
    requireEntityScope(entity, expectedScope ?? entity.scope);
    final catalog = _catalogFor(source);
    final release = _releaseForEntity(catalog.media, entity);
    return AnimeWorkspaceDto(
      common: _animeCommonProjection(
          source, entity, catalog.video, catalog.media, release),
      personal: PersonalCopyProjection.fromShelf(
        source,
        releaseState: releaseState,
      ),
      video: catalog.video,
      media: catalog.media,
      release: release,
      metadata: catalog.metadata,
    );
  }
}

AnimeRelease? _releaseForEntity(
  AnimeMedia media,
  LibraryEntityRef entity,
) {
  final releaseId = switch (entity) {
    LibraryWorkRef() => null,
    LibraryReleaseRef(:final releaseId) => releaseId,
    LibraryCopyRef(:final releaseId) => releaseId,
  };
  if (releaseId == null) return null;
  for (final release in media.releases) {
    if (release.id.value == releaseId) return release;
  }
  throw StateError(
    'Anime release "$releaseId" is not present in the canonical work graph',
  );
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
  AnimeMedia media,
  AnimeRelease? release,
) {
  final isWork = node is LibraryWorkRef;
  final title = isWork ? video.work.title : release!.title;
  return WorkspaceCommonProjection.fromStructuralShelf(
    source,
    node,
    overrideTitle: title,
    overrideSynopsis: isWork ? video.work.synopsis : null,
    overrideReleaseDate:
        release?.releaseDate ?? (isWork ? video.work.releaseDate : null),
    overrideCoverImageUrl:
        release?.coverImageUrl ?? (isWork ? media.coverImageUrl : null),
  );
}
