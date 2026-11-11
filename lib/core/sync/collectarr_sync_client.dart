import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_retry.dart';
import 'package:dio/dio.dart';

class CollectarrSyncClient {
  CollectarrSyncClient({
    required String baseUrl,
    required String syncKey,
    String? accountToken,
    SyncRetryPolicy retryPolicy =
        const SyncRetryPolicy(isRetryable: _retrySyncResponse),
  })  : _syncKey = syncKey,
        _accountToken = accountToken,
        _retryPolicy = retryPolicy,
        _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 3),
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ));

  final Dio _dio;
  final String _syncKey;
  final String? _accountToken;
  final SyncRetryPolicy _retryPolicy;

  Future<Map<String, dynamic>> push({
    required String deviceId,
    required List<SyncChange> changes,
  }) async {
    return _retryPolicy.run(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/sync/push',
        data: {
          'device_id': deviceId,
          'changes': changes.map((change) => change.toWireJson()).toList(),
        },
        options: _options(),
      );
      return _responseData(response, '/sync/push');
    });
  }

  Future<Map<String, dynamic>> pull({DateTime? since}) async {
    return _retryPolicy.run(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/sync/pull',
        data: {
          if (since != null) 'since': since.toUtc().toIso8601String(),
        },
        options: _options(),
      );
      return _responseData(response, '/sync/pull');
    });
  }

  Future<Map<String, dynamic>> health() async {
    // Discovery must fail promptly when the service is stopped or unresponsive.
    final response = await _dio.get<Map<String, dynamic>>(
      '/health',
      options: _options().copyWith(
        sendTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(seconds: 3),
      ),
    );
    return _responseData(response, '/health');
  }

  Future<Map<String, dynamic>> status() async {
    return _retryPolicy.run(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/sync/status',
        options: _options(),
      );
      return _responseData(response, '/sync/status');
    });
  }

  /// Moves the shared key's library into the signed-in account. A key this
  /// server does not know gives no access to that library, so nothing moves.
  Future<void> claimSharedLibrary() async {
    await _retryPolicy.run(() async {
      try {
        await _dio.post<Map<String, dynamic>>(
          '/sync/claim-shared',
          options: _options(),
        );
      } on DioException catch (error) {
        if (error.response?.statusCode != 403) rethrow;
      }
    });
  }

  Future<List<Map<String, dynamic>>> devices() async {
    final response = await _dio.get<List<dynamic>>(
      '/sync/devices',
      options: _options(),
    );
    final data = response.data;
    if (data == null) {
      throw StateError('/sync/devices returned an empty response body');
    }
    return data.whereType<Map<String, dynamic>>().toList(growable: false);
  }

  Options _options() {
    final accountToken = _accountToken;
    return Options(headers: {
      if (_syncKey.isNotEmpty) 'X-Collectarr-Sync-Key': _syncKey,
      if (accountToken != null) 'Authorization': 'Bearer $accountToken',
    });
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

// A scheduled or manual sync can retry a broken connection later. Retrying it
// immediately only delays reporting that the service cannot be reached.
bool _retrySyncResponse(Object error) =>
    isTransientSyncError(error) && !isOfflineSyncError(error);
