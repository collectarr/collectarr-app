import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/models/bundle_release.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/core/models/metadata_search_query.dart';
import 'package:collectarr_app/core/models/season.dart';
import 'package:collectarr_app/core/models/series_relation.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

part 'api_client_admin.dart';
part 'api_client_catalog.dart';
part 'api_client_provider.dart';
part 'api_client_browse.dart';
part 'api_client_assets.dart';

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
  late final _AdminApiClient _adminApi = _AdminApiClient(this);
  late final _CatalogApiClient _catalogApi = _CatalogApiClient(this);
  late final _ProviderApiClient _providerApi = _ProviderApiClient(this);
  late final _BrowseApiClient _browseApi = _BrowseApiClient(this);
  late final _AssetsApiClient _assetsApi = _AssetsApiClient(this);

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

  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
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
    return _catalogApi.search(
      query,
      kind: kind,
      series: series,
      issueNumber: issueNumber,
      publisher: publisher,
      year: year,
      barcode: barcode,
      limit: limit,
    );
  }

  Future<List<Map<String, dynamic>>> searchMetadata(
    MetadataSearchQuery query,
  ) async {
    return _catalogApi.searchMetadata(query);
  }

  Future<CatalogItem> getMetadataItem({
    required String kind,
    required String id,
  }) async {
    return _catalogApi.getMetadataItem(kind: kind, id: id);
  }

  Future<List<BundleReleaseSummary>> getItemBundleReleases(String itemId) async {
    return _catalogApi.getItemBundleReleases(itemId);
  }

  Future<BundleReleaseDetail> getBundleRelease(String bundleReleaseId) async {
    return _catalogApi.getBundleRelease(bundleReleaseId);
  }

  Future<List<CatalogMediaType>> metadataMediaTypes() async {
    return _catalogApi.metadataMediaTypes();
  }

  Future<List<Map<String, dynamic>>> searchProvider({
    String? provider,
    required String query,
    String? kind,
    String? series,
    String? issueNumber,
    int? year,
  }) async {
    return _providerApi.searchProvider(
      provider: provider,
      query: query,
      kind: kind,
      series: series,
      issueNumber: issueNumber,
      year: year,
    );
  }

  Future<List<AdminProviderStatus>> adminProviderStatuses() async {
    return _adminApi.adminProviderStatuses();
  }

  Future<AdminCatalogSummary> adminCatalogSummary() async {
    return _adminApi.adminCatalogSummary();
  }

  Future<List<AdminMetadataItem>> adminCatalogItems({
    String? query,
    String? kind,
    int limit = 25,
  }) async {
    return _adminApi.adminCatalogItems(
      query: query,
      kind: kind,
      limit: limit,
    );
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
    return _adminApi.adminUpdateCatalogItem(
      kind: kind,
      id: id,
      title: title,
      itemNumber: itemNumber,
      synopsis: synopsis,
      editionTitle: editionTitle,
      pageCount: pageCount,
      runtimeMinutes: runtimeMinutes,
      publisher: publisher,
      releaseDate: releaseDate,
      imprint: imprint,
      subtitle: subtitle,
      seriesGroup: seriesGroup,
      country: country,
      language: language,
      ageRating: ageRating,
      catalogNumber: catalogNumber,
      releaseStatus: releaseStatus,
      physicalFormat: physicalFormat,
      variantName: variantName,
      barcode: barcode,
      coverImageUrl: coverImageUrl,
      thumbnailImageUrl: thumbnailImageUrl,
      includeNulls: includeNulls,
      explicitFields: explicitFields,
    );
  }

  Future<Map<String, dynamic>> adminUpdateSeriesTags({
    required String seriesId,
    required List<String> tags,
  }) async {
    return _adminApi.adminUpdateSeriesTags(seriesId: seriesId, tags: tags);
  }

  Future<BundleReleaseDetail> adminUpdateBundleRelease({
    required String bundleReleaseId,
    required AdminBundleReleaseCorrection correction,
  }) async {
    return _adminApi.adminUpdateBundleRelease(
      bundleReleaseId: bundleReleaseId,
      correction: correction,
    );
  }

  Future<AdminSearchStatus> adminSearchStatus() async {
    return _adminApi.adminSearchStatus();
  }

  Future<AdminSearchReindexResult> adminReindexSearch() async {
    return _adminApi.adminReindexSearch();
  }

  Future<List<AdminSearchHistoryEntry>> adminSearchHistory() async {
    return _adminApi.adminSearchHistory();
  }

  Future<List<AdminAuditLogEntry>> adminAuditLogs({
    String? action,
    String? entityType,
    String? entityId,
    int limit = 10,
  }) async {
    return _adminApi.adminAuditLogs(
      action: action,
      entityType: entityType,
      entityId: entityId,
      limit: limit,
    );
  }

  Future<List<AdminDuplicateCandidate>> adminDuplicateCandidates({
    int limit = 10,
  }) async {
    return _adminApi.adminDuplicateCandidates(limit: limit);
  }

  Future<AdminDuplicateActionResult> adminIgnoreDuplicateCandidate({
    required List<String> itemIds,
  }) async {
    return _adminApi.adminIgnoreDuplicateCandidate(itemIds: itemIds);
  }

  Future<AdminDuplicateActionResult> adminMergeDuplicateCandidate({
    required String targetItemId,
    required List<String> sourceItemIds,
  }) async {
    return _adminApi.adminMergeDuplicateCandidate(
      targetItemId: targetItemId,
      sourceItemIds: sourceItemIds,
    );
  }

  Future<AdminMetadataItem> adminGetMetadataItem({
    required String kind,
    required String id,
  }) async {
    return _adminApi.adminGetMetadataItem(kind: kind, id: id);
  }

  Future<List<Map<String, dynamic>>> adminProviderSearch({
    required String provider,
    required String query,
    String? kind,
  }) async {
    return _adminApi.adminProviderSearch(
      provider: provider,
      query: query,
      kind: kind,
    );
  }

  Future<AdminProviderPreview> adminProviderPreview({
    required String provider,
    required String providerItemId,
  }) async {
    return _adminApi.adminProviderPreview(
      provider: provider,
      providerItemId: providerItemId,
    );
  }

  Future<AdminBatchHydrateResult> adminProviderBatchHydrate({
    required String provider,
    required List<String> providerItemIds,
  }) async {
    return _adminApi.adminProviderBatchHydrate(
      provider: provider,
      providerItemIds: providerItemIds,
    );
  }

  Future<AdminProviderPreview> providerPreview({
    required String provider,
    required String providerItemId,
  }) async {
    return _providerApi.providerPreview(
      provider: provider,
      providerItemId: providerItemId,
    );
  }

  Future<AdminProviderPreview> _providerPreview(
    String path, {
    required String provider,
    required String providerItemId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      path,
      data: {
        'provider': provider,
        'provider_item_id': providerItemId,
      },
    );
    final data = response.data;
    if (data == null) {
      throw StateError('$path returned an empty response body');
    }
    return AdminProviderPreview.fromJson(data);
  }

  Future<AdminProviderIngestResult> adminProviderIngest({
    required String provider,
    required String providerItemId,
    String? kind,
  }) async {
    return _adminApi.adminProviderIngest(
      provider: provider,
      providerItemId: providerItemId,
      kind: kind,
    );
  }

  Future<List<AdminProviderIngestHistoryEntry>>
      adminProviderIngestHistory() async {
    return _adminApi.adminProviderIngestHistory();
  }

  Future<AdminProviderIngestResult> adminRetryProviderIngest({
    required int historyId,
  }) async {
    return _adminApi.adminRetryProviderIngest(historyId: historyId);
  }

  Future<List<AdminProviderIngestJob>> adminProviderIngestJobs({
    String? status,
    String? provider,
    String? query,
    int limit = 25,
  }) async {
    return _adminApi.adminProviderIngestJobs(
      status: status,
      provider: provider,
      query: query,
      limit: limit,
    );
  }

  Future<AdminProviderIngestJobSummary> adminProviderIngestJobSummary() async {
    return _adminApi.adminProviderIngestJobSummary();
  }

  Future<AdminProviderIngestJob> adminCreateProviderIngestJob({
    required String provider,
    required String providerItemId,
    int maxAttempts = 3,
  }) async {
    return _adminApi.adminCreateProviderIngestJob(
      provider: provider,
      providerItemId: providerItemId,
      maxAttempts: maxAttempts,
    );
  }

  Future<AdminProviderIngestJobRunResult> adminRunPendingProviderIngestJobs({
    int limit = 5,
  }) async {
    return _adminApi.adminRunPendingProviderIngestJobs(limit: limit);
  }

  Future<AdminProviderIngestJob> adminRunProviderIngestJob({
    required String jobId,
  }) async {
    return _adminApi.adminRunProviderIngestJob(jobId: jobId);
  }

  Future<AdminProviderIngestJob> adminRetryProviderIngestJob({
    required String jobId,
  }) async {
    return _adminApi.adminRetryProviderIngestJob(jobId: jobId);
  }

  Future<AdminMetadataProposalSummary> adminMetadataProposalSummary() async {
    return _adminApi.adminMetadataProposalSummary();
  }

  Future<List<AdminMetadataProposal>> adminMetadataProposals({
    String status = 'pending',
    String? provider,
  }) async {
    return _adminApi.adminMetadataProposals(
      status: status,
      provider: provider,
    );
  }

  Future<AdminProviderIngestResult> adminApproveMetadataProposal({
    required String proposalId,
  }) async {
    return _adminApi.adminApproveMetadataProposal(proposalId: proposalId);
  }

  Future<AdminProviderIngestResult>
      adminApproveMetadataProposalWithProviderItem({
    required String proposalId,
    required String provider,
    required String providerItemId,
    String? kind,
  }) async {
    return _adminApi.adminApproveMetadataProposalWithProviderItem(
      proposalId: proposalId,
      provider: provider,
      providerItemId: providerItemId,
      kind: kind,
    );
  }

  Future<AdminMetadataProposal> adminRejectMetadataProposal({
    required String proposalId,
  }) async {
    return _adminApi.adminRejectMetadataProposal(proposalId: proposalId);
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
    return _catalogApi.createMetadataProposal(
      provider: provider,
      query: query,
      providerItemId: providerItemId,
      title: title,
      summary: summary,
      imageUrl: imageUrl,
      metadataPayload: metadataPayload,
    );
  }

  Future<Map<String, dynamic>> getComic(String id) async {
    return _catalogApi.getComic(id);
  }

  Future<List<SeriesRelation>> getSeriesRelations(String seriesId) async {
    return _catalogApi.getSeriesRelations(seriesId);
  }

  Future<Map<String, dynamic>> getSeries(String seriesId) async {
    return _catalogApi.getSeries(seriesId);
  }

  Future<List<Map<String, dynamic>>> getSeriesItems(String seriesId) {
    return _catalogApi.getSeriesItems(seriesId);
  }

  Future<List<Season>> getProviderSeasons(
    String provider,
    String providerItemId,
  ) async {
    return _providerApi.getProviderSeasons(provider, providerItemId);
  }

  Future<List<Season>> getProviderVolumes(
    String provider,
    String providerItemId,
  ) async {
    return _providerApi.getProviderVolumes(provider, providerItemId);
  }

  Future<List<Season>> getItemVolumes(String itemId) async {
    return _catalogApi.getItemVolumes(itemId);
  }

  Future<List<Season>> getItemSeasons(String itemId) async {
    return _catalogApi.getItemSeasons(itemId);
  }

  Future<CatalogEdition> createEdition(String itemId, {required String title}) async {
    return _catalogApi.createEdition(itemId, title: title);
  }

  Future<List<Map<String, dynamic>>> searchStoryArcs({
    String? query,
    int limit = 50,
  }) {
    return _browseApi.searchStoryArcs(query: query, limit: limit);
  }

  Future<List<Map<String, dynamic>>> getStoryArcItems(String storyArcId) {
    return _browseApi.getStoryArcItems(storyArcId);
  }

  Future<List<Map<String, dynamic>>> storyArcFacets(
    Iterable<String> itemIds,
  ) {
    return _browseApi.storyArcFacets(itemIds);
  }

  Future<List<Map<String, dynamic>>> searchCreators({
    String? query,
    int limit = 50,
  }) {
    return _browseApi.searchCreators(query: query, limit: limit);
  }

  Future<List<Map<String, dynamic>>> creatorFacets(
    Iterable<String> itemIds,
  ) {
    return _browseApi.creatorFacets(itemIds);
  }

  Future<List<Map<String, dynamic>>> getCreatorCredits(
    String creatorId,
  ) {
    return _browseApi.getCreatorCredits(creatorId);
  }

  Future<List<Map<String, dynamic>>> searchCharacters({
    String? query,
    int limit = 50,
  }) {
    return _browseApi.searchCharacters(query: query, limit: limit);
  }

  Future<List<Map<String, dynamic>>> characterFacets(
    Iterable<String> itemIds,
  ) {
    return _browseApi.characterFacets(itemIds);
  }

  Future<List<Map<String, dynamic>>> getCharacterAppearances(
    String characterId,
  ) {
    return _browseApi.getCharacterAppearances(characterId);
  }

  Future<Map<String, dynamic>> lookupBarcode(String barcode,
      {String? kind}) async {
    return _catalogApi.lookupBarcode(barcode, kind: kind);
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

  Future<List<AdminUser>> adminListUsers() async {
    return _assetsApi.adminListUsers();
  }

  Future<AdminImageCacheStats> adminImageCacheStats() async {
    return _assetsApi.adminImageCacheStats();
  }

  Future<AdminImageCachePurgeResult> adminPurgeImageCache({
    String? provider,
  }) async {
    return _assetsApi.adminPurgeImageCache(provider: provider);
  }

  Future<AdminUser> adminUpdateUser(
    String userId, {
    String? role,
    bool? isActive,
    String? displayName,
  }) async {
    return _assetsApi.adminUpdateUser(
      userId,
      role: role,
      isActive: isActive,
      displayName: displayName,
    );
  }

  // ---------------------------------------------------------------------------
  // Images — download & multi-image
  // ---------------------------------------------------------------------------

  /// Download a single processed image from the server as raw bytes.
  Future<List<int>> downloadImageBytes(String objectKey) async {
    return _assetsApi.downloadImageBytes(objectKey);
  }

  /// Batch-download processed images.  Returns a map of object_key → base64.
  Future<Map<String, String?>> batchDownloadImages(
    List<String> objectKeys,
  ) async {
    return _assetsApi.batchDownloadImages(objectKeys);
  }

  /// List all image assets for an entity.
  Future<List<Map<String, dynamic>>> listEntityImages({
    required String entityType,
    required String entityId,
  }) async {
    return _assetsApi.listEntityImages(
      entityType: entityType,
      entityId: entityId,
    );
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
    return _assetsApi.addEntityImage(
      entityType: entityType,
      entityId: entityId,
      imageType: imageType,
      imageDataBase64: imageDataBase64,
      sourceUrl: sourceUrl,
      provider: provider,
      isPrimary: isPrimary,
    );
  }

  /// Delete an image asset.
  Future<void> deleteEntityImage(String imageId) async {
    await _assetsApi.deleteEntityImage(imageId);
  }

  /// Set an image as primary for its type.
  Future<Map<String, dynamic>> setImagePrimary(String imageId) async {
    return _assetsApi.setImagePrimary(imageId);
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
