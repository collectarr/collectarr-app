import 'package:collectarr_app/core/sync/sync_retry.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _dio(DioExceptionType type, {int? status}) {
  final options = RequestOptions(path: '/sync/push');
  return DioException(
    requestOptions: options,
    type: type,
    response: status == null
        ? null
        : Response(requestOptions: options, statusCode: status),
  );
}

void main() {
  group('isTransientSyncError', () {
    test('treats timeouts and connection errors as transient', () {
      expect(isTransientSyncError(_dio(DioExceptionType.connectionTimeout)),
          isTrue);
      expect(isTransientSyncError(_dio(DioExceptionType.sendTimeout)), isTrue);
      expect(isTransientSyncError(_dio(DioExceptionType.receiveTimeout)),
          isTrue);
      expect(isTransientSyncError(_dio(DioExceptionType.connectionError)),
          isTrue);
    });

    test('treats 429 and 5xx responses as transient', () {
      expect(
          isTransientSyncError(
              _dio(DioExceptionType.badResponse, status: 429)),
          isTrue);
      expect(
          isTransientSyncError(
              _dio(DioExceptionType.badResponse, status: 503)),
          isTrue);
    });

    test('treats 4xx (non-429) and non-Dio errors as permanent', () {
      expect(
          isTransientSyncError(
              _dio(DioExceptionType.badResponse, status: 400)),
          isFalse);
      expect(
          isTransientSyncError(
              _dio(DioExceptionType.badResponse, status: 409)),
          isFalse);
      expect(isTransientSyncError(StateError('nope')), isFalse);
    });
  });

  group('isOfflineSyncError', () {
    test('only network-level failures count as offline', () {
      expect(isOfflineSyncError(_dio(DioExceptionType.connectionError)),
          isTrue);
      expect(
          isOfflineSyncError(_dio(DioExceptionType.badResponse, status: 500)),
          isFalse);
      expect(isOfflineSyncError(StateError('nope')), isFalse);
    });
  });

  group('SyncRetryPolicy.run', () {
    test('retries transient failures then succeeds', () async {
      final delays = <Duration>[];
      final policy = SyncRetryPolicy(
        maxAttempts: 3,
        baseDelay: const Duration(milliseconds: 10),
        sleep: (d) async => delays.add(d),
      );
      var attempts = 0;

      final result = await policy.run(() async {
        attempts++;
        if (attempts < 3) {
          throw _dio(DioExceptionType.connectionError);
        }
        return 'ok';
      });

      expect(result, 'ok');
      expect(attempts, 3);
      expect(delays.length, 2);
      // Exponential backoff: 10ms then 20ms.
      expect(delays[0], const Duration(milliseconds: 10));
      expect(delays[1], const Duration(milliseconds: 20));
    });

    test('does not retry permanent failures', () async {
      final policy = SyncRetryPolicy(maxAttempts: 5, sleep: (_) async {});
      var attempts = 0;

      await expectLater(
        policy.run(() async {
          attempts++;
          throw _dio(DioExceptionType.badResponse, status: 400);
        }),
        throwsA(isA<DioException>()),
      );
      expect(attempts, 1);
    });

    test('gives up after maxAttempts and rethrows', () async {
      final policy = SyncRetryPolicy(maxAttempts: 2, sleep: (_) async {});
      var attempts = 0;

      await expectLater(
        policy.run(() async {
          attempts++;
          throw _dio(DioExceptionType.receiveTimeout);
        }),
        throwsA(isA<DioException>()),
      );
      expect(attempts, 2);
    });

    test('caps backoff at maxDelay', () async {
      final delays = <Duration>[];
      final policy = SyncRetryPolicy(
        maxAttempts: 5,
        baseDelay: const Duration(seconds: 1),
        maxDelay: const Duration(seconds: 2),
        sleep: (d) async => delays.add(d),
      );

      await expectLater(
        policy.run(() async => throw _dio(DioExceptionType.connectionError)),
        throwsA(isA<DioException>()),
      );

      expect(
          delays, everyElement(lessThanOrEqualTo(const Duration(seconds: 2))));
    });
  });
}
