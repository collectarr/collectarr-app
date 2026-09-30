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

  Future<AdminNormalizedMetadataDriftReport> adminNormalizedMetadataDrift(
      {int sampleLimit = 100}) async {
    final response = await _client._dio.get<Map<String, dynamic>>(
      '/api/v1/admin/catalog/normalized-metadata-drift',
      queryParameters: {'sample_limit': sampleLimit},
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
          '/api/v1/admin/catalog/normalized-metadata-drift returned an empty response body');
    }
    return AdminNormalizedMetadataDriftReport.fromJson(data);
  }

  Future<List<AdminMetadataItem>> adminCatalogItems({
    String? query,
    String? kind,
    int limit = 25,
  }) async {
    final response = await _client._dio.get<List<dynamic>>(
      '/api/v1/admin/catalog/items',
      queryParameters: {
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        if (kind != null && kind.isNotEmpty) 'kind': kind,
        'limit': limit,
      },
    );
    final data = response.data;
    if (data == null) {
      return const [];
    }
    return data
        .cast<Map<String, dynamic>>()
        .map(_client._resolveImageUrls)
        .map(AdminMetadataItem.fromJson)
        .toList(growable: false);
  }

  Future<AdminMetadataItem> adminUpdateCatalogItemFields({
    required String kind,
    required String id,
    required Map<String, Object?> fields,
  }) async {
    final response = await _client._dio.patch<Map<String, dynamic>>(
      '/api/v1/admin/catalog/items/$kind/$id',
      data: {
        for (final entry in fields.entries)
          entry.key: _jsonSafeCatalogCorrectionValue(entry.value),
      },
    );
    final body = response.data;
    if (body == null) {
      throw StateError(
          '/api/v1/admin/catalog/items/$kind/$id returned an empty response body');
    }
    return AdminMetadataItem.fromJson(_client._resolveImageUrls(body));
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

  Future<Map<String, dynamic>> adminUpdateSeriesFields({
    required String seriesId,
    required Map<String, Object?> fields,
  }) async {
    final response = await _client._dio.patch<Map<String, dynamic>>(
      '/api/v1/admin/catalog/series/$seriesId/tags',
      data: {
        for (final entry in fields.entries)
          entry.key: _jsonSafeCatalogCorrectionValue(entry.value),
      },
    );
    final body = response.data;
    if (body == null) {
      throw StateError(
          '/api/v1/admin/catalog/series/$seriesId/tags returned an empty response body');
    }
    return body;
  }

  Future<BundleReleaseDetail> adminUpdateBundleRelease({
    required String bundleReleaseId,
    required AdminBundleReleaseCorrection correction,
  }) async {
    final response = await _client._dio.patch<Map<String, dynamic>>(
      '/api/v1/admin/catalog/bundle-releases/$bundleReleaseId',
      data: correction.toJson(),
    );
    final body = response.data;
    if (body == null) {
      throw StateError(
          '/api/v1/admin/catalog/bundle-releases/$bundleReleaseId returned an empty response body');
    }
    return BundleReleaseDetail.fromJson(_client._resolveImageUrls(body));
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

  Future<AdminMetadataItem> adminGetMetadataItem({
    required String kind,
    required String id,
  }) async {
    final item = await _client.getCatalogItemJson(
      kind: catalogMediaKindFromApiValue(kind),
      id: id,
    );
    return AdminMetadataItem.fromJson(item);
  }

  Future<AdminMetadataProposalSummary> adminMetadataProposalSummary() async {
    final response = await _client._dio.get<Map<String, dynamic>>(
      '/api/v1/admin/metadata/proposals/summary',
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
        '/api/v1/admin/metadata/proposals/summary returned an empty response body',
      );
    }
    return AdminMetadataProposalSummary.fromJson(data);
  }

  Future<List<AdminMetadataProposal>> adminMetadataProposals({
    String status = 'pending',
  }) async {
    final response = await _client._dio.get<List<dynamic>>(
      '/api/v1/admin/metadata/proposals',
      queryParameters: {
        'status': status,
      },
    );
    final data = response.data;
    if (data == null) {
      return const [];
    }
    return data
        .cast<Map<String, dynamic>>()
        .map(_client._resolveImageUrls)
        .map(AdminMetadataProposal.fromJson)
        .toList(growable: false);
  }

  Future<AdminMetadataProposal> adminApproveMetadataProposal({
    required String proposalId,
  }) async {
    final response = await _client._dio.post<Map<String, dynamic>>(
      '/api/v1/admin/metadata/proposals/$proposalId/approve',
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
        '/api/v1/admin/metadata/proposals/$proposalId/approve returned an empty response body',
      );
    }
    return AdminMetadataProposal.fromJson(data);
  }

  Future<AdminMetadataProposal> adminUpdateMetadataProposal({
    required String proposalId,
    required Map<String, dynamic> catalogItem,
    String? reviewNote,
  }) async {
    final response = await _client._dio.patch<Map<String, dynamic>>(
      '/api/v1/admin/metadata/proposals/$proposalId',
      data: {
        'catalog_item': catalogItem,
        if (reviewNote != null) 'review_note': reviewNote,
      },
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
        '/api/v1/admin/metadata/proposals/$proposalId returned an empty response body',
      );
    }
    return AdminMetadataProposal.fromJson(_client._resolveImageUrls(data));
  }

  Future<AdminMetadataProposal> adminRejectMetadataProposal({
    required String proposalId,
  }) async {
    final response = await _client._dio.post<Map<String, dynamic>>(
      '/api/v1/admin/metadata/proposals/$proposalId/reject',
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
        '/api/v1/admin/metadata/proposals/$proposalId/reject returned an empty response body',
      );
    }
    return AdminMetadataProposal.fromJson(_client._resolveImageUrls(data));
  }
}
