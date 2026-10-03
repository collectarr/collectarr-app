import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:dio/dio.dart';

/// Remote access to the source-neutral Music Catalog Item API.
///
/// The Music kind owns both its transport model and decoding. The shared API
/// client only provides the HTTP and JSON boundary.
final class MusicCatalogRemoteSource {
  const MusicCatalogRemoteSource(this._api);

  final ApiClient _api;

  Future<List<MusicAlbum>> search({
    String? query,
    String? barcode,
    String? artist,
    String? label,
    int? year,
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
        if (artist != null && artist.trim().isNotEmpty) 'artist': artist.trim(),
        if (label != null && label.trim().isNotEmpty) 'label': label.trim(),
        if (year != null) 'year': year,
        'limit': limit,
        'offset': offset,
      },
      cancelToken: cancelToken,
    );
    return [for (final row in rows) MusicCatalogMapper.fromCatalogPayload(row)];
  }

  Future<MusicAlbum> getById(
    String itemId, {
    CancelToken? cancelToken,
  }) async {
    final json = await _api.getJsonObject(
      '/api/v1/metadata/music/items/${Uri.encodeComponent(itemId)}',
      cancelToken: cancelToken,
    );
    return MusicCatalogMapper.fromCatalogPayload(json);
  }
}
