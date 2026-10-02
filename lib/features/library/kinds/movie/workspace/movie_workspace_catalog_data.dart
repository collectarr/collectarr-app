import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/movie/catalog/movie_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';

final class MovieWorkspaceCatalogData
    implements
        LibraryWorkspaceCatalogData,
        LibraryWorkspaceCatalogSynopsisData {
  MovieWorkspaceCatalogData({
    required this.ref,
    required this.movie,
    required this.metadata,
    required CatalogItemDto transport,
  }) : _transport = transport;

  factory MovieWorkspaceCatalogData.fromTransport(CatalogItemDto item) {
    return MovieWorkspaceCatalogData(
      ref: item.catalogRef,
      movie: MovieCatalogMapper.mapMetadataItemToMovie(item),
      metadata: MovieCatalogMetadata.fromJson(item.payload),
      transport: item,
    );
  }

  @override
  final CatalogEntityRef ref;
  final MovieCatalogItem movie;
  final MovieCatalogMetadata? metadata;
  final CatalogItemDto _transport;

  CatalogItemDto get transport => _transport;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.movie;
  @override
  String get title => movie.title;
  @override
  String? get synopsis => movie.synopsis;
  @override
  DateTime? get releaseDate => movie.releaseDate;
  @override
  String? get coverImageUrl => movie.coverImageUrl;
  @override
  String? get thumbnailImageUrl => movie.thumbnailImageUrl ?? coverImageUrl;
}
