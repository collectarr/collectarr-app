import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/features/library/kinds/registry/catalog_kind_transport_codec_defaults.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/data.dart';

final class MovieCatalogTransportCodec
    with CatalogKindTransportCodecDefaults<MovieCatalogMetadata> {
  const MovieCatalogTransportCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.movie;

  @override
  MovieCatalogMetadata decode(CatalogItemDto item) =>
      MovieCatalogMetadata.fromJson(item.kindData);

  @override
  MovieCatalogMetadata decodeKindData(Map<String, dynamic> kindData) =>
      MovieCatalogMetadata.fromJson(kindData);

  @override
  CatalogItemDto encode(String id, MovieCatalogMetadata item) =>
      CatalogItemDto.raw(
        id: id,
        mediaKind: kind,
        kindData: item.toJson(),
      );

  @override
  CatalogDisplaySummary summarize(
    String catalogItemId,
    MovieCatalogMetadata item,
  ) =>
      CatalogDisplaySummary.forCatalogItem(
        kind: kind,
        id: catalogItemId,
        primaryLabel: item.title,
        imageUrl: item.thumbnailImageUrl ?? item.coverImageUrl,
      );

  @override
  MovieWorkspaceData workspaceData(CatalogItemDto item) =>
      MovieWorkspaceData(metadata: decode(item));

  @override
  MovieWorkspaceData workspaceDataFromKindData(
    Map<String, dynamic> kindData,
  ) =>
      MovieWorkspaceData(metadata: MovieCatalogMetadata.fromJson(kindData));
}
