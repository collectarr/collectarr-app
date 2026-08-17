import 'dart:async';

import 'package:collectarr_app/features/providers/providers_sdk.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeHttpAdapter implements HttpClientAdapter {
  _FakeHttpAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('ProviderRateLimiter', () {
    test('acquires initial tokens without delay and handles pauses', () async {
      final limiter = ProviderRateLimiter(
        provider: 'test',
        maxRequests: 2,
        interval: const Duration(milliseconds: 100),
      );

      // First two tokens available immediately
      final sw = Stopwatch()..start();
      await limiter.acquire();
      await limiter.acquire();
      expect(sw.elapsedMilliseconds, lessThan(100));

      // Pause limiter for 150ms
      limiter.pauseUntil(DateTime.now().add(const Duration(milliseconds: 150)));
      await limiter.acquire();
      expect(sw.elapsedMilliseconds, greaterThanOrEqualTo(100));

      limiter.dispose();
    });

    test('registry returns preconfigured limiters for known providers', () {
      final registry = ProviderRateLimiterRegistry();
      final ol = registry.getLimiter('openlibrary');
      expect(ol.provider, 'openlibrary');
      expect(ol.maxRequests, 1);

      final anilist = registry.getLimiter('anilist');
      expect(anilist.provider, 'anilist');
      expect(anilist.maxRequests, 90);

      registry.dispose();
    });
  });

  group('ProviderRetryPolicy', () {
    const policy = ProviderRetryPolicy(maxRetries: 3);

    test('shouldRetry triggers on network errors, timeouts, 429, and 5xx', () {
      final timeoutErr = DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.connectionTimeout,
      );
      expect(policy.shouldRetry(timeoutErr, 0), isTrue);
      expect(policy.shouldRetry(timeoutErr, 3), isFalse); // Exceeded maxRetries

      final rateLimitErr = DioException(
        requestOptions: RequestOptions(),
        response: Response(
          requestOptions: RequestOptions(),
          statusCode: 429,
        ),
      );
      expect(policy.shouldRetry(rateLimitErr, 1), isTrue);

      final serverErr = DioException(
        requestOptions: RequestOptions(),
        response: Response(
          requestOptions: RequestOptions(),
          statusCode: 503,
        ),
      );
      expect(policy.shouldRetry(serverErr, 0), isTrue);

      final clientErr = DioException(
        requestOptions: RequestOptions(),
        response: Response(
          requestOptions: RequestOptions(),
          statusCode: 404,
        ),
      );
      expect(policy.shouldRetry(clientErr, 0), isFalse);

      final cancelErr = DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.cancel,
      );
      expect(policy.shouldRetry(cancelErr, 0), isFalse);
    });

    test('parseRetryAfter parses seconds and Unix reset timestamps', () {
      final respWithSec = Response(
        requestOptions: RequestOptions(),
        headers: Headers.fromMap({
          'retry-after': ['10'],
        }),
      );
      expect(ProviderRetryPolicy.parseRetryAfter(respWithSec)?.inSeconds, 10);

      final nowUnix = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final respWithReset = Response(
        requestOptions: RequestOptions(),
        headers: Headers.fromMap({
          'x-ratelimit-reset': ['${nowUnix + 5}'],
        }),
      );
      final resetDuration = ProviderRetryPolicy.parseRetryAfter(respWithReset);
      expect(resetDuration, isNotNull);
      expect(resetDuration!.inSeconds, inInclusiveRange(3, 6));
    });
  });

  group('ProviderHttpClient', () {
    test('configures default polite headers and user agent', () async {
      RequestOptions? recordedOptions;
      final dio = Dio();
      dio.httpClientAdapter = _FakeHttpAdapter((options) async {
        recordedOptions = options;
        return ResponseBody.fromString('{"ok": true}', 200, headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        });
      });

      final client = ProviderHttpClient(
        provider: 'test_prov',
        dio: dio,
        rateLimiter: ProviderRateLimiter(
          provider: 'test_prov',
          maxRequests: 10,
          interval: const Duration(seconds: 1),
        ),
      );

      final response =
          await client.get<Map<String, dynamic>>('https://example.com/api');
      expect(response.statusCode, 200);
      expect(recordedOptions?.headers['User-Agent'],
          ProviderHttpClient.defaultAppUserAgent);
      expect(recordedOptions?.headers['Accept'], 'application/json');
    });

    test('retries transient 500 error and succeeds on second attempt',
        () async {
      var callCount = 0;
      final dio = Dio();
      dio.httpClientAdapter = _FakeHttpAdapter((options) async {
        callCount++;
        if (callCount == 1) {
          return ResponseBody.fromString('Server Error', 500);
        }
        return ResponseBody.fromString('{"result": "success"}', 200, headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        });
      });

      final client = ProviderHttpClient(
        provider: 'test_prov',
        dio: dio,
        retryPolicy: const ProviderRetryPolicy(
          maxRetries: 2,
          initialDelay: Duration(milliseconds: 10),
        ),
        rateLimiter: ProviderRateLimiter(
          provider: 'test_prov',
          maxRequests: 10,
          interval: const Duration(seconds: 1),
        ),
      );

      final response =
          await client.get<Map<String, dynamic>>('https://example.com/api');
      expect(response.statusCode, 200);
      expect(callCount, 2);
    });

    test(
        'maps 401/403 to ProviderAuthException and 404 to ProviderNotFoundException',
        () async {
      final dio = Dio();
      dio.httpClientAdapter = _FakeHttpAdapter((options) async {
        if (options.path.contains('auth')) {
          return ResponseBody.fromString('Unauthorized', 401);
        }
        return ResponseBody.fromString('Not Found', 404);
      });

      final client = ProviderHttpClient(
        provider: 'test_prov',
        dio: dio,
        rateLimiter: ProviderRateLimiter(
          provider: 'test_prov',
          maxRequests: 10,
          interval: const Duration(seconds: 1),
        ),
      );

      expect(
        () => client.get<dynamic>('https://example.com/auth'),
        throwsA(isA<ProviderAuthException>()),
      );

      expect(
        () => client.get<dynamic>('https://example.com/missing'),
        throwsA(isA<ProviderNotFoundException>()),
      );
    });
  });
}
