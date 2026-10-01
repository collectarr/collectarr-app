import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/api/dto/canonical_correction_proposal.dart';
import 'package:collectarr_app/core/api/dto/canonical_correction_target.dart';
import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/core/models/auth_session.dart';
import 'package:collectarr_app/core/api/dto/bundle_release.dart';
import 'package:collectarr_app/core/models/catalog_search_hit.dart';
import 'package:collectarr_app/core/api/dto/media_catalog.dart';
import 'package:collectarr_app/core/api/dto/metadata_search_query.dart';
import 'package:collectarr_app/core/models/library_relation_node.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/api/generated/collectarr_api.client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

part 'api_client_admin.dart';
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
  late final CollectarrApiClient _catalogApi =
      CollectarrApiClient(_dio, _resolveImageUrls);
  late final _AssetsApiClient _assetsApi = _AssetsApiClient(this);

  CollectarrApiClient get catalog => _catalogApi;

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

  Future<AuthSession> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/auth/register',
      data: {
        'email': email,
        'password': password,
        'display_name': displayName,
      },
    );
    final session = AuthSession.fromJson(response.data!);
    setToken(session.token);
    return session;
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
    final session = AuthSession.fromJson(response.data!);
    setToken(session.token);
    return session;
  }

  Future<AuthUser> currentUser() async {
    final response = await _dio.get<Map<String, dynamic>>('/api/v1/auth/me');
    final data = response.data;
    if (data == null) {
      throw StateError('/api/v1/auth/me returned an empty response.');
    }
    return AuthUser.fromJson(data);
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
    int? offset,
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
      offset: offset,
    );
  }

  /// Returns only the identity and display summary needed by cross-kind UI.
  Future<List<CatalogSearchHit>> searchHits(
    String query, {
    CatalogMediaKind? kind,
    String? series,
    String? issueNumber,
    String? publisher,
    int? year,
    String? barcode,
    int? limit,
    int? offset,
  }) async {
    final rows = await search(
      query,
      kind: kind?.apiValue,
      series: series,
      issueNumber: issueNumber,
      publisher: publisher,
      year: year,
      barcode: barcode,
      limit: limit,
      offset: offset,
    );
    return [
      for (final row in rows) CatalogSearchHit.fromJson(row),
    ];
  }

  Future<List<Map<String, dynamic>>> searchMetadata(MetadataSearchQuery query,
      {CancelToken? cancelToken}) async {
    return _catalogApi.searchMetadata(query, cancelToken: cancelToken);
  }

  /// Fetches an untyped JSON object for a kind-owned remote data source.
  ///
  /// The owning feature is responsible for decoding the response into its
  /// typed transport model.
  Future<Map<String, dynamic>> getJsonObject(
    String path, {
    Map<String, Object?>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );
    final data = response.data;
    if (data == null) {
      throw StateError('Core returned an empty JSON object for $path.');
    }
    return data;
  }

  /// Fetches a JSON list for a kind-owned remote data source.
  Future<List<Map<String, dynamic>>> getJsonList(
    String path, {
    Map<String, Object?>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      path,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );
    return [
      for (final value in response.data ?? const <dynamic>[])
        if (value is Map) Map<String, dynamic>.from(value),
    ];
  }

  Future<Map<String, dynamic>> getCatalogItemJson({
    required CatalogMediaKind kind,
    required String id,
    CancelToken? cancelToken,
  }) {
    return _catalogApi.getCatalogItemJson(
      kind: kind,
      id: id,
      cancelToken: cancelToken,
    );
  }

  Future<TvSeriesDto> getTvSeriesDto(String id) {
    return _catalogApi.getTvSeriesDto(id);
  }

  Future<List<TvSeasonDto>> getTvSeriesSeasonsDto(String id) {
    return _catalogApi.getTvSeriesSeasonsDto(id);
  }

  Future<List<TvReleaseDto>> getTvSeriesReleasesDto(String id) {
    return _catalogApi.getTvSeriesReleasesDto(id);
  }

  Future<TvSeasonDto> getTvSeasonDto(String id) {
    return _catalogApi.getTvSeasonDto(id);
  }

  Future<List<TvEpisodeDto>> getTvSeasonEpisodesDto(String id) {
    return _catalogApi.getTvSeasonEpisodesDto(id);
  }

  Future<TvReleaseDto> getTvReleaseDto(String id) {
    return _catalogApi.getTvReleaseDto(id);
  }

  Future<List<TvReleaseMediaDto>> getTvReleaseMediaDto(String id) {
    return _catalogApi.getTvReleaseMediaDto(id);
  }

  Future<List<TvReleaseEpisodeMapDto>> getTvReleaseEpisodeMapDto(String id) {
    return _catalogApi.getTvReleaseEpisodeMapDto(id);
  }

  Future<TvReleaseMediaDto> getTvReleaseMediaItemDto(String id) {
    return _catalogApi.getTvReleaseMediaItemDto(id);
  }

  Future<BundleReleaseDetail> getBundleRelease(String bundleReleaseId) async {
    return _catalogApi.getBundleRelease(bundleReleaseId);
  }

  Future<List<BundleReleaseSummary>> getItemBundleReleases(
      String itemId) async {
    return const <BundleReleaseSummary>[];
  }

  Future<List<CatalogMediaType>> metadataMediaTypes() async {
    return _catalogApi.metadataMediaTypes();
  }

  Future<MetadataNormalizedManifest> metadataNormalizedManifest() async {
    return _catalogApi.metadataNormalizedManifest();
  }

  Future<MetadataFieldSchema> metadataFieldSchema({
    bool editableOnly = true,
  }) async {
    return _catalogApi.metadataFieldSchema(editableOnly: editableOnly);
  }

  /// Creates a proposal against one exact canonical Core entity.
  Future<CanonicalCorrectionProposal> proposeCanonicalCorrection({
    required CatalogMediaKind kind,
    required String entityType,
    required String entityId,
    required String scope,
    String? baseRevision,
    String? baseHash,
    required Map<String, Object?> proposedFields,
  }) async {
    if (baseRevision == null && baseHash == null) {
      throw ArgumentError('baseRevision or baseHash is required.');
    }
    if (proposedFields.isEmpty) {
      throw ArgumentError('proposedFields must not be empty.');
    }
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/metadata/correction-proposals',
      data: {
        'kind': kind.apiValue,
        'entity_type': entityType,
        'entity_id': entityId,
        'scope': scope,
        if (baseRevision != null) 'base_revision': baseRevision,
        if (baseHash != null) 'base_hash': baseHash,
        'proposed_fields': proposedFields,
      },
    );
    final data = response.data;
    if (data == null) {
      throw StateError('Core returned an empty correction proposal response.');
    }
    return CanonicalCorrectionProposal.fromJson(data);
  }

  Future<CanonicalCorrectionTarget> getCanonicalCorrectionTarget({
    required CatalogMediaKind kind,
    required String entityId,
    required String scope,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/metadata/correction-targets/${kind.apiValue}/${Uri.encodeComponent(entityId)}',
      queryParameters: {'scope': scope},
    );
    final data = response.data;
    if (data == null) {
      throw StateError('Core returned an empty canonical target snapshot.');
    }
    return CanonicalCorrectionTarget.fromJson(data);
  }

  Future<AdminCatalogSummary> adminCatalogSummary() async {
    return _adminApi.adminCatalogSummary();
  }

  Future<AdminNormalizedMetadataDriftReport> adminNormalizedMetadataDrift(
      {int sampleLimit = 100}) async {
    return _adminApi.adminNormalizedMetadataDrift(sampleLimit: sampleLimit);
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

  /// Sends a kind-owned correction patch without interpreting its fields in
  /// the generic Library orchestration layer.
  Future<AdminMetadataItem> adminUpdateCatalogItemFields({
    required String kind,
    required String id,
    required Map<String, Object?> fields,
  }) {
    return _adminApi.adminUpdateCatalogItemFields(
      kind: kind,
      id: id,
      fields: fields,
    );
  }

  Future<Map<String, dynamic>> adminUpdateSeriesFields({
    required String seriesId,
    required Map<String, Object?> fields,
  }) {
    return _adminApi.adminUpdateSeriesFields(
      seriesId: seriesId,
      fields: fields,
    );
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

  Future<AdminMetadataItem> adminGetMetadataItem({
    required String kind,
    required String id,
  }) async {
    return _adminApi.adminGetMetadataItem(kind: kind, id: id);
  }

  Future<AdminMetadataProposalSummary> adminMetadataProposalSummary() async {
    return _adminApi.adminMetadataProposalSummary();
  }

  Future<List<AdminMetadataProposal>> adminMetadataProposals({
    String status = 'pending',
  }) async {
    return _adminApi.adminMetadataProposals(status: status);
  }

  Future<AdminMetadataProposal> adminApproveMetadataProposal({
    required String proposalId,
  }) async {
    return _adminApi.adminApproveMetadataProposal(proposalId: proposalId);
  }

  Future<AdminMetadataProposal> adminUpdateMetadataProposal({
    required String proposalId,
    required Map<String, dynamic> catalogItem,
    String? reviewNote,
  }) async {
    return _adminApi.adminUpdateMetadataProposal(
      proposalId: proposalId,
      catalogItem: catalogItem,
      reviewNote: reviewNote,
    );
  }

  Future<AdminMetadataProposal> adminRejectMetadataProposal({
    required String proposalId,
  }) async {
    return _adminApi.adminRejectMetadataProposal(proposalId: proposalId);
  }

  Future<Map<String, dynamic>> createCatalogItemProposal({
    required String kind,
    required Map<String, dynamic> catalogItem,
  }) async {
    return _catalogApi.createCatalogItemProposal(
      kind: kind,
      catalogItem: catalogItem,
    );
  }

  Future<List<LibraryRelationNode>> getSeriesRelations(String seriesId) async {
    return _catalogApi.getSeriesRelations(seriesId);
  }

  Future<Map<String, dynamic>> getSeries(String seriesId) async {
    return _catalogApi.getSeries(seriesId);
  }

  Future<List<Map<String, dynamic>>> getSeriesItems(String seriesId) {
    return _catalogApi.getSeriesItems(seriesId);
  }

  /// Sends a GET request for a JSON list without assigning domain meaning to
  /// its fields. Kind-owned repositories map the returned rows.
  Future<List<Map<String, dynamic>>> getJsonRows(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      path,
      queryParameters: queryParameters,
    );
    return _decodeJsonRows(response.data);
  }

  /// Sends a POST request for a JSON list without assigning domain meaning to
  /// its fields. Kind-owned repositories map the returned rows.
  Future<List<Map<String, dynamic>>> postJsonRows(
    String path, {
    required Object data,
  }) async {
    final response = await _dio.post<List<dynamic>>(path, data: data);
    return _decodeJsonRows(response.data);
  }

  Future<Map<String, dynamic>> lookupBarcode(
    String barcode, {
    String? kind,
    CancelToken? cancelToken,
  }) async {
    return _catalogApi.lookupBarcode(
      barcode,
      kind: kind,
      cancelToken: cancelToken,
    );
  }

  Future<Map<String, dynamic>> health() async {
    final response = await _dio.get<Map<String, dynamic>>('/api/v1/health');
    final data = response.data;
    if (data == null) {
      throw StateError('/api/v1/health returned an empty response body');
    }
    return data;
  }

  // -----------------------------------------------------------------------
  // User management
  // -----------------------------------------------------------------------

  Future<List<AdminUser>> adminListUsers() async {
    return _assetsApi.adminListUsers();
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
    bool isPrimary = false,
  }) async {
    return _assetsApi.addEntityImage(
      entityType: entityType,
      entityId: entityId,
      imageType: imageType,
      imageDataBase64: imageDataBase64,
      sourceUrl: sourceUrl,
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

  /// Search for visually similar covers by uploading an image.
  Future<Map<String, dynamic>> searchByCoverUpload(
    Uint8List imageBytes, {
    int threshold = 12,
    int limit = 20,
  }) async {
    return _assetsApi.searchByCoverUpload(
      imageBytes,
      threshold: threshold,
      limit: limit,
    );
  }

  Map<String, dynamic> _resolveImageUrls(Map<String, dynamic> data) {
    return _resolveImageUrlsValue(data) as Map<String, dynamic>;
  }

  List<Map<String, dynamic>> _decodeJsonRows(List<dynamic>? body) {
    if (body == null) {
      return const [];
    }
    return body
        .cast<Map<String, dynamic>>()
        .map(_resolveImageUrls)
        .toList(growable: false);
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
      return raw;
    }
    if (!raw.startsWith('/')) {
      return raw;
    }
    final base = Uri.tryParse(baseUrl);
    return base?.resolve(raw).toString() ?? raw;
  }
}

const _imageUrlKeys = {
  'image_url',
  'cover_image_url',
  'thumbnail_image_url',
  'cover_delivery_url',
};
