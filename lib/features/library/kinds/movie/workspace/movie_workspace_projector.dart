import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/kinds/movie/catalog/movie_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_mapper.dart';
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
    final movie = MovieCatalogMapper.mapMetadataItemToMovie(
      source.catalogTransport!.toTransportItem(),
    );
    final media = MovieWorkspaceMapper.fromCatalogItem(
      source.catalogTransport!.toTransportItem(),
    );
    MovieCatalogMetadata? metadata;
    final km = source.catalogTransport?.kindMetadata;
    if (km is MovieCatalogMetadata) {
      metadata = km;
    }
    return MovieWorkspaceDto(
      common: WorkspaceCommonProjection.fromShelf(source, node),
      personal: PersonalCopyProjection.fromShelf(source),
      movie: movie,
      media: media,
      metadata: metadata,
    );
  }

  @override
  MovieWorkspaceDto projectRelease({
    required LibraryWorkspaceSource source,
    required LibraryReleaseNodeRef node,
    required LibraryReleaseState releaseState,
  }) {
    final movie = MovieCatalogMapper.mapMetadataItemToMovie(
      source.catalogTransport!.toTransportItem(),
    );
    final media = MovieWorkspaceMapper.fromCatalogItem(
      source.catalogTransport!.toTransportItem(),
    );
    MovieCatalogMetadata? metadata;
    final km = source.catalogTransport?.kindMetadata;
    if (km is MovieCatalogMetadata) {
      metadata = km;
    }
    return MovieWorkspaceDto(
      common: WorkspaceCommonProjection.fromShelf(source, node),
      personal: PersonalCopyProjection.fromShelf(source),
      movie: movie,
      media: media,
      metadata: metadata,
    );
  }

  @override
  MovieWorkspaceDto projectCopy({
    required LibraryWorkspaceSource source,
    required LibraryCopyNodeRef node,
  }) {
    final movie = MovieCatalogMapper.mapMetadataItemToMovie(
      source.catalogTransport!.toTransportItem(),
    );
    final media = MovieWorkspaceMapper.fromCatalogItem(
      source.catalogTransport!.toTransportItem(),
    );
    MovieCatalogMetadata? metadata;
    final km = source.catalogTransport?.kindMetadata;
    if (km is MovieCatalogMetadata) {
      metadata = km;
    }
    return MovieWorkspaceDto(
      common: WorkspaceCommonProjection.fromShelf(source, node),
      personal: PersonalCopyProjection.fromShelf(source),
      movie: movie,
      media: media,
      metadata: metadata,
    );
  }
}
