import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/library/kinds/music/data/remote/catalog_music_item_dto.dart';
import 'package:dio/dio.dart';

/// Remote access to the source-neutral Music Catalog Item API.
///
/// The Music kind owns both its transport model and decoding. The shared API
/// client only provides the HTTP and JSON boundary.
final class MusicCatalogRemoteSource {
  const MusicCatalogRemoteSource(this._api);

  final ApiClient _api;

  Future<List<CatalogMusicItemDto>> search({
    String? query,
    String? barcode,
    int limit = 25,
    int offset = 0,
    CancelToken? cancelToken,
  }) async {
    final rows = await _api.getJsonList(
      '/api/v1/metadata/music/items',
      queryParameters: {
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        if (barcode != null && barcode.trim().isNotEmpty)
          'barcode': barcode.trim(),
        'limit': limit,
        'offset': offset,
      },
      cancelToken: cancelToken,
    );
    return [for (final row in rows) CatalogMusicItemDto.fromJson(row)];
  }

  Future<CatalogMusicItemDto> getById(
    String itemId, {
    CancelToken? cancelToken,
  }) async {
    final json = await _api.getJsonObject(
      '/api/v1/metadata/music/items/${Uri.encodeComponent(itemId)}',
      cancelToken: cancelToken,
    );
    return CatalogMusicItemDto.fromJson(json);
  }
}
