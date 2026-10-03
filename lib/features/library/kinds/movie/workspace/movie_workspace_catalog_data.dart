import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';

final class MovieWorkspaceCatalogData
    implements
        LibraryWorkspaceCatalogData,
        LibraryWorkspaceCatalogSynopsisData {
  MovieWorkspaceCatalogData({
    required this.ref,
    required this.metadata,
    required CatalogItemDto transport,
  }) : _transport = transport;

  factory MovieWorkspaceCatalogData.fromTransport(CatalogItemDto item) {
    return MovieWorkspaceCatalogData(
      ref: item.catalogRef,
      metadata: MovieCatalogMetadata.fromJson(item.kindData),
      transport: item,
    );
  }

  @override
  final CatalogEntityRef ref;
  final MovieCatalogMetadata metadata;
  final CatalogItemDto _transport;

  CatalogItemDto get transport => _transport;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.movie;
  @override
  String get title => metadata.title;
  @override
  String? get synopsis => metadata.synopsis;
  @override
  DateTime? get releaseDate =>
      metadata.releaseDate ?? metadata.releaseDateParts?.asDateTime;
  @override
  String? get coverImageUrl => metadata.coverImageUrl;
  @override
  String? get thumbnailImageUrl => metadata.thumbnailImageUrl ?? coverImageUrl;
}
