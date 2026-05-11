import 'package:dio/dio.dart';

class ApiClient {
  ApiClient({String baseUrl = 'http://localhost:8010'})
      : _dio = Dio(BaseOptions(baseUrl: baseUrl));

  final Dio _dio;

  String get baseUrl => _dio.options.baseUrl;

  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
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
    final response = await _dio.get<List<dynamic>>(
      '/search',
      queryParameters: {
        if (query.trim().isNotEmpty) 'q': query,
        if (kind != null) 'kind': kind,
        if (series != null && series.trim().isNotEmpty) 'series': series,
        if (issueNumber != null && issueNumber.trim().isNotEmpty)
          'issue_number': issueNumber,
        if (publisher != null && publisher.trim().isNotEmpty)
          'publisher': publisher,
        if (year != null) 'year': year,
        if (barcode != null && barcode.trim().isNotEmpty)
          'barcode': _normalizeBarcode(barcode),
        if (limit != null) 'limit': limit,
      },
    );
    return response.data!.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> searchProvider({
    required String provider,
    required String query,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/metadata/providers/$provider/search',
      queryParameters: {'q': query},
    );
    final data = response.data;
    if (data == null) {
      return const [];
    }
    return data.cast<Map<String, dynamic>>();
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
      '/barcode/${Uri.encodeComponent(_normalizeBarcode(barcode))}',
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

  String _normalizeBarcode(String value) {
    return value.trim().replaceAll(RegExp(r'[\s-]+'), '');
  }
}
