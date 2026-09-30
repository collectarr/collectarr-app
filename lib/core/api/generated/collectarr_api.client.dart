import 'package:collectarr_app/core/api/dto/bundle_release.dart';
import 'package:collectarr_app/core/api/dto/media_catalog.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/api/dto/metadata_search_query.dart';
import 'package:collectarr_app/core/models/library_relation_node.dart';
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
    int? offset,
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
        offset: offset,
      ),
    );
  }

  Future<List<Map<String, dynamic>>> searchMetadata(
    MetadataSearchQuery query, {
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/api/v1/search',
      queryParameters: query.toQueryParameters(),
      cancelToken: cancelToken,
    );
    return response.data!
        .cast<Map<String, dynamic>>()
        .map(_resolveImageUrls)
        .toList(growable: false);
  }

  /// Fetches one flattened, kind-owned Catalog Item response.
  ///
  /// This is the canonical read path for Add/Edit catalog data. It does not
  /// route through Work or Release endpoints.
  Future<Map<String, dynamic>> getCatalogItemJson({
    required CatalogMediaKind kind,
    required String id,
    CancelToken? cancelToken,
  }) async {
    final route = switch (kind) {
      CatalogMediaKind.anime => 'anime',
      CatalogMediaKind.boardgame => 'boardgames',
      CatalogMediaKind.book => 'books',
      CatalogMediaKind.comic => 'comics',
      CatalogMediaKind.game => 'games',
      CatalogMediaKind.manga => 'manga',
      CatalogMediaKind.movie => 'movies',
      CatalogMediaKind.music => 'music',
      CatalogMediaKind.tv => 'tv',
      CatalogMediaKind.unknown =>
        throw UnsupportedError('Unknown Catalog Item kind.'),
    };
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/metadata/$route/items/${Uri.encodeComponent(id)}',
      cancelToken: cancelToken,
    );
    final data = response.data;
    if (data == null) {
      throw StateError('Core returned an empty $route Catalog Item response.');
    }
    return _resolveImageUrls(data);
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
      '/api/v1/metadata/books/works/${Uri.encodeComponent(id)}',
      BookWorkDto.fromJson,
    );
  }

  Future<ComicWorkDto> getComicWorkDto(String id) {
    return _fetchTypedMetadataItem(
      '/api/v1/metadata/comics/works/${Uri.encodeComponent(id)}',
      ComicWorkDto.fromJson,
    );
  }

  Future<AnimeSeriesDto> getAnimeSeriesDto(String id) {
    return _fetchTypedMetadataItem(
      '/api/v1/metadata/anime/series/${Uri.encodeComponent(id)}',
      AnimeSeriesDto.fromJson,
    );
  }

  Future<MovieWorkDto> getMovieWorkDto(String id) {
    return _fetchTypedMetadataItem(
      '/api/v1/metadata/movies/works/${Uri.encodeComponent(id)}',
      MovieWorkDto.fromJson,
    );
  }

  Future<TvSeriesDto> getTvSeriesDto(String id) {
    return _fetchTypedMetadataItem(
      '/api/v1/metadata/tv/series/${Uri.encodeComponent(id)}',
      TvSeriesDto.fromJson,
    );
  }

  Future<List<TvSeasonDto>> getTvSeriesSeasonsDto(String id) async {
    final response = await _dio.get<List<dynamic>>(
      '/api/v1/metadata/tv/series/${Uri.encodeComponent(id)}/seasons',
    );
    return (response.data ?? const <dynamic>[])
        .cast<Map<String, dynamic>>()
        .map((value) => TvSeasonDto.fromJson(_resolveImageUrls(value)))
        .toList(growable: false);
  }

  Future<List<TvReleaseDto>> getTvSeriesReleasesDto(String id) async {
    final response = await _dio.get<List<dynamic>>(
      '/api/v1/metadata/tv/series/${Uri.encodeComponent(id)}/releases',
    );
    return (response.data ?? const <dynamic>[])
        .cast<Map<String, dynamic>>()
        .map((value) => TvReleaseDto.fromJson(_resolveImageUrls(value)))
        .toList(growable: false);
  }

  Future<TvSeasonDto> getTvSeasonDto(String id) {
    return _fetchTypedMetadataItem(
      '/api/v1/metadata/tv/seasons/${Uri.encodeComponent(id)}',
      TvSeasonDto.fromJson,
    );
  }

  Future<List<TvEpisodeDto>> getTvSeasonEpisodesDto(String id) async {
    final response = await _dio.get<List<dynamic>>(
      '/api/v1/metadata/tv/seasons/${Uri.encodeComponent(id)}/episodes',
    );
    return (response.data ?? const <dynamic>[])
        .cast<Map<String, dynamic>>()
        .map((value) => TvEpisodeDto.fromJson(_resolveImageUrls(value)))
        .toList(growable: false);
  }

  Future<TvReleaseDto> getTvReleaseDto(String id) {
    return _fetchTypedMetadataItem(
      '/api/v1/metadata/tv/releases/${Uri.encodeComponent(id)}',
      TvReleaseDto.fromJson,
    );
  }

  Future<List<TvReleaseMediaDto>> getTvReleaseMediaDto(String id) async {
    final response = await _dio.get<List<dynamic>>(
      '/api/v1/metadata/tv/releases/${Uri.encodeComponent(id)}/media',
    );
    return (response.data ?? const <dynamic>[])
        .cast<Map<String, dynamic>>()
        .map((value) => TvReleaseMediaDto.fromJson(_resolveImageUrls(value)))
        .toList(growable: false);
  }

  Future<List<TvReleaseEpisodeMapDto>> getTvReleaseEpisodeMapDto(
      String id) async {
    final response = await _dio.get<List<dynamic>>(
      '/api/v1/metadata/tv/releases/${Uri.encodeComponent(id)}/episode-map',
    );
    return (response.data ?? const <dynamic>[])
        .cast<Map<String, dynamic>>()
        .map((value) =>
            TvReleaseEpisodeMapDto.fromJson(_resolveImageUrls(value)))
        .toList(growable: false);
  }

  Future<TvReleaseMediaDto> getTvReleaseMediaItemDto(String id) {
    return _fetchTypedMetadataItem(
      '/api/v1/metadata/tv/media/${Uri.encodeComponent(id)}',
      TvReleaseMediaDto.fromJson,
    );
  }

  Future<GameWorkDto> getGameWorkDto(String id) {
    return _fetchTypedMetadataItem(
      '/api/v1/metadata/games/works/${Uri.encodeComponent(id)}',
      GameWorkDto.fromJson,
    );
  }

  Future<GameReleaseDto> getGameReleaseDto(String id) {
    return _fetchTypedMetadataItem(
      '/api/v1/metadata/games/releases/${Uri.encodeComponent(id)}',
      GameReleaseDto.fromJson,
    );
  }

  Future<BoardGameWorkDto> getBoardGameWorkDto(String id) {
    return _fetchTypedMetadataItem(
      '/api/v1/metadata/boardgames/works/${Uri.encodeComponent(id)}',
      BoardGameWorkDto.fromJson,
    );
  }

  Future<BoardGameEditionDto> getBoardGameEditionDto(String id) {
    return _fetchTypedMetadataItem(
      '/api/v1/metadata/boardgames/editions/${Uri.encodeComponent(id)}',
      BoardGameEditionDto.fromJson,
    );
  }

  Future<BundleReleaseDetail> getBundleRelease(String bundleReleaseId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/metadata/bundle-releases/$bundleReleaseId',
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
        '/api/v1/metadata/bundle-releases/$bundleReleaseId returned an empty response body',
      );
    }
    return BundleReleaseDetail.fromJson(_resolveImageUrls(data));
  }

  Future<List<CatalogMediaType>> metadataMediaTypes() async {
    final response = await _dio.get<dynamic>('/api/v1/metadata/media-types');
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
      '/api/v1/metadata/normalized-manifest',
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
        '/api/v1/metadata/normalized-manifest returned an empty response body',
      );
    }
    return MetadataNormalizedManifest.fromJson(data);
  }

  Future<MetadataFieldSchema> metadataFieldSchema({
    bool editableOnly = true,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/metadata/field-schema',
      queryParameters: {'editable_only': editableOnly},
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
        '/api/v1/metadata/field-schema returned an empty response body',
      );
    }
    return MetadataFieldSchema.fromJson(data);
  }

  Future<Map<String, dynamic>> createCatalogItemProposal({
    required String kind,
    required Map<String, dynamic> catalogItem,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/metadata/proposals',
      data: {
        'schema_version': 'v1',
        'kind': kind,
        'catalog_item': catalogItem,
      },
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
          '/api/v1/metadata/proposals returned an empty response body');
    }
    return data;
  }

  Future<List<LibraryRelationNode>> getSeriesRelations(String seriesId) async {
    final response =
        await _dio.get<List<dynamic>>('/api/v1/series/$seriesId/relations');
    final data = response.data;
    if (data == null) {
      return const [];
    }
    return data
        .cast<Map<String, dynamic>>()
        .map(LibraryRelationNode.fromJson)
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> getSeries(String seriesId) async {
    final response =
        await _dio.get<Map<String, dynamic>>('/api/v1/series/$seriesId');
    final data = response.data;
    if (data == null) {
      throw StateError(
          '/api/v1/series/$seriesId returned an empty response body');
    }
    return data;
  }

  Future<List<Map<String, dynamic>>> getSeriesItems(String seriesId) async {
    final response =
        await _dio.get<List<dynamic>>('/api/v1/series/$seriesId/items');
    final data = response.data;
    if (data == null) {
      return const [];
    }
    return data
        .cast<Map<String, dynamic>>()
        .map(_resolveImageUrls)
        .toList(growable: false);
  }

  Future<BookEditionDto> createBookEdition(
    String workId, {
    required String title,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/metadata/books/works/${Uri.encodeComponent(workId)}/editions',
      data: {'title': title},
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
        '/api/v1/metadata/books/works/$workId/editions returned empty body',
      );
    }
    return BookEditionDto.fromJson(_resolveImageUrls(data));
  }

  Future<BoardGameEditionDto> createBoardGameEdition(
    String workId, {
    required String title,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/metadata/boardgames/works/${Uri.encodeComponent(workId)}/editions',
      data: {'title': title},
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
        '/api/v1/metadata/boardgames/works/$workId/editions returned empty body',
      );
    }
    return BoardGameEditionDto.fromJson(_resolveImageUrls(data));
  }

  Future<Map<String, dynamic>> lookupBarcode(
    String barcode, {
    String? kind,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/barcode/${Uri.encodeComponent(MetadataSearchQuery.normalizeBarcode(barcode))}',
      queryParameters: {if (kind != null) 'kind': kind},
      cancelToken: cancelToken,
    );
    final data = response.data;
    if (data == null) {
      throw StateError('/api/v1/barcode returned an empty response body');
    }
    return _resolveImageUrls(data);
  }
}
