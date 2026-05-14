import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/models/metadata_search_query.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  ApiClient({String baseUrl = 'http://localhost:8010'})
      : _dio = Dio(BaseOptions(baseUrl: baseUrl));

  final Dio _dio;

  String get baseUrl => _dio.options.baseUrl;

  @visibleForTesting
  String? get authorizationHeader =>
      _dio.options.headers['Authorization'] as String?;

  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearToken() {
    _dio.options.headers.remove('Authorization');
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        'display_name': displayName,
      },
    );
    final data = response.data!;
    setToken(data['access_token'] as String);
    return data;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
    final data = response.data!;
    setToken(data['access_token'] as String);
    return data;
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
    MetadataSearchQuery query,
  ) async {
    final response = await _dio.get<List<dynamic>>(
      '/search',
      queryParameters: query.toQueryParameters(),
    );
    return response.data!.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> searchProvider({
    required String provider,
    required String query,
    String? kind,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/metadata/providers/$provider/search',
      queryParameters: {
        'q': query,
        if (kind != null) 'kind': kind,
      },
    );
    final data = response.data;
    if (data == null) {
      return const [];
    }
    return data.cast<Map<String, dynamic>>();
  }

  Future<List<AdminProviderStatus>> adminProviderStatuses() async {
    final response = await _dio.get<List<dynamic>>('/admin/providers');
    final data = response.data;
    if (data == null) {
      return const [];
    }
    return data
        .cast<Map<String, dynamic>>()
        .map(AdminProviderStatus.fromJson)
        .toList(growable: false);
  }

  Future<AdminCatalogSummary> adminCatalogSummary() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/admin/catalog/summary',
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
          '/admin/catalog/summary returned an empty response body');
    }
    return AdminCatalogSummary.fromJson(data);
  }

  Future<List<AdminMetadataItem>> adminCatalogItems({
    String? query,
    String? kind,
    int limit = 25,
  }) async {
    final response = await _dio.get<List<dynamic>>(
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
        .map(AdminMetadataItem.fromJson)
        .toList(growable: false);
  }

  Future<AdminMetadataItem> adminUpdateCatalogItem({
    required String kind,
    required String id,
    String? title,
    String? itemNumber,
    String? synopsis,
    int? pageCount,
    String? publisher,
    DateTime? releaseDate,
    String? variantName,
    String? barcode,
    String? coverImageUrl,
    String? thumbnailImageUrl,
  }) async {
    final data = <String, dynamic>{
      if (title != null) 'title': title,
      if (itemNumber != null) 'item_number': itemNumber,
      if (synopsis != null) 'synopsis': synopsis,
      if (pageCount != null) 'page_count': pageCount,
      if (publisher != null) 'publisher': publisher,
      if (releaseDate != null) 'release_date': _dateForApi(releaseDate.toUtc()),
      if (variantName != null) 'variant_name': variantName,
      if (barcode != null) 'barcode': barcode,
      if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      if (thumbnailImageUrl != null) 'thumbnail_image_url': thumbnailImageUrl,
    };
    final response = await _dio.patch<Map<String, dynamic>>(
      '/admin/catalog/items/$kind/$id',
      data: data,
    );
    final body = response.data;
    if (body == null) {
      throw StateError(
          '/admin/catalog/items/$kind/$id returned an empty response body');
    }
    return AdminMetadataItem.fromJson(body);
  }

  Future<AdminSearchStatus> adminSearchStatus() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/admin/search/status',
    );
    final data = response.data;
    if (data == null) {
      throw StateError('/admin/search/status returned an empty response body');
    }
    return AdminSearchStatus.fromJson(data);
  }

  Future<AdminSearchReindexResult> adminReindexSearch() async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/admin/search/reindex',
    );
    final data = response.data;
    if (data == null) {
      throw StateError('/admin/search/reindex returned an empty response body');
    }
    return AdminSearchReindexResult.fromJson(data);
  }

  Future<List<AdminSearchHistoryEntry>> adminSearchHistory() async {
    final response = await _dio.get<List<dynamic>>(
      '/admin/search/history',
    );
    final data = response.data;
    if (data == null) {
      return const [];
    }
    return data
        .cast<Map<String, dynamic>>()
        .map(AdminSearchHistoryEntry.fromJson)
        .toList(growable: false);
  }

  Future<List<AdminDuplicateCandidate>> adminDuplicateCandidates({
    int limit = 10,
  }) async {
    final response = await _dio.get<List<dynamic>>(
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
    final response = await _dio.post<Map<String, dynamic>>(
      '/admin/duplicates/ignore',
      data: {'item_ids': itemIds},
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
          '/admin/duplicates/ignore returned an empty response body');
    }
    return AdminDuplicateActionResult.fromJson(data);
  }

  Future<AdminDuplicateActionResult> adminMergeDuplicateCandidate({
    required String targetItemId,
    required List<String> sourceItemIds,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/admin/duplicates/merge',
      data: {
        'target_item_id': targetItemId,
        'source_item_ids': sourceItemIds,
      },
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
          '/admin/duplicates/merge returned an empty response body');
    }
    return AdminDuplicateActionResult.fromJson(data);
  }

  Future<AdminMetadataItem> adminGetMetadataItem({
    required String kind,
    required String id,
  }) async {
    final route = _metadataRouteForKind(kind);
    final response = await _dio.get<Map<String, dynamic>>(
      '/metadata/$route/$id',
    );
    final data = response.data;
    if (data == null) {
      throw StateError('/metadata/$route/$id returned an empty response body');
    }
    return AdminMetadataItem.fromJson(data);
  }

  Future<List<Map<String, dynamic>>> adminProviderSearch({
    required String provider,
    required String query,
    String? kind,
  }) async {
    final response = await _dio.post<List<dynamic>>(
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
    return data.cast<Map<String, dynamic>>();
  }

  Future<AdminProviderIngestResult> adminProviderIngest({
    required String provider,
    required String providerItemId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/admin/providers/ingest',
      data: {
        'provider': provider,
        'provider_item_id': providerItemId,
      },
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
          '/admin/providers/ingest returned an empty response body');
    }
    return AdminProviderIngestResult.fromJson(data);
  }

  Future<List<AdminProviderIngestHistoryEntry>>
      adminProviderIngestHistory() async {
    final response = await _dio.get<List<dynamic>>(
      '/admin/providers/ingest/history',
    );
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
    final response = await _dio.post<Map<String, dynamic>>(
      '/admin/providers/ingest/retry',
      data: {'history_id': historyId},
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
          '/admin/providers/ingest/retry returned an empty response body');
    }
    return AdminProviderIngestResult.fromJson(data);
  }

  Future<List<AdminProviderIngestJob>> adminProviderIngestJobs({
    String? status,
    int limit = 25,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/admin/providers/ingest/jobs',
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
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

  Future<AdminProviderIngestJob> adminCreateProviderIngestJob({
    required String provider,
    required String providerItemId,
    int maxAttempts = 3,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/admin/providers/ingest/jobs',
      data: {
        'provider': provider,
        'provider_item_id': providerItemId,
        'max_attempts': maxAttempts,
      },
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
          '/admin/providers/ingest/jobs returned an empty response body');
    }
    return AdminProviderIngestJob.fromJson(data);
  }

  Future<AdminProviderIngestJobRunResult> adminRunPendingProviderIngestJobs({
    int limit = 5,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/admin/providers/ingest/jobs/run-pending',
      queryParameters: {'limit': limit},
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
          '/admin/providers/ingest/jobs/run-pending returned an empty response body');
    }
    return AdminProviderIngestJobRunResult.fromJson(data);
  }

  Future<AdminProviderIngestJob> adminRunProviderIngestJob({
    required String jobId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/admin/providers/ingest/jobs/$jobId/run',
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
          '/admin/providers/ingest/jobs/$jobId/run returned an empty response body');
    }
    return AdminProviderIngestJob.fromJson(data);
  }

  Future<AdminProviderIngestJob> adminRetryProviderIngestJob({
    required String jobId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/admin/providers/ingest/jobs/$jobId/retry',
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
          '/admin/providers/ingest/jobs/$jobId/retry returned an empty response body');
    }
    return AdminProviderIngestJob.fromJson(data);
  }

  Future<Map<String, dynamic>> createMetadataProposal({
    required String provider,
    required String query,
    String? providerItemId,
    String? title,
    String? summary,
    String? imageUrl,
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
      },
    );
    final data = response.data;
    if (data == null) {
      throw StateError('/metadata/proposals returned an empty response body');
    }
    return data;
  }

  Future<Map<String, dynamic>> getComic(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/comics/$id');
    return response.data!;
  }

  Future<Map<String, dynamic>> lookupBarcode(String barcode,
      {String? kind}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/barcode/${Uri.encodeComponent(MetadataSearchQuery.normalizeBarcode(barcode))}',
      queryParameters: {
        if (kind != null) 'kind': kind,
      },
    );
    final data = response.data;
    if (data == null) {
      throw StateError('/barcode returned an empty response body');
    }
    return data;
  }

  Future<Map<String, dynamic>> health() async {
    final response = await _dio.get<Map<String, dynamic>>('/health');
    final data = response.data;
    if (data == null) {
      throw StateError('/health returned an empty response body');
    }
    return data;
  }
}

String _metadataRouteForKind(String kind) {
  return switch (kind) {
    'comic' => 'comics',
    'game' => 'games',
    'bluray' => 'blu-ray',
    'movie' => 'movies',
    'book' => 'books',
    'boardgame' => 'board-games',
    _ => kind,
  };
}

String _dateForApi(DateTime value) {
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
