import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/movie/catalog/movie_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_media.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_mapper.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';

final class MovieWorkspaceCatalogData implements LibraryWorkspaceCatalogData {
  MovieWorkspaceCatalogData({
    required this.ref,
    required this.movie,
    required this.media,
    required this.metadata,
  });

  factory MovieWorkspaceCatalogData.fromTransport(CatalogItemDto item) {
    final rawMetadata = item.kindMetadata;
    return MovieWorkspaceCatalogData(
      ref: item.catalogRef,
      movie: MovieCatalogMapper.mapMetadataItemToMovie(item),
      media: rawMetadata is MovieMedia
          ? rawMetadata
          : MovieWorkspaceMapper.fromCatalogItem(item),
      metadata: rawMetadata is MovieCatalogMetadata
          ? rawMetadata
          : rawMetadata == null
              ? null
              : MovieCatalogMetadata.fromJson(item.payload),
    );
  }

  @override
  final CatalogEntityRef ref;
  final MovieCatalogItem movie;
  final MovieMedia media;
  final MovieCatalogMetadata? metadata;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.movie;
  @override
  String get title => movie.work.title;
  @override
  String? get synopsis => movie.work.synopsis;
  @override
  DateTime? get releaseDate => movie.work.releaseDate;
  @override
  String? get coverImageUrl => movie.primaryRelease?.frontCoverUrl;
  @override
  String? get thumbnailImageUrl => movie.primaryRelease?.frontCoverUrl;
}
