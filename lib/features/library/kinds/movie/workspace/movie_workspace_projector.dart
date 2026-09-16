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
    final catalog = _catalogFor(source);
    return MovieWorkspaceDto(
      common: _movieCommonProjection(source, entity, catalog.movie),
      personal: PersonalCopyProjection.fromShelf(
        source,
        releaseState: releaseState,
      ),
      movie: catalog.movie,
      media: catalog.media,
      metadata: catalog.metadata,
    );
  }
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
) {
  return WorkspaceCommonProjection.fromStructuralShelf(
    source,
    node,
    overrideTitle: movie.work.title,
    overrideSynopsis: movie.work.synopsis,
    overrideReleaseDate: movie.work.releaseDate,
    overrideCoverImageUrl: movie.primaryRelease?.frontCoverUrl,
  );
}
