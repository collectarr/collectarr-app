import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/movie/catalog/movie_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class MovieWorkspaceProjector
    implements LibraryWorkspaceProjector<MovieWorkspaceDto> {
  const MovieWorkspaceProjector();

  @override
  MovieWorkspaceDto projectTitle({
    required LibraryWorkspaceSource source,
    required LibraryTitleNodeRef node,
  }) {
    final catalog = _catalogFor(source);
    return MovieWorkspaceDto(
      common: _movieCommonProjection(source, node, catalog.movie),
      personal: PersonalCopyProjection.fromShelf(source),
      movie: catalog.movie,
      media: catalog.media,
      metadata: catalog.metadata,
    );
  }

  @override
  MovieWorkspaceDto projectRelease({
    required LibraryWorkspaceSource source,
    required LibraryReleaseNodeRef node,
    required LibraryReleaseState releaseState,
  }) {
    final catalog = _catalogFor(source);
    return MovieWorkspaceDto(
      common: _movieCommonProjection(source, node, catalog.movie),
      personal: PersonalCopyProjection.fromShelf(source),
      movie: catalog.movie,
      media: catalog.media,
      metadata: catalog.metadata,
    );
  }

  @override
  MovieWorkspaceDto projectCopy({
    required LibraryWorkspaceSource source,
    required LibraryCopyNodeRef node,
  }) {
    final catalog = _catalogFor(source);
    return MovieWorkspaceDto(
      common: _movieCommonProjection(source, node, catalog.movie),
      personal: PersonalCopyProjection.fromShelf(source),
      movie: catalog.movie,
      media: catalog.media,
      metadata: catalog.metadata,
    );
  }
}

MovieWorkspaceCatalogData _catalogFor(LibraryWorkspaceSource source) {
  final data = source.catalogData;
  if (data case final MovieWorkspaceCatalogData catalog) return catalog;
  final snapshot = source.catalogSnapshot;
  if (snapshot != null) {
    return snapshot.mapTransport(MovieWorkspaceCatalogData.fromTransport);
  }
  throw StateError('Expected MovieWorkspaceCatalogData for movie workspace');
}

WorkspaceCommonProjection _movieCommonProjection(
  LibraryWorkspaceSource source,
  LibraryNodeRef node,
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
