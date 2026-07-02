part of 'api_client.dart';

class _CatalogApiClient {
  _CatalogApiClient(this._client);

  final ApiClient _client;

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
    final response = await _client._dio.get<List<dynamic>>(
      '/search',
      queryParameters: query.toQueryParameters(),
    );
    return response.data!
        .cast<Map<String, dynamic>>()
        .map(_client._resolveImageUrls)
        .map(CatalogMetadataDto.fromJson)
        .toList(growable: false);
  }

  Future<CatalogItem> getMetadataItem({
    required String kind,
    required String id,
  }) async {
    return (await getTypedMetadataItemDto(kind: kind, id: id)).toCatalogItem();
  }

  Future<CatalogMetadataDto> getMetadataItemDto({
    required String kind,
    required String id,
  }) async {
    final typed = await getTypedMetadataItemDto(kind: kind, id: id);
    return CatalogMetadataDto.fromJson(typed.raw);
  }

  Future<CatalogTypedDto> getTypedMetadataItemDto({
    required String kind,
    required String id,
  }) async {
    final encodedId = Uri.encodeComponent(id);
    switch (kind.trim().toLowerCase()) {
      case 'book':
        return getBookWorkDto(id);
      case 'game':
        return getGameWorkDto(id);
      case 'boardgame':
        return getBoardGameWorkDto(id);
      default:
        final encodedKind = Uri.encodeComponent(kind);
        final response = await _client._dio.get<Map<String, dynamic>>(
          '/metadata/$encodedKind/$encodedId',
        );
        final data = response.data;
        if (data == null) {
          throw StateError(
            '/metadata/$encodedKind/$encodedId returned an empty response body',
          );
        }
        return _legacyTypedDtoFromJson(
          _client._resolveImageUrls(data),
        );
    }
  }

  Future<T> _fetchTypedMetadataItem<T extends CatalogTypedDto>(
    String path,
    T Function(Map<String, dynamic>) factory,
  ) async {
    final response = await _client._dio.get<Map<String, dynamic>>(
      path,
    );
    final data = response.data;
    if (data == null) {
      throw StateError('$path returned an empty response body');
    }
    return factory(_client._resolveImageUrls(data));
  }

  Future<BookWorkDto> getBookWorkDto(String id) {
    return _fetchTypedMetadataItem(
      '/metadata/books/works/${Uri.encodeComponent(id)}',
      BookWorkDto.fromJson,
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

  CatalogTypedDto _legacyTypedDtoFromJson(Map<String, dynamic> json) {
    final kind = json['kind']?.toString().toLowerCase();
    return switch (kind) {
      'book' => BookWorkDto.fromJson(json),
      'game' => GameWorkDto.fromJson(json),
      'boardgame' => BoardGameWorkDto.fromJson(json),
      _ => _FallbackTypedDto(json),
    };
  }

  Future<List<BundleReleaseSummary>> getItemBundleReleases(
      String itemId) async {
    final response = await _client._dio.get<List<dynamic>>(
      '/metadata/items/$itemId/bundle-releases',
    );
    final data = response.data;
    if (data == null) {
      return const [];
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(_client._resolveImageUrls)
        .map(BundleReleaseSummary.fromJson)
        .toList(growable: false);
  }

  Future<BundleReleaseDetail> getBundleRelease(String bundleReleaseId) async {
    final response = await _client._dio.get<Map<String, dynamic>>(
      '/metadata/bundle-releases/$bundleReleaseId',
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
        '/metadata/bundle-releases/$bundleReleaseId returned an empty response body',
      );
    }
    return BundleReleaseDetail.fromJson(_client._resolveImageUrls(data));
  }

  Future<List<CatalogMediaType>> metadataMediaTypes() async {
    final response = await _client._dio.get<dynamic>('/metadata/media-types');
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
    final response = await _client._dio.get<Map<String, dynamic>>(
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
    final response = await _client._dio.get<Map<String, dynamic>>(
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
    final response = await _client._dio.post<Map<String, dynamic>>(
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
        await _client._dio.get<Map<String, dynamic>>('/metadata/comic/$id');
    return _client._resolveImageUrls(response.data!);
  }

  Future<List<SeriesRelation>> getSeriesRelations(String seriesId) async {
    final response = await _client._dio.get<List<dynamic>>(
      '/series/$seriesId/relations',
    );
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
    final response =
        await _client._dio.get<Map<String, dynamic>>('/series/$seriesId');
    final data = response.data;
    if (data == null) {
      throw StateError('/series/$seriesId returned an empty response body');
    }
    return data;
  }

  Future<List<Map<String, dynamic>>> getSeriesItems(String seriesId) async {
    final response =
        await _client._dio.get<List<dynamic>>('/series/$seriesId/items');
    final data = response.data;
    if (data == null) {
      return const [];
    }
    return data
        .cast<Map<String, dynamic>>()
        .map(_client._resolveImageUrls)
        .toList(growable: false);
  }

  Future<List<Season>> getItemVolumes(String itemId) async {
    final response = await _client._dio.get<List<dynamic>>(
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

  Future<List<Season>> getItemSeasons(String itemId) async {
    final response = await _client._dio.get<List<dynamic>>(
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

  Future<CatalogEdition> createEdition(String itemId,
      {required String title}) async {
    final response = await _client._dio.post<Map<String, dynamic>>(
      '/metadata/items/${Uri.encodeComponent(itemId)}/editions',
      data: {'title': title},
    );
    final data = response.data;
    if (data == null) {
      throw StateError('/metadata/items/$itemId/editions returned empty body');
    }
    return CatalogEdition.fromJson(data);
  }

  Future<Map<String, dynamic>> lookupBarcode(String barcode,
      {String? kind}) async {
    return (await lookupBarcodeDto(barcode, kind: kind)).toJson();
  }

  Future<CatalogMetadataDto> lookupBarcodeDto(String barcode,
      {String? kind}) async {
    final response = await _client._dio.get<Map<String, dynamic>>(
      '/barcode/${Uri.encodeComponent(MetadataSearchQuery.normalizeBarcode(barcode))}',
      queryParameters: {if (kind != null) 'kind': kind},
    );
    final data = response.data;
    if (data == null) {
      throw StateError('/barcode returned an empty response body');
    }
    return CatalogMetadataDto.fromJson(_client._resolveImageUrls(data));
  }
}

class _FallbackTypedDto extends CatalogTypedDto {
  _FallbackTypedDto(super.raw)
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
