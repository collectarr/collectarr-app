import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/core/models/metadata_search_query.dart';
import 'package:collectarr_app/core/models/season.dart';
import 'package:collectarr_app/core/models/series_relation.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  static const requestTimeout = Duration(seconds: 30);

  ApiClient({String baseUrl = 'http://127.0.0.1:8010'})
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl.trim(),
            connectTimeout: requestTimeout,
            receiveTimeout: requestTimeout,
            sendTimeout: requestTimeout,
          ),
        );

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

  Future<Map<String, dynamic>> currentUser() async {
    final response = await _dio.get<Map<String, dynamic>>('/auth/me');
    final data = response.data;
    if (data == null) {
      throw StateError('/auth/me returned an empty response.');
    }
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
    return response.data!
        .cast<Map<String, dynamic>>()
        .map(_resolveImageUrls)
        .toList(growable: false);
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

  Future<List<Map<String, dynamic>>> searchProvider({
    String? provider,
    required String query,
    String? kind,
    String? series,
    String? issueNumber,
    int? year,
  }) async {
    final providerPath = provider == null || provider.isEmpty
        ? '/metadata/providers/search'
        : '/metadata/providers/$provider/search';
    final response = await _dio.get<List<dynamic>>(
      providerPath,
      queryParameters: {
        'q': query,
        if (kind != null) 'kind': kind,
        if (series != null && series.trim().isNotEmpty) 'series': series.trim(),
        if (issueNumber != null && issueNumber.trim().isNotEmpty)
          'issue_number': issueNumber.trim(),
        if (year != null) 'year': year,
      },
    );
    final data = response.data;
    if (data == null) {
      return const [];
    }
    return data
        .cast<Map<String, dynamic>>()
        .map(_resolveImageUrls)
        .toList(growable: false);
  }

  Future<List<AdminProviderStatus>> adminProviderStatuses() async {
    final response = await _dio.get<dynamic>('/admin/providers');
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
        .map(_resolveImageUrls)
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
    String? physicalFormat,
    String? variantName,
    String? barcode,
    String? coverImageUrl,
    String? thumbnailImageUrl,
    bool includeNulls = false,
  }) async {
    final data = <String, dynamic>{
      if (includeNulls || title != null) 'title': title,
      if (includeNulls || itemNumber != null) 'item_number': itemNumber,
      if (includeNulls || synopsis != null) 'synopsis': synopsis,
      if (includeNulls || pageCount != null) 'page_count': pageCount,
      if (includeNulls || publisher != null) 'publisher': publisher,
      if (includeNulls || releaseDate != null)
        'release_date':
            releaseDate == null ? null : _dateForApi(releaseDate.toUtc()),
      if (physicalFormat != null) 'physical_format': physicalFormat,
      if (includeNulls || variantName != null) 'variant_name': variantName,
      if (includeNulls || barcode != null) 'barcode': barcode,
      if (includeNulls || coverImageUrl != null)
        'cover_image_url': coverImageUrl,
      if (includeNulls || thumbnailImageUrl != null)
        'thumbnail_image_url': thumbnailImageUrl,
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
    return AdminMetadataItem.fromJson(_resolveImageUrls(body));
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

  Future<List<AdminAuditLogEntry>> adminAuditLogs({
    String? action,
    String? entityType,
    String? entityId,
    int limit = 10,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/admin/audit/logs',
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
    final response = await _dio.get<Map<String, dynamic>>(
      '/metadata/$kind/$id',
    );
    final data = response.data;
    if (data == null) {
      throw StateError('/metadata/$kind/$id returned an empty response body');
    }
    return AdminMetadataItem.fromJson(_resolveImageUrls(data));
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
    return data
        .cast<Map<String, dynamic>>()
        .map(_resolveImageUrls)
        .toList(growable: false);
  }

  Future<AdminProviderPreview> adminProviderPreview({
    required String provider,
    required String providerItemId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/admin/providers/preview',
      data: {
        'provider': provider,
        'provider_item_id': providerItemId,
      },
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
          '/admin/providers/preview returned an empty response body');
    }
    return AdminProviderPreview.fromJson(data);
  }

  Future<AdminProviderPreview> providerPreview({
    required String provider,
    required String providerItemId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/metadata/providers/preview',
      data: {
        'provider': provider,
        'provider_item_id': providerItemId,
      },
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
          '/metadata/providers/preview returned an empty response body');
    }
    return AdminProviderPreview.fromJson(data);
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
    String? provider,
    String? query,
    int limit = 25,
  }) async {
    final response = await _dio.get<List<dynamic>>(
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
    final response = await _dio.get<Map<String, dynamic>>(
      '/admin/providers/ingest/jobs/summary',
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
          '/admin/providers/ingest/jobs/summary returned an empty response body');
    }
    return AdminProviderIngestJobSummary.fromJson(data);
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
    final response =
        await _dio.get<Map<String, dynamic>>('/metadata/comic/$id');
    return _resolveImageUrls(response.data!);
  }

  Future<List<SeriesRelation>> getSeriesRelations(String seriesId) async {
    final response = await _dio.get<List<dynamic>>(
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

  Future<List<Season>> getProviderSeasons(
    String provider,
    String providerItemId,
  ) async {
    final response = await _dio.get<List<dynamic>>(
      '/metadata/providers/$provider/seasons/${Uri.encodeComponent(providerItemId)}',
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

  Future<List<Season>> getProviderVolumes(
    String provider,
    String providerItemId,
  ) async {
    final response = await _dio.get<List<dynamic>>(
      '/metadata/providers/$provider/volumes/${Uri.encodeComponent(providerItemId)}',
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

  Future<List<Season>> getItemVolumes(String itemId) async {
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

  Future<List<Map<String, dynamic>>> _fetchList(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
  }) async {
    final response = data != null
        ? await _dio.post<List<dynamic>>(path,
            queryParameters: queryParameters, data: data)
        : await _dio.get<List<dynamic>>(path,
            queryParameters: queryParameters);
    final body = response.data;
    if (body == null) {
      return const [];
    }
    return body
        .cast<Map<String, dynamic>>()
        .map(_resolveImageUrls)
        .toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> searchStoryArcs({
    String? query,
    int limit = 50,
  }) {
    return _fetchList(
      '/story-arcs',
      queryParameters: {
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        'limit': limit,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getStoryArcItems(
      String storyArcId) {
    return _fetchList(
        '/story-arcs/${Uri.encodeComponent(storyArcId)}/items');
  }

  Future<List<Map<String, dynamic>>> storyArcFacets(
    Iterable<String> itemIds,
  ) {
    final ids = itemIds.where((id) => id.trim().isNotEmpty).toSet().toList();
    if (ids.isEmpty) {
      return Future.value(const []);
    }
    return _fetchList('/story-arcs/facets', data: {'item_ids': ids});
  }

  Future<List<Map<String, dynamic>>> searchCreators({
    String? query,
    int limit = 50,
  }) {
    return _fetchList(
      '/creators',
      queryParameters: {
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        'limit': limit,
      },
    );
  }

  Future<List<Map<String, dynamic>>> creatorFacets(
    Iterable<String> itemIds,
  ) {
    final ids = itemIds.where((id) => id.trim().isNotEmpty).toSet().toList();
    if (ids.isEmpty) {
      return Future.value(const []);
    }
    return _fetchList('/creators/facets', data: {'item_ids': ids});
  }

  Future<List<Map<String, dynamic>>> getCreatorCredits(
    String creatorId,
  ) {
    return _fetchList(
      '/creators/${Uri.encodeComponent(creatorId)}/credits',
    );
  }

  Future<List<Map<String, dynamic>>> searchCharacters({
    String? query,
    int limit = 50,
  }) {
    return _fetchList(
      '/characters',
      queryParameters: {
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        'limit': limit,
      },
    );
  }

  Future<List<Map<String, dynamic>>> characterFacets(
    Iterable<String> itemIds,
  ) {
    final ids = itemIds.where((id) => id.trim().isNotEmpty).toSet().toList();
    if (ids.isEmpty) {
      return Future.value(const []);
    }
    return _fetchList('/characters/facets', data: {'item_ids': ids});
  }

  Future<List<Map<String, dynamic>>> getCharacterAppearances(
    String characterId,
  ) {
    return _fetchList(
        '/characters/${Uri.encodeComponent(characterId)}/appearances');
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
    return _resolveImageUrls(data);
  }

  Future<Map<String, dynamic>> health() async {
    final response = await _dio.get<Map<String, dynamic>>('/health');
    final data = response.data;
    if (data == null) {
      throw StateError('/health returned an empty response body');
    }
    return data;
  }

  // -----------------------------------------------------------------------
  // User management
  // -----------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> adminListUsers() async {
    final response = await _dio.get<List<dynamic>>('/admin/users');
    final data = response.data;
    if (data == null) return const [];
    return data.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> adminImageCacheStats() async {
    final response =
        await _dio.get<Map<String, dynamic>>('/admin/image-cache/stats');
    final data = response.data;
    if (data == null) {
      throw StateError('/admin/image-cache/stats returned empty body');
    }
    return data;
  }

  Future<Map<String, dynamic>> adminPurgeImageCache({String? provider}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/admin/image-cache/purge',
      queryParameters: {if (provider != null) 'provider': provider},
    );
    final data = response.data;
    if (data == null) {
      throw StateError('/admin/image-cache/purge returned empty body');
    }
    return data;
  }

  Future<Map<String, dynamic>> adminUpdateUser(
    String userId, {
    String? role,
    bool? isActive,
    String? displayName,
  }) async {
    final body = <String, dynamic>{
      if (role != null) 'role': role,
      if (isActive != null) 'is_active': isActive,
      if (displayName != null) 'display_name': displayName,
    };
    final response = await _dio.patch<Map<String, dynamic>>(
      '/admin/users/${Uri.encodeComponent(userId)}',
      data: body,
    );
    final data = response.data;
    if (data == null) {
      throw StateError('/admin/users/$userId returned an empty response body');
    }
    return data;
  }

  // ---------------------------------------------------------------------------
  // Images — download & multi-image
  // ---------------------------------------------------------------------------

  /// Download a single processed image from the server as raw bytes.
  Future<List<int>> downloadImageBytes(String objectKey) async {
    final response = await _dio.get<List<int>>(
      '/images/download',
      queryParameters: {'object_key': objectKey},
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data ?? const [];
  }

  /// Batch-download processed images.  Returns a map of object_key → base64.
  Future<Map<String, String?>> batchDownloadImages(
    List<String> objectKeys,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/images/batch-download',
      data: objectKeys,
    );
    return response.data?.map(
          (key, value) => MapEntry(key, value as String?),
        ) ??
        {};
  }

  /// List all image assets for an entity.
  Future<List<Map<String, dynamic>>> listEntityImages({
    required String entityType,
    required String entityId,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/images/entity/$entityType/$entityId',
    );
    return (response.data ?? []).cast<Map<String, dynamic>>();
  }

  /// Upload a new image for an entity.
  Future<Map<String, dynamic>> addEntityImage({
    required String entityType,
    required String entityId,
    required String imageType,
    required String imageDataBase64,
    String? sourceUrl,
    String? provider,
    bool isPrimary = false,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/images/entity/$entityType/$entityId',
      data: {
        'image_type': imageType,
        'image_data_base64': imageDataBase64,
        if (sourceUrl != null) 'source_url': sourceUrl,
        if (provider != null) 'provider': provider,
        'is_primary': isPrimary,
      },
    );
    return response.data ?? {};
  }

  /// Delete an image asset.
  Future<void> deleteEntityImage(String imageId) async {
    await _dio.delete('/images/$imageId');
  }

  /// Set an image as primary for its type.
  Future<Map<String, dynamic>> setImagePrimary(String imageId) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/images/$imageId/primary',
    );
    return response.data ?? {};
  }

  Map<String, dynamic> _resolveImageUrls(Map<String, dynamic> data) {
    return _resolveImageUrlsValue(data) as Map<String, dynamic>;
  }

  Object? _resolveImageUrlsValue(Object? value) {
    if (value is List) {
      return value.map(_resolveImageUrlsValue).toList(growable: false);
    }
    if (value is Map<String, dynamic>) {
      final resolved = <String, dynamic>{};
      for (final entry in value.entries) {
        final nested = _resolveImageUrlsValue(entry.value);
        resolved[entry.key] =
            _imageUrlKeys.contains(entry.key) ? _resolveApiUrl(nested) : nested;
      }
      return resolved;
    }
    return value;
  }

  String? _resolveApiUrl(Object? value) {
    final raw = value?.toString().trim();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final parsed = Uri.tryParse(raw);
    if (parsed == null) {
      return raw;
    }
    if (parsed.hasScheme) {
      return _rewriteKnownProviderImageUrl(parsed) ?? raw;
    }
    if (!raw.startsWith('/')) {
      return raw;
    }
    final base = Uri.tryParse(baseUrl);
    return base?.resolve(raw).toString() ?? raw;
  }

  String? _rewriteKnownProviderImageUrl(Uri uri) {
    final host = uri.host.toLowerCase();
    if (!host.endsWith('mangadex.org')) {
      return null;
    }
    final segments = uri.pathSegments;
    if (segments.length < 2 || segments.first != 'covers') {
      return null;
    }
    final providerItemId = segments[1].trim();
    if (providerItemId.isEmpty) {
      return null;
    }
    final base = Uri.tryParse(baseUrl);
    if (base == null) {
      return null;
    }
    return base
        .resolve(
          '/metadata/providers/mangadex/images/'
          '${Uri.encodeComponent(providerItemId)}',
        )
        .toString();
  }
}

const _imageUrlKeys = {
  'image_url',
  'cover_image_url',
  'thumbnail_image_url',
  'cover_delivery_url',
};

String _dateForApi(DateTime value) {
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
