import 'package:collectarr_app/core/models/bundle_release.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';

import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/core/models/metadata_search_query.dart';
import 'package:collectarr_app/core/models/series_relation.dart';
import 'collectarr_api.models.dart';
import 'package:dio/dio.dart';

class CollectarrApiClient {
  CollectarrApiClient(this._dio, this._resolveImageUrls);

  final Dio _dio;
  final Map<String, dynamic> Function(Map<String, dynamic>) _resolveImageUrls;

  Future<List<Map<String, dynamic>>> search(
    String query, {
    String? kind,
    String? series,
    String? issueNumber,
    String? publisher,
    int? year,
    String? barcode,
    int? limit,
  }) async {
    return searchMetadata(
      MetadataSearchQuery(
        query: query,
        kind: kind,
        series: series,
        issueNumber: issueNumber,
        publisher: publisher,
        year: year,
        barcode: barcode,
        limit: limit,
      ),
    );
  }

  Future<List<Map<String, dynamic>>> searchMetadata(
    MetadataSearchQuery query,
  ) async {
    final response = await _dio.get<List<dynamic>>(
      '/search',
      queryParameters: query.toQueryParameters(),
    );
    return response.data!
        .cast<Map<String, dynamic>>()
        .map(_resolveImageUrls)
        .toList(growable: false);
  }

  Future<TypedMetadataResponse> getTypedMetadataItem({
    required String kind,
    required String id,
  }) async {
    final encodedId = Uri.encodeComponent(id);
    switch (kind.trim().toLowerCase()) {
      case 'comic':
        return getComicWorkDto(id);
      case 'manga':
        return getMangaWorkDto(id);
      case 'anime':
        return getAnimeSeriesDto(id);
      case 'movie':
        return getMovieWorkDto(id);
      case 'tv':
        return getTvSeriesDto(id);
      case 'book':
        return getBookWorkDto(id);
      case 'game':
        return getGameWorkDto(id);
      case 'boardgame':
        return getBoardGameWorkDto(id);
      case 'music':
        return getMusicReleaseDto(id);
      default:
        throw UnsupportedError('Unsupported metadata kind: $kind');
    }
  }

  Future<T> _fetchTypedMetadataItem<T extends TypedMetadataResponse>(
    String path,
    T Function(Map<String, dynamic>) factory,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(path);
    final data = response.data;
    if (data == null) {
      throw StateError('$path returned an empty response body');
    }
    return factory(_resolveImageUrls(data));
  }

  Future<BookWorkDto> getBookWorkDto(String id) {
    return _fetchTypedMetadataItem(
      '/metadata/books/works/${Uri.encodeComponent(id)}',
      BookWorkDto.fromJson,
    );
  }

  Future<ComicWorkDto> getComicWorkDto(String id) {
    return _fetchTypedMetadataItem(
      '/metadata/comics/works/${Uri.encodeComponent(id)}',
      ComicWorkDto.fromJson,
    );
  }

  Future<MangaWorkDto> getMangaWorkDto(String id) {
    return _fetchTypedMetadataItem(
      '/metadata/manga/works/${Uri.encodeComponent(id)}',
      MangaWorkDto.fromJson,
    );
  }

  Future<AnimeSeriesDto> getAnimeSeriesDto(String id) {
    return _fetchTypedMetadataItem(
      '/metadata/anime/series/${Uri.encodeComponent(id)}',
      AnimeSeriesDto.fromJson,
    );
  }

  Future<MovieWorkDto> getMovieWorkDto(String id) {
    return _fetchTypedMetadataItem(
      '/metadata/movies/works/${Uri.encodeComponent(id)}',
      MovieWorkDto.fromJson,
    );
  }

  Future<TvSeriesDto> getTvSeriesDto(String id) {
    return _fetchTypedMetadataItem(
      '/metadata/tv/series/${Uri.encodeComponent(id)}',
      TvSeriesDto.fromJson,
    );
  }

  Future<GameWorkDto> getGameWorkDto(String id) {
    return _fetchTypedMetadataItem(
      '/metadata/games/works/${Uri.encodeComponent(id)}',
      GameWorkDto.fromJson,
    );
  }

  Future<GameReleaseDto> getGameReleaseDto(String id) {
    return _fetchTypedMetadataItem(
      '/metadata/games/releases/${Uri.encodeComponent(id)}',
      GameReleaseDto.fromJson,
    );
  }

  Future<BoardGameWorkDto> getBoardGameWorkDto(String id) {
    return _fetchTypedMetadataItem(
      '/metadata/boardgames/works/${Uri.encodeComponent(id)}',
      BoardGameWorkDto.fromJson,
    );
  }

  Future<BoardGameEditionDto> getBoardGameEditionDto(String id) {
    return _fetchTypedMetadataItem(
      '/metadata/boardgames/editions/${Uri.encodeComponent(id)}',
      BoardGameEditionDto.fromJson,
    );
  }

  Future<MusicReleaseDto> getMusicReleaseDto(String id) {
    return _fetchTypedMetadataItem(
      '/metadata/music/releases/${Uri.encodeComponent(id)}',
      MusicReleaseDto.fromJson,
    );
  }

  Future<MusicMediaDto> getMusicMediaDto(String id) {
    return _fetchTypedMetadataItem(
      '/metadata/music/media/${Uri.encodeComponent(id)}',
      MusicMediaDto.fromJson,
    );
  }

  Future<MusicTrackDto> getMusicTrackDto(String id) {
    return _fetchTypedMetadataItem(
      '/metadata/music/tracks/${Uri.encodeComponent(id)}',
      MusicTrackDto.fromJson,
    );
  }

  Future<List<BundleReleaseSummary>> getItemBundleReleases(
    String itemId,
  ) async {
    return const [];
  }

  Future<BundleReleaseDetail> getBundleRelease(String bundleReleaseId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/metadata/bundle-releases/$bundleReleaseId',
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
        '/metadata/bundle-releases/$bundleReleaseId returned an empty response body',
      );
    }
    return BundleReleaseDetail.fromJson(_resolveImageUrls(data));
  }

  Future<List<CatalogMediaType>> metadataMediaTypes() async {
    final response = await _dio.get<dynamic>('/metadata/media-types');
    final data = response.data;
    if (data == null) {
      return const [];
    }
    final rows = data is List<dynamic>
        ? data
        : data is Map<String, dynamic>
            ? data['media_types'] as List<dynamic>? ?? const []
            : const <dynamic>[];
    return rows
        .cast<Map<String, dynamic>>()
        .map(CatalogMediaType.fromJson)
        .toList(growable: false);
  }

  Future<MetadataNormalizedManifest> metadataNormalizedManifest() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/metadata/normalized-manifest',
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
        '/metadata/normalized-manifest returned an empty response body',
      );
    }
    return MetadataNormalizedManifest.fromJson(data);
  }

  Future<MetadataFieldSchema> metadataFieldSchema({
    bool editableOnly = true,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/metadata/field-schema',
      queryParameters: {'editable_only': editableOnly},
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
        '/metadata/field-schema returned an empty response body',
      );
    }
    return MetadataFieldSchema.fromJson(data);
  }

  Future<Map<String, dynamic>> createMetadataProposal({
    required String provider,
    required String query,
    String? providerItemId,
    String? title,
    String? summary,
    String? imageUrl,
    Map<String, dynamic>? metadataPayload,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/metadata/proposals',
      data: {
        'provider': provider,
        'query': query,
        if (providerItemId != null) 'provider_item_id': providerItemId,
        if (title != null) 'title': title,
        if (summary != null) 'summary': summary,
        if (imageUrl != null) 'image_url': imageUrl,
        if (metadataPayload != null) 'metadata_payload': metadataPayload,
      },
    );
    final data = response.data;
    if (data == null) {
      throw StateError('/metadata/proposals returned an empty response body');
    }
    return data;
  }

  Future<Map<String, dynamic>> getComic(String id) async {
    final response =
        await _dio.get<Map<String, dynamic>>('/metadata/comic/$id');
    return _resolveImageUrls(response.data!);
  }

  Future<List<SeriesRelation>> getSeriesRelations(String seriesId) async {
    final response =
        await _dio.get<List<dynamic>>('/series/$seriesId/relations');
    final data = response.data;
    if (data == null) {
      return const [];
    }
    return data
        .cast<Map<String, dynamic>>()
        .map(SeriesRelation.fromJson)
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> getSeries(String seriesId) async {
    final response = await _dio.get<Map<String, dynamic>>('/series/$seriesId');
    final data = response.data;
    if (data == null) {
      throw StateError('/series/$seriesId returned an empty response body');
    }
    return data;
  }

  Future<List<Map<String, dynamic>>> getSeriesItems(String seriesId) async {
    final response = await _dio.get<List<dynamic>>('/series/$seriesId/items');
    final data = response.data;
    if (data == null) {
      return const [];
    }
    return data
        .cast<Map<String, dynamic>>()
        .map(_resolveImageUrls)
        .toList(growable: false);
  }

  Future<CatalogEdition> createBookEdition(
    String workId, {
    required String title,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/metadata/books/works/${Uri.encodeComponent(workId)}/editions',
      data: {'title': title},
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
        '/metadata/books/works/$workId/editions returned empty body',
      );
    }
    return CatalogEdition.fromJson(data);
  }

  Future<CatalogEdition> createBoardGameEdition(
    String workId, {
    required String title,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/metadata/boardgames/works/${Uri.encodeComponent(workId)}/editions',
      data: {'title': title},
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
        '/metadata/boardgames/works/$workId/editions returned empty body',
      );
    }
    return CatalogEdition.fromJson(data);
  }

  Future<Map<String, dynamic>> lookupBarcode(
    String barcode, {
    String? kind,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/barcode/${Uri.encodeComponent(MetadataSearchQuery.normalizeBarcode(barcode))}',
      queryParameters: {if (kind != null) 'kind': kind},
    );
    final data = response.data;
    if (data == null) {
      throw StateError('/barcode returned an empty response body');
    }
    return _resolveImageUrls(data);
  }
}
