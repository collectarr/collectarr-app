part of 'api_client.dart';

class _AdminApiClient {
  _AdminApiClient(this._client);

  final ApiClient _client;

  Future<AdminCatalogSummary> adminCatalogSummary() async {
    final response = await _client._dio.get<Map<String, dynamic>>(
      '/api/v1/admin/catalog/summary',
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
          '/api/v1/admin/catalog/summary returned an empty response body');
    }
    return AdminCatalogSummary.fromJson(data);
  }

  Future<AdminCatalogItemIntegrityReport> adminCatalogItemIntegrity(
      {int sampleLimit = 100}) async {
    final response = await _client._dio.get<Map<String, dynamic>>(
      '/api/v1/admin/catalog/item-integrity',
      queryParameters: {'sample_limit': sampleLimit},
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
          '/api/v1/admin/catalog/item-integrity returned an empty response body');
    }
    return AdminCatalogItemIntegrityReport.fromJson(data);
  }

  Future<List<AdminMetadataItem>> adminCatalogItems({
    String? query,
    String? kind,
    int limit = 25,
  }) async {
    final items = await _client.searchCatalogItems(
      kind: kind == null || kind.isEmpty
          ? null
          : catalogMediaKindFromApiValue(kind),
      query: query,
      limit: limit,
    );
    return [
      for (final item in items)
        AdminMetadataItem.fromJson(_client._resolveImageUrls(item.toJson())),
    ];
  }

  Future<AdminMetadataItem> adminUpdateCatalogItemFields({
    required String kind,
    required String id,
    required Map<String, Object?> fields,
  }) async {
    final reference = CatalogItemRef(
      kind: catalogMediaKindFromApiValue(kind),
      id: id,
    );
    final current = await _client.getCatalogItem(reference);
    final details = Map<String, dynamic>.from(current.details.toJson());
    if (kind == 'music' && details['tracks'] is List) {
      details['tracks'] = [
        for (final track in details['tracks'] as List<dynamic>)
          if (track is Map)
            Map<String, dynamic>.from(track)..remove('album_id'),
      ];
    }
    for (final entry in fields.entries) {
      final value = _jsonSafeCatalogCorrectionValue(entry.value);
      if (entry.key == 'cover_image_url' ||
          entry.key == 'thumbnail_image_url') {
        final imageType =
            entry.key == 'cover_image_url' ? 'front_cover' : 'thumbnail';
        if (details.containsKey(entry.key)) {
          details[entry.key] = value;
        } else if (details['images'] is List) {
          _setCatalogImage(details, imageType, value);
        } else {
          throw StateError(
            'Catalog Item kind "$kind" does not support ${entry.key}.',
          );
        }
        continue;
      }
      if (!details.containsKey(entry.key)) {
        throw StateError(
          'Catalog Item kind "$kind" does not support ${entry.key}.',
        );
      }
      details[entry.key] = value;
    }
    final updated = await _client.updateCatalogItem(
      reference,
      CatalogItemWriteV1Dto(
        details: catalogItemWriteDetailsFromJson(details),
      ),
    );
    return AdminMetadataItem.fromJson(
      _client._resolveImageUrls({
        'id': updated.id,
        'kind': updated.kind,
        ...updated.details.toJson(),
      }),
    );
  }

  void _setCatalogImage(
    Map<String, dynamic> details,
    String imageType,
    Object? url,
  ) {
    final images = [
      for (final image in details['images'] as List<dynamic>)
        if (image is Map) Map<String, dynamic>.from(image),
    ];
    final existingIndex = images.indexWhere(
      (image) => image['image_type'] == imageType,
    );
    if (existingIndex >= 0) {
      images[existingIndex]['url'] = url;
    } else {
      images.add({
        'image_type': imageType,
        'url': url,
        'position': images.length,
      });
    }
    details['images'] = images;
  }

  Object? _jsonSafeCatalogCorrectionValue(Object? value) {
    if (value is DateTime) return value.toUtc().toIso8601String();
    if (value is PartialDate) return value.toJson();
    if (value is Map) {
      return <String, Object?>{
        for (final entry in value.entries)
          entry.key.toString(): _jsonSafeCatalogCorrectionValue(entry.value),
      };
    }
    if (value is Iterable) {
      return [
        for (final element in value) _jsonSafeCatalogCorrectionValue(element),
      ];
    }
    return value;
  }

  Future<AdminSearchStatus> adminSearchStatus() async {
    final response = await _client._dio
        .get<Map<String, dynamic>>('/api/v1/admin/search/status');
    final data = response.data;
    if (data == null) {
      throw StateError(
          '/api/v1/admin/search/status returned an empty response body');
    }
    return AdminSearchStatus.fromJson(data);
  }

  Future<AdminSearchReindexResult> adminReindexSearch() async {
    final response = await _client._dio
        .post<Map<String, dynamic>>('/api/v1/admin/search/reindex');
    final data = response.data;
    if (data == null) {
      throw StateError(
          '/api/v1/admin/search/reindex returned an empty response body');
    }
    return AdminSearchReindexResult.fromJson(data);
  }

  Future<List<AdminSearchHistoryEntry>> adminSearchHistory() async {
    final response =
        await _client._dio.get<List<dynamic>>('/api/v1/admin/search/history');
    final data = response.data;
    if (data == null) {
      return const [];
    }
    return data
        .cast<Map<String, dynamic>>()
        .map(AdminSearchHistoryEntry.fromJson)
        .toList(growable: false);
  }

  Future<List<AdminAuditLogEntry>> adminAuditLogs({
    String? action,
    String? entityType,
    String? entityId,
    int limit = 10,
  }) async {
    final response = await _client._dio.get<List<dynamic>>(
      '/api/v1/admin/audit/logs',
      queryParameters: {
        if (action != null && action.isNotEmpty) 'action': action,
        if (entityType != null && entityType.isNotEmpty)
          'entity_type': entityType,
        if (entityId != null && entityId.isNotEmpty) 'entity_id': entityId,
        'limit': limit,
      },
    );
    final data = response.data;
    if (data == null) {
      return const [];
    }
    return data
        .cast<Map<String, dynamic>>()
        .map(AdminAuditLogEntry.fromJson)
        .toList(growable: false);
  }

  Future<List<AdminDuplicateCandidate>> adminDuplicateCandidates({
    int limit = 10,
  }) async {
    final response = await _client._dio.get<List<dynamic>>(
      '/api/v1/admin/duplicates',
      queryParameters: {'limit': limit},
    );
    final data = response.data;
    if (data == null) {
      return const [];
    }
    return data
        .cast<Map<String, dynamic>>()
        .map(AdminDuplicateCandidate.fromJson)
        .toList(growable: false);
  }

  Future<AdminDuplicateActionResult> adminIgnoreDuplicateCandidate({
    required List<String> itemIds,
  }) async {
    final response = await _client._dio.post<Map<String, dynamic>>(
      '/api/v1/admin/duplicates/ignore',
      data: {'item_ids': itemIds},
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
          '/api/v1/admin/duplicates/ignore returned an empty response body');
    }
    return AdminDuplicateActionResult.fromJson(data);
  }

  Future<AdminMetadataItem> adminGetMetadataItem({
    required String kind,
    required String id,
  }) async {
    final item = await _client.getCatalogItem(
      CatalogItemRef(kind: catalogMediaKindFromApiValue(kind), id: id),
    );
    return AdminMetadataItem.fromJson(
      _client._resolveImageUrls({
        'id': item.id,
        'kind': item.kind,
        ...item.details.toJson(),
      }),
    );
  }

  Future<AdminProviderIngestResult> adminProviderIngest({
    required String provider,
    required String providerItemId,
    String? kind,
  }) async {
    final response = await _client._dio.post<Map<String, dynamic>>(
      '/api/v1/admin/providers/ingest',
      data: {
        'provider': provider,
        'provider_item_id': providerItemId,
        if (kind != null && kind.isNotEmpty) 'kind': kind,
      },
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
          '/api/v1/admin/providers/ingest returned an empty response body');
    }
    return AdminProviderIngestResult.fromJson(data);
  }

  Future<AdminProviderIngestJob> adminCreateProviderIngestJob({
    required String provider,
    required String providerItemId,
    int maxAttempts = 3,
  }) async {
    final response = await _client._dio.post<Map<String, dynamic>>(
      '/api/v1/admin/providers/ingest/jobs',
      data: {
        'provider': provider,
        'provider_item_id': providerItemId,
        'max_attempts': maxAttempts,
      },
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
          '/api/v1/admin/providers/ingest/jobs returned an empty response body');
    }
    return AdminProviderIngestJob.fromJson(data);
  }

}
