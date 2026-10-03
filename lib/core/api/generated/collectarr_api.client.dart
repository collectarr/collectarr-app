import 'package:collectarr_app/core/api/dto/bundle_release.dart';
import 'package:collectarr_app/core/api/dto/media_catalog.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/api/dto/metadata_search_query.dart';
import 'package:collectarr_app/core/models/library_relation_node.dart';
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
    int? offset,
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
        offset: offset,
      ),
    );
  }

  Future<List<Map<String, dynamic>>> searchMetadata(
    MetadataSearchQuery query, {
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/api/v1/search',
      queryParameters: query.toQueryParameters(),
      cancelToken: cancelToken,
    );
    return response.data!
        .cast<Map<String, dynamic>>()
        .map(_resolveImageUrls)
        .toList(growable: false);
  }

  /// Fetches one flattened, kind-entry Catalog Item response.
  ///
  /// This is the canonical read path for Add/Edit catalog data. It does not
  /// route through Work or Release endpoints.
  Future<Map<String, dynamic>> getCatalogItemJson({
    required CatalogMediaKind kind,
    required String id,
    CancelToken? cancelToken,
  }) async {
    final route = switch (kind) {
      CatalogMediaKind.anime => 'anime',
      CatalogMediaKind.boardgame => 'boardgames',
      CatalogMediaKind.book => 'books',
      CatalogMediaKind.comic => 'comics',
      CatalogMediaKind.game => 'games',
      CatalogMediaKind.manga => 'manga',
      CatalogMediaKind.movie => 'movies',
      CatalogMediaKind.music => 'music',
      CatalogMediaKind.tv => 'tv',
      CatalogMediaKind.unknown =>
        throw UnsupportedError('Unknown Catalog Item kind.'),
    };
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/metadata/$route/items/${Uri.encodeComponent(id)}',
      cancelToken: cancelToken,
    );
    final data = response.data;
    if (data == null) {
      throw StateError('Core returned an empty $route Catalog Item response.');
    }
    return _resolveImageUrls(data);
  }

  Future<BundleReleaseDetail> getBundleRelease(String bundleReleaseId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/metadata/bundle-releases/$bundleReleaseId',
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
        '/api/v1/metadata/bundle-releases/$bundleReleaseId returned an empty response body',
      );
    }
    return BundleReleaseDetail.fromJson(_resolveImageUrls(data));
  }

  Future<List<CatalogMediaType>> metadataMediaTypes() async {
    final response = await _dio.get<dynamic>('/api/v1/metadata/media-types');
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
      '/api/v1/metadata/normalized-manifest',
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
        '/api/v1/metadata/normalized-manifest returned an empty response body',
      );
    }
    return MetadataNormalizedManifest.fromJson(data);
  }

  Future<MetadataFieldSchema> metadataFieldSchema({
    bool editableOnly = true,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/metadata/field-schema',
      queryParameters: {'editable_only': editableOnly},
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
        '/api/v1/metadata/field-schema returned an empty response body',
      );
    }
    return MetadataFieldSchema.fromJson(data);
  }

  Future<Map<String, dynamic>> createCatalogItemProposal({
    required String kind,
    required Map<String, dynamic> catalogItem,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/metadata/proposals',
      data: {
        'schema_version': 'v1',
        'kind': kind,
        'catalog_item': catalogItem,
      },
    );
    final data = response.data;
    if (data == null) {
      throw StateError(
          '/api/v1/metadata/proposals returned an empty response body');
    }
    return data;
  }

  Future<List<LibraryRelationNode>> getSeriesRelations(String seriesId) async {
    final response =
        await _dio.get<List<dynamic>>('/api/v1/series/$seriesId/relations');
    final data = response.data;
    if (data == null) {
      return const [];
    }
    return data
        .cast<Map<String, dynamic>>()
        .map(LibraryRelationNode.fromJson)
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> getSeries(String seriesId) async {
    final response =
        await _dio.get<Map<String, dynamic>>('/api/v1/series/$seriesId');
    final data = response.data;
    if (data == null) {
      throw StateError(
          '/api/v1/series/$seriesId returned an empty response body');
    }
    return data;
  }

  Future<List<Map<String, dynamic>>> getSeriesItems(String seriesId) async {
    final response =
        await _dio.get<List<dynamic>>('/api/v1/series/$seriesId/items');
    final data = response.data;
    if (data == null) {
      return const [];
    }
    return data
        .cast<Map<String, dynamic>>()
        .map(_resolveImageUrls)
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> lookupBarcode(
    String barcode, {
    String? kind,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/barcode/${Uri.encodeComponent(MetadataSearchQuery.normalizeBarcode(barcode))}',
      queryParameters: {if (kind != null) 'kind': kind},
      cancelToken: cancelToken,
    );
    final data = response.data;
    if (data == null) {
      throw StateError('/api/v1/barcode returned an empty response body');
    }
    return _resolveImageUrls(data);
  }
}
