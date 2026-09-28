import 'package:collectarr_app/core/api/dto/bundle_release.dart';
import 'package:collectarr_app/core/api/dto/media_catalog.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/api/dto/metadata_search_query.dart';
import 'package:collectarr_app/core/models/library_relation_node.dart';
import 'collectarr_api.models.dart';
import 'package:dio/dio.dart';

class CollectarrApiClient {
  CollectarrApiClient(this._dio, this._resolveImageUrls);

  final Dio _dio;
  final Map<String, dynamic> Function(Map<String, dynamic>) _resolveImageUrls;

  Future<List<CatalogItemSummaryV1Dto>> searchCatalogItems({
    CatalogMediaKind? kind,
    String? query,
    String? identifier,
    int limit = 50,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/api/v1/metadata/catalog/items',
      queryParameters: {
        if (kind != null) 'kind': kind.apiValue,
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        if (identifier != null && identifier.trim().isNotEmpty)
          'identifier': identifier.trim(),
        'limit': limit,
      },
      cancelToken: cancelToken,
    );
    final rows = response.data;
    if (rows == null) {
      throw StateError('/api/v1/metadata/catalog/items returned no body.');
    }
    return List.unmodifiable([
      for (final raw in rows)
        if (raw is Map)
          CatalogItemSummaryV1Dto.fromJson(
            _resolveImageUrls(Map<String, dynamic>.from(raw)),
          )
        else
          throw const FormatException(
            'Catalog Item search entries must be JSON objects.',
          ),
    ]);
  }

  Future<CatalogItemV1Dto> getCatalogItem(CatalogItemRef reference) async {
    final path =
        '/api/v1/metadata/catalog/items/${Uri.encodeComponent(reference.id)}';
    final response = await _dio.get<Map<String, dynamic>>(path);
    final data = response.data;
    if (data == null) throw StateError('$path returned an empty response body');
    final item = CatalogItemV1Dto.fromJson(_resolveImageUrls(data));
    if (item.reference != reference) {
      throw StateError(
        'Catalog Item $reference resolved to a different identity: ${item.reference}.',
      );
    }
    return item;
  }

  Future<CatalogItemV1Dto> createCatalogItem(
    CatalogItemWriteV1Dto payload,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/metadata/catalog/items',
      data: payload.toJson(),
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
          '/api/v1/metadata/catalog/items returned an empty response body');
    }
    final item = CatalogItemV1Dto.fromJson(_resolveImageUrls(data));
    if (item.kind != payload.details.kind) {
      throw StateError(
        'Catalog Item create requested kind ${payload.details.kind}, '
        'but the server returned ${item.kind}.',
      );
    }
    return item;
  }

  Future<CatalogItemV1Dto> updateCatalogItem(
    CatalogItemRef reference,
    CatalogItemWriteV1Dto payload,
  ) async {
    if (payload.details.kind != reference.kind.apiValue) {
      throw ArgumentError.value(
        payload.details.kind,
        'payload.details.kind',
        'Must match Catalog Item reference kind ${reference.kind.apiValue}.',
      );
    }
    final path =
        '/api/v1/metadata/catalog/items/${Uri.encodeComponent(reference.id)}';
    final response = await _dio.put<Map<String, dynamic>>(
      path,
      data: payload.toJson(),
    );
    final data = response.data;
    if (data == null) throw StateError('$path returned an empty response body');
    final item = CatalogItemV1Dto.fromJson(_resolveImageUrls(data));
    if (item.reference != reference) {
      throw StateError(
        'Catalog Item update for $reference returned ${item.reference}.',
      );
    }
    return item;
  }

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
    MetadataSearchQuery query, {
    CancelToken? cancelToken,
  }) async {
    final rawQuery = query.query?.trim();
    final identifier = query.barcode?.trim().isNotEmpty == true
        ? query.barcode!.trim()
        : rawQuery != null && RegExp(r'^\d{8,14}$').hasMatch(rawQuery)
            ? rawQuery
            : null;
    final searchText = [
      rawQuery,
      query.series,
      query.issueNumber,
      query.publisher,
      if (query.year != null) query.year.toString(),
    ].whereType<String>().map((value) => value.trim()).firstWhere(
          (value) => value.isNotEmpty,
          orElse: () => '',
        );
    final rawKind = query.kind?.trim();
    final kind = rawKind == null || rawKind.isEmpty
        ? null
        : catalogMediaKindFromApiValue(rawKind);
    final results = await searchCatalogItems(
      kind: kind?.isUnknown == true ? null : kind,
      query: searchText.isEmpty ? null : searchText,
      identifier: identifier,
      limit: query.limit ?? 50,
      cancelToken: cancelToken,
    );
    return List.unmodifiable([
      for (final result in results) result.toJson(),
    ]);
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

  Future<MangaWorkDto> getMangaWorkDto(String id) {
    return _fetchTypedMetadataItem(
      '/api/v1/metadata/manga/works/${Uri.encodeComponent(id)}',
      MangaWorkDto.fromJson,
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
      '/api/v1/metadata/proposals',
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
    final rawKind = kind?.trim();
    final parsedKind = rawKind == null || rawKind.isEmpty
        ? null
        : catalogMediaKindFromApiValue(rawKind);
    final matches = await searchCatalogItems(
      kind: parsedKind?.isUnknown == true ? null : parsedKind,
      identifier: MetadataSearchQuery.normalizeBarcode(barcode),
      limit: 1,
      cancelToken: cancelToken,
    );
    if (matches.isEmpty) {
      throw StateError('No Catalog Item matches barcode $barcode.');
    }
    final match = matches.first;
    final item = await getCatalogItem(match.reference);
    return {
      'id': item.id,
      'kind': item.kind,
      'created_at': item.createdAt.toIso8601String(),
      'updated_at': item.updatedAt.toIso8601String(),
      ...item.details.toJson(),
    };
  }
}
