import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/dto/metadata_search_query.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/music/data/remote/music_catalog_remote_source.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:dio/dio.dart';

Future<List<Map<String, dynamic>>> searchMusicCatalogItems({
  required ApiClient api,
  required MetadataSearchQuery query,
  CancelToken? cancelToken,
}) async {
  final results = await MusicCatalogRemoteSource(api).search(
    query: query.query,
    barcode: query.barcode,
    artist: query.series,
    label: query.publisher,
    year: query.year,
    limit: query.limit ?? 25,
    cancelToken: cancelToken,
  );
  return [for (final item in results) item.toSearchJson()];
}

CatalogSearchCandidate musicCatalogTransportFromCoreItem(
  CatalogSearchCandidate item,
) {
  return item.kindCapability.mapTransport((transport) {
    final group = MusicCatalogMapper.mapMetadataItemToMusic(transport);
    return item.kindCapability.withKindMetadata(group);
  });
}

