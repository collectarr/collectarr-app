import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/movie/catalog/movie_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_entity_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class MovieWorkspaceProjector
    implements LibraryEntityWorkspaceProjector<MovieWorkspaceDto> {
  const MovieWorkspaceProjector();

  @override
  MovieWorkspaceDto project({
    required LibraryWorkspaceSource source,
    required LibraryEntityRef entity,
    LibraryReleaseState? releaseState,
  }) {
    requireEntityBelongsToSource(source, entity);
    final catalog = _catalogFor(source);
    final release = _releaseForEntity(catalog.movie, entity);
    return MovieWorkspaceDto(
      common: _movieCommonProjection(source, entity, catalog.movie, release),
      personal: PersonalCopyProjection.fromShelf(
        source,
        releaseState: releaseState,
      ),
      movie: catalog.movie,
      media: catalog.media,
      release: release,
      metadata: catalog.metadata,
    );
  }
}

MovieCatalogRelease? _releaseForEntity(
  MovieCatalogItem movie,
  LibraryEntityRef entity,
) {
  final releaseId = switch (entity) {
    LibraryWorkRef() => null,
    LibraryReleaseRef(:final releaseId) => releaseId,
    LibraryCopyRef(:final releaseId) => releaseId,
  };
  if (releaseId == null) return null;
  for (final release in movie.releases) {
    if (release.id == releaseId) return release;
  }
  throw StateError(
    'Movie release "$releaseId" is not present in the canonical work graph',
  );
}

MovieWorkspaceCatalogData _catalogFor(LibraryWorkspaceSource source) {
  final data = source.catalogData;
  if (data case final MovieWorkspaceCatalogData catalog) return catalog;
  throw StateError('Expected MovieWorkspaceCatalogData for movie workspace');
}

WorkspaceCommonProjection _movieCommonProjection(
  LibraryWorkspaceSource source,
  LibraryEntityRef node,
  MovieCatalogItem movie,
  MovieCatalogRelease? release,
) {
  final selected = release ?? movie.primaryRelease;
  return WorkspaceCommonProjection.fromStructuralShelf(
    source,
    node,
    overrideTitle: release?.title ?? movie.work.title,
    overrideSynopsis: movie.work.synopsis,
    overrideReleaseDate: selected?.releaseDate ?? movie.work.releaseDate,
    overrideCoverImageUrl: selected?.frontCoverUrl,
  );
}
