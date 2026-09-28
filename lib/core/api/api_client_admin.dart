part of 'api_client.dart';

class _AdminApiClient {
  _AdminApiClient(this._client);

  final ApiClient _client;

  Future<List<AdminProviderStatus>> adminProviderStatuses() async {
    final response = await _client._dio.get<dynamic>('/api/v1/admin/providers');
    final data = response.data;
    if (data == null) {
      return const [];
    }
    final rows = data is List<dynamic>
        ? data
        : data is Map<String, dynamic>
            ? data['providers'] as List<dynamic>? ?? const []
            : const <dynamic>[];
    return rows
        .cast<Map<String, dynamic>>()
        .map(AdminProviderStatus.fromJson)
        .toList(growable: false);
  }

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

  Future<List<Map<String, dynamic>>> adminProviderSearch({
    required String provider,
    required String query,
    String? kind,
  }) async {
    final response = await _client._dio.post<List<dynamic>>(
      '/api/v1/admin/providers/search',
      data: {
        'provider': provider,
        'query': query,
        if (kind != null) 'kind': kind,
      },
    );
    final data = response.data;
    if (data == null) {
      return const [];
    }
    return data
        .cast<Map<String, dynamic>>()
        .map(_client._resolveImageUrls)
        .toList(growable: false);
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

  Future<List<AdminReleaseMediaMappingRule>> adminReleaseMediaMappingRules({
    String? provider,
    bool? active,
  }) async {
    final response = await _client._dio.get<List<dynamic>>(
      '/api/v1/admin/metadata/mapping-rules',
      queryParameters: {
        if (provider != null && provider.isNotEmpty) 'provider': provider,
        if (active != null) 'active': active,
      },
    );
    final data = response.data;
    if (data == null) {
      return const [];
    }
    return data
        .cast<Map<String, dynamic>>()
        .map(AdminReleaseMediaMappingRule.fromJson)
        .toList(growable: false);
  }

  Future<AdminReleaseMediaMappingRule> adminCreateReleaseMediaMappingRule({
    required AdminReleaseMediaMappingRuleUpsert payload,
  }) async {
    final response = await _client._dio.post<Map<String, dynamic>>(
      '/api/v1/admin/metadata/mapping-rules',
      data: payload.toJson(),
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
          '/api/v1/admin/metadata/mapping-rules returned an empty response body');
    }
    return AdminReleaseMediaMappingRule.fromJson(data);
  }

  Future<AdminReleaseMediaMappingRule> adminUpdateReleaseMediaMappingRule({
    required String ruleId,
    required AdminReleaseMediaMappingRuleUpsert payload,
  }) async {
    final response = await _client._dio.patch<Map<String, dynamic>>(
      '/api/v1/admin/metadata/mapping-rules/$ruleId',
      data: payload.toJson(),
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
        '/api/v1/admin/metadata/mapping-rules/$ruleId returned an empty response body',
      );
    }
    return AdminReleaseMediaMappingRule.fromJson(data);
  }

  Future<void> adminDeleteReleaseMediaMappingRule({
    required String ruleId,
  }) async {
    await _client._dio.delete<Map<String, dynamic>>(
      '/api/v1/admin/metadata/mapping-rules/$ruleId',
    );
  }

  Future<AdminProviderPrefillResolved> adminResolveProviderPrefill({
    required String source,
    String? provider,
    String? kind,
    String? query,
    String? providerItemId,
    String? releaseType,
    String? proposalId,
    int? ingestHistoryId,
  }) async {
    final response = await _client._dio.post<Map<String, dynamic>>(
      '/api/v1/admin/providers/prefill/resolve',
      data: {
        'source': source,
        if (provider != null && provider.isNotEmpty) 'provider': provider,
        if (kind != null && kind.isNotEmpty) 'kind': kind,
        if (query != null && query.trim().isNotEmpty) 'query': query.trim(),
        if (providerItemId != null && providerItemId.trim().isNotEmpty)
          'provider_item_id': providerItemId.trim(),
        if (releaseType != null && releaseType.trim().isNotEmpty)
          'release_type': releaseType.trim(),
        if (proposalId != null && proposalId.isNotEmpty)
          'proposal_id': proposalId,
        if (ingestHistoryId != null) 'ingest_history_id': ingestHistoryId,
      },
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
          '/api/v1/admin/providers/prefill/resolve returned an empty response body');
    }
    return AdminProviderPrefillResolved.fromJson(data);
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
    String? provider,
  }) async {
    final response = await _client._dio.get<List<dynamic>>(
      '/api/v1/admin/metadata/proposals',
      queryParameters: {
        'status': status,
        if (provider != null && provider.isNotEmpty) 'provider': provider,
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

  Future<AdminProviderIngestResult> adminApproveMetadataProposal({
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
    return AdminProviderIngestResult.fromJson(data);
  }

  Future<AdminMetadataProposal> adminUpdateMetadataProposal({
    required String proposalId,
    String? query,
    String? providerItemId,
    String? title,
    String? summary,
    String? imageUrl,
    Map<String, dynamic>? metadataPayload,
  }) async {
    final response = await _client._dio.patch<Map<String, dynamic>>(
      '/api/v1/admin/metadata/proposals/$proposalId',
      data: {
        if (query != null) 'query': query,
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
        '/api/v1/admin/metadata/proposals/$proposalId returned an empty response body',
      );
    }
    return AdminMetadataProposal.fromJson(_client._resolveImageUrls(data));
  }

  Future<AdminProviderIngestResult>
      adminApproveMetadataProposalWithProviderItem({
    required String proposalId,
    required String provider,
    required String providerItemId,
    String? kind,
  }) async {
    final response = await _client._dio.post<Map<String, dynamic>>(
      '/api/v1/admin/metadata/proposals/$proposalId/approve-provider',
      data: {
        'provider': provider,
        'provider_item_id': providerItemId,
        if (kind != null && kind.isNotEmpty) 'kind': kind,
      },
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
        '/api/v1/admin/metadata/proposals/$proposalId/approve-provider returned an empty response body',
      );
    }
    return AdminProviderIngestResult.fromJson(data);
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

  Future<List<AdminProviderIngestHistoryEntry>>
      adminProviderIngestHistory() async {
    final response = await _client._dio
        .get<List<dynamic>>('/api/v1/admin/providers/ingest/history');
    final data = response.data;
    if (data == null) {
      return const [];
    }
    return data
        .cast<Map<String, dynamic>>()
        .map(AdminProviderIngestHistoryEntry.fromJson)
        .toList(growable: false);
  }

  Future<AdminProviderIngestResult> adminRetryProviderIngest({
    required int historyId,
  }) async {
    final response = await _client._dio.post<Map<String, dynamic>>(
      '/api/v1/admin/providers/ingest/retry',
      data: {'history_id': historyId},
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
          '/api/v1/admin/providers/ingest/retry returned an empty response body');
    }
    return AdminProviderIngestResult.fromJson(data);
  }

  Future<List<AdminProviderIngestJob>> adminProviderIngestJobs({
    String? status,
    String? provider,
    String? query,
    int limit = 25,
  }) async {
    final response = await _client._dio.get<List<dynamic>>(
      '/api/v1/admin/providers/ingest/jobs',
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
        if (provider != null && provider.isNotEmpty) 'provider': provider,
        if (query != null && query.isNotEmpty) 'q': query,
        'limit': limit,
      },
    );
    final data = response.data;
    if (data == null) {
      return const [];
    }
    return data
        .cast<Map<String, dynamic>>()
        .map(AdminProviderIngestJob.fromJson)
        .toList(growable: false);
  }

  Future<AdminProviderIngestJobSummary> adminProviderIngestJobSummary() async {
    final response = await _client._dio.get<Map<String, dynamic>>(
      '/api/v1/admin/providers/ingest/jobs/summary',
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
          '/api/v1/admin/providers/ingest/jobs/summary returned an empty response body');
    }
    return AdminProviderIngestJobSummary.fromJson(data);
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

  Future<AdminProviderIngestJobRunResult> adminRunPendingProviderIngestJobs({
    int limit = 5,
  }) async {
    final response = await _client._dio.post<Map<String, dynamic>>(
      '/api/v1/admin/providers/ingest/jobs/run-pending',
      queryParameters: {'limit': limit},
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
          '/api/v1/admin/providers/ingest/jobs/run-pending returned an empty response body');
    }
    return AdminProviderIngestJobRunResult.fromJson(data);
  }

  Future<AdminProviderIngestJob> adminRunProviderIngestJob({
    required String jobId,
  }) async {
    final response = await _client._dio.post<Map<String, dynamic>>(
      '/api/v1/admin/providers/ingest/jobs/$jobId/run',
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
          '/api/v1/admin/providers/ingest/jobs/$jobId/run returned an empty response body');
    }
    return AdminProviderIngestJob.fromJson(data);
  }

  Future<AdminProviderIngestJob> adminRetryProviderIngestJob({
    required String jobId,
  }) async {
    final response = await _client._dio.post<Map<String, dynamic>>(
      '/api/v1/admin/providers/ingest/jobs/$jobId/retry',
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
          '/api/v1/admin/providers/ingest/jobs/$jobId/retry returned an empty response body');
    }
    return AdminProviderIngestJob.fromJson(data);
  }
}
