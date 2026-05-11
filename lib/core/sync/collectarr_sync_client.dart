import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:dio/dio.dart';

class CollectarrSyncClient {
  CollectarrSyncClient({
    required String baseUrl,
    required String syncKey,
  })  : _syncKey = syncKey,
        _dio = Dio(BaseOptions(baseUrl: baseUrl));

  final Dio _dio;
  final String _syncKey;

  Future<Map<String, dynamic>> push({
    required String deviceId,
    required List<SyncChange> changes,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/sync/push',
      data: {
        'device_id': deviceId,
        'changes': changes.map((change) => change.toWireJson()).toList(),
      },
      options: _options(),
    );
    return _responseData(response, '/sync/push');
  }

  Future<Map<String, dynamic>> pull({DateTime? since}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/sync/pull',
      data: {
        if (since != null) 'since': since.toUtc().toIso8601String(),
      },
      options: _options(),
    );
    return _responseData(response, '/sync/pull');
  }

  Future<Map<String, dynamic>> health() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/health',
      options: _options(),
    );
    return _responseData(response, '/health');
  }

  Options _options() {
    return Options(headers: {'X-Collectarr-Sync-Key': _syncKey});
  }

  Map<String, dynamic> _responseData(
    Response<Map<String, dynamic>> response,
    String endpoint,
  ) {
    final data = response.data;
    if (data == null) {
      throw StateError('$endpoint returned an empty response body');
    }
    return data;
  }
}
