import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/dto/catalog_search_page.dart';
import 'package:collectarr_app/core/api/dto/metadata_search_query.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/data/remote/music_catalog_remote_source.dart';
import 'package:dio/dio.dart';

Future<CatalogSearchPage> searchMusicCatalogItems({
  required ApiClient api,
  required MetadataSearchQuery query,
  CancelToken? cancelToken,
}) async {
  final page = await MusicCatalogRemoteSource(api).searchPage(
    query: query.query,
    barcode: query.barcode,
    artist: query.series,
    label: query.publisher,
    year: query.year,
    limit: query.limit ?? 25,
    offset: query.offset ?? 0,
    cancelToken: cancelToken,
  );
  return CatalogSearchPage(
    items: [
      for (final item in page.items)
        MusicCatalogMapper.toCatalogItemDto(
          MusicCatalogMapper.fromCatalogPayload(item),
        ).toEnvelope().toJson(),
    ],
    nextOffset: page.nextOffset,
    hasMore: page.hasMore,
  );
}

CatalogSearchCandidate musicCatalogTransportFromCoreItem(
  CatalogSearchCandidate item,
) =>
    item;

MusicAlbum musicCatalogItemFromCandidate(
  CatalogSearchCandidate item,
) {
  return item.kindCapability.mapTransport((transport) {
    return MusicCatalogMapper.mapMetadataItemToMusic(transport);
  });
}
