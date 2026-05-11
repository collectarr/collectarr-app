import 'package:dio/dio.dart';

class ApiClient {
  ApiClient({String baseUrl = 'http://localhost:8010'})
      : _dio = Dio(BaseOptions(baseUrl: baseUrl));

  final Dio _dio;

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

  Future<List<Map<String, dynamic>>> search(String query, {String? kind}) async {
    final response = await _dio.get<List<dynamic>>(
      '/search',
      queryParameters: {
        'q': query,
        if (kind != null) 'kind': kind,
      },
    );
    return response.data!.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getComic(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/comics/$id');
    return response.data!;
  }

  Future<List<Map<String, dynamic>>> collection() async {
    final response = await _dio.get<List<dynamic>>('/collection');
    return response.data!.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> addToCollection(Map<String, dynamic> payload) async {
    final response = await _dio.post<Map<String, dynamic>>('/collection/add', data: payload);
    return response.data!;
  }

  Future<Map<String, dynamic>> pushSync(
    List<Map<String, dynamic>> changes, {
    required String deviceId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/sync/push',
      data: {'device_id': deviceId, 'changes': changes},
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> pullSync({DateTime? since}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/sync/pull',
      data: {'since': since?.toIso8601String()},
    );
    return response.data!;
  }
}
