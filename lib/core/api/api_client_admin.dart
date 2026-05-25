part of 'api_client.dart';

class _AdminApiClient {
  _AdminApiClient(this._client);

  final ApiClient _client;

  Future<List<AdminProviderStatus>> adminProviderStatuses() async {
    final response = await _client._dio.get<dynamic>('/admin/providers');
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
      '/admin/catalog/summary',
    );
    final data = response.data;
    if (data == null) {
      throw StateError('/admin/catalog/summary returned an empty response body');
    }
    return AdminCatalogSummary.fromJson(data);
  }

  Future<List<AdminMetadataItem>> adminCatalogItems({
    String? query,
    String? kind,
    int limit = 25,
  }) async {
    final response = await _client._dio.get<List<dynamic>>(
      '/admin/catalog/items',
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

  Future<AdminMetadataItem> adminUpdateCatalogItem({
    required String kind,
    required String id,
    String? title,
    String? itemNumber,
    String? synopsis,
    String? editionTitle,
    int? pageCount,
    int? runtimeMinutes,
    String? publisher,
    DateTime? releaseDate,
    String? imprint,
    String? subtitle,
    String? seriesGroup,
    String? country,
    String? language,
    String? ageRating,
    String? catalogNumber,
    String? releaseStatus,
    String? physicalFormat,
    String? variantName,
    String? barcode,
    String? coverImageUrl,
    String? thumbnailImageUrl,
    bool includeNulls = false,
    Set<String> explicitFields = const <String>{},
  }) async {
    final data = <String, dynamic>{
      if (explicitFields.contains('title') || includeNulls || title != null)
        'title': title,
      if (explicitFields.contains('item_number') || includeNulls || itemNumber != null)
        'item_number': itemNumber,
      if (explicitFields.contains('synopsis') || includeNulls || synopsis != null)
        'synopsis': synopsis,
      if (explicitFields.contains('edition_title') || includeNulls || editionTitle != null)
        'edition_title': editionTitle,
      if (explicitFields.contains('page_count') || includeNulls || pageCount != null)
        'page_count': pageCount,
      if (explicitFields.contains('runtime_minutes') || includeNulls || runtimeMinutes != null)
        'runtime_minutes': runtimeMinutes,
      if (explicitFields.contains('publisher') || includeNulls || publisher != null)
        'publisher': publisher,
      if (explicitFields.contains('release_date') || includeNulls || releaseDate != null)
        'release_date': releaseDate == null ? null : _dateForApi(releaseDate.toUtc()),
      if (explicitFields.contains('imprint') || includeNulls || imprint != null)
        'imprint': imprint,
      if (explicitFields.contains('subtitle') || includeNulls || subtitle != null)
        'subtitle': subtitle,
      if (explicitFields.contains('series_group') || includeNulls || seriesGroup != null)
        'series_group': seriesGroup,
      if (explicitFields.contains('country') || includeNulls || country != null)
        'country': country,
      if (explicitFields.contains('language') || includeNulls || language != null)
        'language': language,
      if (explicitFields.contains('age_rating') || includeNulls || ageRating != null)
        'age_rating': ageRating,
      if (explicitFields.contains('catalog_number') || includeNulls || catalogNumber != null)
        'catalog_number': catalogNumber,
      if (explicitFields.contains('release_status') || includeNulls || releaseStatus != null)
        'release_status': releaseStatus,
      if (physicalFormat != null) 'physical_format': physicalFormat,
      if (explicitFields.contains('variant_name') || includeNulls || variantName != null)
        'variant_name': variantName,
      if (explicitFields.contains('barcode') || includeNulls || barcode != null)
        'barcode': barcode,
      if (explicitFields.contains('cover_image_url') || includeNulls || coverImageUrl != null)
        'cover_image_url': coverImageUrl,
      if (explicitFields.contains('thumbnail_image_url') || includeNulls || thumbnailImageUrl != null)
        'thumbnail_image_url': thumbnailImageUrl,
    };
    final response = await _client._dio.patch<Map<String, dynamic>>(
      '/admin/catalog/items/$kind/$id',
      data: data,
    );
    final body = response.data;
    if (body == null) {
      throw StateError('/admin/catalog/items/$kind/$id returned an empty response body');
    }
    return AdminMetadataItem.fromJson(_client._resolveImageUrls(body));
  }

  Future<Map<String, dynamic>> adminUpdateSeriesTags({
    required String seriesId,
    required List<String> tags,
  }) async {
    final response = await _client._dio.patch<Map<String, dynamic>>(
      '/admin/catalog/series/$seriesId/tags',
      data: {'tags': tags},
    );
    final body = response.data;
    if (body == null) {
      throw StateError('/admin/catalog/series/$seriesId/tags returned an empty response body');
    }
    return body;
  }

  Future<BundleReleaseDetail> adminUpdateBundleRelease({
    required String bundleReleaseId,
    required AdminBundleReleaseCorrection correction,
  }) async {
    final response = await _client._dio.patch<Map<String, dynamic>>(
      '/admin/catalog/bundle-releases/$bundleReleaseId',
      data: correction.toJson(),
    );
    final body = response.data;
    if (body == null) {
      throw StateError('/admin/catalog/bundle-releases/$bundleReleaseId returned an empty response body');
    }
    return BundleReleaseDetail.fromJson(_client._resolveImageUrls(body));
  }

  Future<AdminSearchStatus> adminSearchStatus() async {
    final response = await _client._dio.get<Map<String, dynamic>>('/admin/search/status');
    final data = response.data;
    if (data == null) {
      throw StateError('/admin/search/status returned an empty response body');
    }
    return AdminSearchStatus.fromJson(data);
  }

  Future<AdminSearchReindexResult> adminReindexSearch() async {
    final response = await _client._dio.post<Map<String, dynamic>>('/admin/search/reindex');
    final data = response.data;
    if (data == null) {
      throw StateError('/admin/search/reindex returned an empty response body');
    }
    return AdminSearchReindexResult.fromJson(data);
  }

  Future<List<AdminSearchHistoryEntry>> adminSearchHistory() async {
    final response = await _client._dio.get<List<dynamic>>('/admin/search/history');
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
      '/admin/audit/logs',
      queryParameters: {
        if (action != null && action.isNotEmpty) 'action': action,
        if (entityType != null && entityType.isNotEmpty) 'entity_type': entityType,
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
      '/admin/duplicates',
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
      '/admin/duplicates/ignore',
      data: {'item_ids': itemIds},
    );
    final data = response.data;
    if (data == null) {
      throw StateError('/admin/duplicates/ignore returned an empty response body');
    }
    return AdminDuplicateActionResult.fromJson(data);
  }

  Future<AdminDuplicateActionResult> adminMergeDuplicateCandidate({
    required String targetItemId,
    required List<String> sourceItemIds,
  }) async {
    final response = await _client._dio.post<Map<String, dynamic>>(
      '/admin/duplicates/merge',
      data: {
        'target_item_id': targetItemId,
        'source_item_ids': sourceItemIds,
      },
    );
    final data = response.data;
    if (data == null) {
      throw StateError('/admin/duplicates/merge returned an empty response body');
    }
    return AdminDuplicateActionResult.fromJson(data);
  }

  Future<AdminMetadataItem> adminGetMetadataItem({
    required String kind,
    required String id,
  }) async {
    final response = await _client._dio.get<Map<String, dynamic>>('/metadata/$kind/$id');
    final data = response.data;
    if (data == null) {
      throw StateError('/metadata/$kind/$id returned an empty response body');
    }
    return AdminMetadataItem.fromJson(_client._resolveImageUrls(data));
  }

  Future<List<Map<String, dynamic>>> adminProviderSearch({
    required String provider,
    required String query,
    String? kind,
  }) async {
    final response = await _client._dio.post<List<dynamic>>(
      '/admin/providers/search',
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

  Future<AdminProviderPreview> adminProviderPreview({
    required String provider,
    required String providerItemId,
  }) async {
    return _client._providerPreview(
      '/admin/providers/preview',
      provider: provider,
      providerItemId: providerItemId,
    );
  }

  /// Batch-hydrate provider item IDs into normalized previews.
  Future<AdminBatchHydrateResult> adminProviderBatchHydrate({
    required String provider,
    required List<String> providerItemIds,
  }) async {
    final response = await _client._dio.post<Map<String, dynamic>>(
      '/admin/providers/batch-hydrate',
      data: {
        'provider': provider,
        'items': [
          for (final id in providerItemIds) {'provider_item_id': id},
        ],
      },
    );
    final data = response.data;
    if (data == null) {
      throw StateError('batch-hydrate returned an empty response body');
    }
    return AdminBatchHydrateResult.fromJson(data);
  }

  Future<AdminProviderIngestResult> adminProviderIngest({
    required String provider,
    required String providerItemId,
    String? kind,
  }) async {
    final response = await _client._dio.post<Map<String, dynamic>>(
      '/admin/providers/ingest',
      data: {
        'provider': provider,
        'provider_item_id': providerItemId,
        if (kind != null && kind.isNotEmpty) 'kind': kind,
      },
    );
    final data = response.data;
    if (data == null) {
      throw StateError('/admin/providers/ingest returned an empty response body');
    }
    return AdminProviderIngestResult.fromJson(data);
  }

  Future<AdminMetadataProposalSummary> adminMetadataProposalSummary() async {
    final response = await _client._dio.get<Map<String, dynamic>>(
      '/admin/metadata/proposals/summary',
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
        '/admin/metadata/proposals/summary returned an empty response body',
      );
    }
    return AdminMetadataProposalSummary.fromJson(data);
  }

  Future<List<AdminMetadataProposal>> adminMetadataProposals({
    String status = 'pending',
    String? provider,
  }) async {
    final response = await _client._dio.get<List<dynamic>>(
      '/admin/metadata/proposals',
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
      '/admin/metadata/proposals/$proposalId/approve',
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
        '/admin/metadata/proposals/$proposalId/approve returned an empty response body',
      );
    }
    return AdminProviderIngestResult.fromJson(data);
  }

  Future<AdminProviderIngestResult>
      adminApproveMetadataProposalWithProviderItem({
    required String proposalId,
    required String provider,
    required String providerItemId,
    String? kind,
  }) async {
    final response = await _client._dio.post<Map<String, dynamic>>(
      '/admin/metadata/proposals/$proposalId/approve-provider',
      data: {
        'provider': provider,
        'provider_item_id': providerItemId,
        if (kind != null && kind.isNotEmpty) 'kind': kind,
      },
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
        '/admin/metadata/proposals/$proposalId/approve-provider returned an empty response body',
      );
    }
    return AdminProviderIngestResult.fromJson(data);
  }

  Future<AdminMetadataProposal> adminRejectMetadataProposal({
    required String proposalId,
  }) async {
    final response = await _client._dio.post<Map<String, dynamic>>(
      '/admin/metadata/proposals/$proposalId/reject',
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
        '/admin/metadata/proposals/$proposalId/reject returned an empty response body',
      );
    }
    return AdminMetadataProposal.fromJson(_client._resolveImageUrls(data));
  }

  Future<List<AdminProviderIngestHistoryEntry>> adminProviderIngestHistory() async {
    final response = await _client._dio.get<List<dynamic>>('/admin/providers/ingest/history');
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
      '/admin/providers/ingest/retry',
      data: {'history_id': historyId},
    );
    final data = response.data;
    if (data == null) {
      throw StateError('/admin/providers/ingest/retry returned an empty response body');
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
      '/admin/providers/ingest/jobs',
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
      '/admin/providers/ingest/jobs/summary',
    );
    final data = response.data;
    if (data == null) {
      throw StateError('/admin/providers/ingest/jobs/summary returned an empty response body');
    }
    return AdminProviderIngestJobSummary.fromJson(data);
  }

  Future<AdminProviderIngestJob> adminCreateProviderIngestJob({
    required String provider,
    required String providerItemId,
    int maxAttempts = 3,
  }) async {
    final response = await _client._dio.post<Map<String, dynamic>>(
      '/admin/providers/ingest/jobs',
      data: {
        'provider': provider,
        'provider_item_id': providerItemId,
        'max_attempts': maxAttempts,
      },
    );
    final data = response.data;
    if (data == null) {
      throw StateError('/admin/providers/ingest/jobs returned an empty response body');
    }
    return AdminProviderIngestJob.fromJson(data);
  }

  Future<AdminProviderIngestJobRunResult> adminRunPendingProviderIngestJobs({
    int limit = 5,
  }) async {
    final response = await _client._dio.post<Map<String, dynamic>>(
      '/admin/providers/ingest/jobs/run-pending',
      queryParameters: {'limit': limit},
    );
    final data = response.data;
    if (data == null) {
      throw StateError('/admin/providers/ingest/jobs/run-pending returned an empty response body');
    }
    return AdminProviderIngestJobRunResult.fromJson(data);
  }

  Future<AdminProviderIngestJob> adminRunProviderIngestJob({
    required String jobId,
  }) async {
    final response = await _client._dio.post<Map<String, dynamic>>(
      '/admin/providers/ingest/jobs/$jobId/run',
    );
    final data = response.data;
    if (data == null) {
      throw StateError('/admin/providers/ingest/jobs/$jobId/run returned an empty response body');
    }
    return AdminProviderIngestJob.fromJson(data);
  }

  Future<AdminProviderIngestJob> adminRetryProviderIngestJob({
    required String jobId,
  }) async {
    final response = await _client._dio.post<Map<String, dynamic>>(
      '/admin/providers/ingest/jobs/$jobId/retry',
    );
    final data = response.data;
    if (data == null) {
      throw StateError('/admin/providers/ingest/jobs/$jobId/retry returned an empty response body');
    }
    return AdminProviderIngestJob.fromJson(data);
  }
}