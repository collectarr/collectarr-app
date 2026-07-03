import 'package:collectarr_app/core/api/generated/catalog_metadata_dto.dart';
import 'package:collectarr_app/core/models/bundle_release.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/season.dart';
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
    return (await searchMetadataDtos(query))
        .map((dto) => dto.toJson())
        .toList(growable: false);
  }

  Future<List<CatalogMetadataDto>> searchMetadataDtos(
    MetadataSearchQuery query,
  ) async {
    final response = await _dio.get<List<dynamic>>(
      '/search',
      queryParameters: query.toQueryParameters(),
    );
    return response.data!
        .cast<Map<String, dynamic>>()
        .map(_resolveImageUrls)
        .map(CatalogMetadataDto.fromJson)
        .toList(growable: false);
  }

  Future<TypedMetadataResponse> getTypedMetadataItemDto({
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
        final encodedKind = Uri.encodeComponent(kind);
        final response = await _dio.get<Map<String, dynamic>>(
          '/metadata/$encodedKind/$encodedId',
        );
        final data = response.data;
        if (data == null) {
          throw StateError(
            '/metadata/$encodedKind/$encodedId returned an empty response body',
          );
        }
        return _legacyTypedDtoFromJson(_resolveImageUrls(data));
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

  TypedMetadataResponse _legacyTypedDtoFromJson(Map<String, dynamic> json) {
    final kind = json['kind']?.toString().toLowerCase();
    return switch (kind) {
      'book' => BookWorkDto.fromJson(json),
      'game' => GameWorkDto.fromJson(json),
      'boardgame' => BoardGameWorkDto.fromJson(json),
      'music' => MusicReleaseDto.fromJson(json),
      _ => _FallbackTypedResponse(json),
    };
  }

  Future<List<BundleReleaseSummary>> getItemBundleReleases(
    String itemId,
  ) async {
    final response = await _dio.get<List<dynamic>>(
      '/metadata/items/$itemId/bundle-releases',
    );
    final data = response.data;
    if (data == null) {
      return const [];
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(_resolveImageUrls)
        .map(BundleReleaseSummary.fromJson)
        .toList(growable: false);
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
    final response = await _dio.get<Map<String, dynamic>>('/metadata/comic/$id');
    return _resolveImageUrls(response.data!);
  }

  Future<List<SeriesRelation>> getSeriesRelations(String seriesId) async {
    final response = await _dio.get<List<dynamic>>('/series/$seriesId/relations');
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

  Future<List<Season>> getItemVolumes(
    String itemId, {
    String? kind,
  }) async {
    final normalizedKind = kind?.trim().toLowerCase();
    if (normalizedKind == 'manga') {
      final dto = await getMangaWorkDto(itemId);
      return _seasonsFromMangaChapters(dto);
    }
    final response = await _dio.get<List<dynamic>>(
      '/metadata/items/${Uri.encodeComponent(itemId)}/volumes',
    );
    final data = response.data;
    if (data == null) {
      return const [];
    }
    return data
        .cast<Map<String, dynamic>>()
        .map(Season.fromJson)
        .toList(growable: false);
  }

  Future<List<Season>> getItemSeasons(
    String itemId, {
    String? kind,
  }) async {
    final normalizedKind = kind?.trim().toLowerCase();
    if (normalizedKind == 'anime') {
      final dto = await getAnimeSeriesDto(itemId);
      return _seasonsFromAnimeEpisodes(dto);
    }
    if (normalizedKind == 'tv') {
      final dto = await getTvSeriesDto(itemId);
      return [
        for (final season in dto.seasons) Season.fromJson(season),
      ];
    }
    final response = await _dio.get<List<dynamic>>(
      '/metadata/items/${Uri.encodeComponent(itemId)}/seasons',
    );
    final data = response.data;
    if (data == null) {
      return const [];
    }
    return data
        .cast<Map<String, dynamic>>()
        .map(Season.fromJson)
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

  @Deprecated('Use kind-specific typed edition creation endpoints when available.')
  Future<CatalogEdition> createEdition(
    String itemId, {
    required String title,
    String? kind,
  }) async {
    final normalizedKind = kind?.trim().toLowerCase();
    if (normalizedKind == 'book') {
      return createBookEdition(itemId, title: title);
    }
    if (normalizedKind == 'boardgame') {
      return createBoardGameEdition(itemId, title: title);
    }
    final response = await _dio.post<Map<String, dynamic>>(
      '/metadata/items/${Uri.encodeComponent(itemId)}/editions',
      data: {'title': title},
    );
    final data = response.data;
    if (data == null) {
      throw StateError('/metadata/items/$itemId/editions returned empty body');
    }
    return CatalogEdition.fromJson(data);
  }

  Future<Map<String, dynamic>> lookupBarcode(
    String barcode, {
    String? kind,
  }) async {
    return (await lookupBarcodeDto(barcode, kind: kind)).toJson();
  }

  Future<CatalogMetadataDto> lookupBarcodeDto(
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
    return CatalogMetadataDto.fromJson(_resolveImageUrls(data));
  }

  List<Season> _seasonsFromMangaChapters(MangaWorkDto dto) {
    if (dto.chapters.isEmpty) {
      return const [];
    }
    return [
      Season(
        seasonNumber: 1,
        title: dto.title,
        episodeCount: dto.chapters.length,
        episodes: [
          for (final chapter in dto.chapters)
            Episode(
              episodeNumber: _intValue(chapter['chapter_number']) ?? 0,
              title: chapter['chapter_title']?.toString() ??
                  chapter['title']?.toString() ??
                  'Chapter',
              airDate: chapter['publication_date']?.toString(),
              pageCount: _intValue(chapter['page_count']),
            ),
        ],
      ),
    ];
  }

  List<Season> _seasonsFromAnimeEpisodes(AnimeSeriesDto dto) {
    if (dto.episodes.isEmpty) {
      return const [];
    }
    return [
      Season(
        seasonNumber: 1,
        title: dto.title,
        episodeCount: dto.episodes.length,
        episodes: [
          for (final episode in dto.episodes)
            Episode(
              episodeNumber: _intValue(episode['episode_number']) ?? 0,
              title: episode['episode_title']?.toString() ??
                  episode['title']?.toString() ??
                  'Episode',
              airDate: episode['air_date']?.toString(),
              runtimeMinutes: _intValue(episode['runtime_minutes']),
            ),
        ],
      ),
    ];
  }
}

class _FallbackTypedResponse extends TypedMetadataResponse {
  _FallbackTypedResponse(super.raw)
      : id = raw['id']?.toString() ?? '',
        title = raw['title']?.toString() ?? 'Untitled item',
        kind = raw['kind']?.toString(),
        releaseDate = null,
        coverImageUrl = raw['cover_image_url']?.toString(),
        thumbnailImageUrl = raw['thumbnail_image_url']?.toString(),
        barcode = raw['barcode']?.toString();

  @override
  final String id;
  @override
  final String title;
  @override
  final String? kind;
  @override
  final DateTime? releaseDate;
  @override
  final String? coverImageUrl;
  @override
  final String? thumbnailImageUrl;
  @override
  final String? barcode;
}

int? _intValue(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}
