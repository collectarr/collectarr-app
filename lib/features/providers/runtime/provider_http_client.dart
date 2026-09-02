import 'dart:async';

import 'package:dio/dio.dart';

import '../domain/models/provider_exception.dart';
import 'provider_rate_limiter.dart';
import 'provider_retry_policy.dart';
import 'provider_runtime.dart';

/// Shared HTTP client for client-side provider adapters.
///
/// Features:
/// - Per-provider token bucket rate limiting.
/// - Automatic exponential backoff retries with jitter and 429 Retry-After parsing.
/// - Standard polite User-Agent and headers.
/// - Uniform timeouts.
/// - Translation of DioExceptions into typed [ProviderException] hierarchy.
class ProviderHttpClient {
  ProviderHttpClient({
    required this.provider,
    this.baseUrl = '',
    ProviderRateLimiter? rateLimiter,
    this.retryPolicy = const ProviderRetryPolicy(),
    this.customUserAgent,
    this.defaultHeaders = const {},
    this.connectTimeout = const Duration(seconds: 10),
    this.receiveTimeout = const Duration(seconds: 20),
    this.sendTimeout = const Duration(seconds: 10),
    Dio? dio,
  })  : rateLimiter =
            rateLimiter ?? ProviderRateLimiterRegistry().getLimiter(provider),
        _dio = dio ?? Dio() {
    _configureDio();
  }

  final String provider;
  final String baseUrl;
  final ProviderRateLimiter rateLimiter;
  final ProviderRetryPolicy retryPolicy;
  final String? customUserAgent;
  final Map<String, String> defaultHeaders;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;

  final Dio _dio;

  static const String defaultAppUserAgent =
      'Collectarr/0.2.1 (+https://github.com/collectarr/collectarr-app)';

  void _configureDio() {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      headers: {
        'User-Agent': customUserAgent ?? defaultAppUserAgent,
        'Accept': 'application/json',
        ...defaultHeaders,
      },
    );
  }

  /// Perform a GET request with rate limiting and retry handling.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProviderCancellationToken? cancellationToken,
  }) async {
    return _executeWithRetry<T>(
      () => _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: _combineCancelTokens(cancelToken, cancellationToken),
      ),
      cancellationToken: cancellationToken,
    );
  }

  /// Perform a POST request with rate limiting and retry handling.
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProviderCancellationToken? cancellationToken,
  }) async {
    return _executeWithRetry<T>(
      () => _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: _combineCancelTokens(cancelToken, cancellationToken),
      ),
      cancellationToken: cancellationToken,
    );
  }

  CancelToken _combineCancelTokens(
    CancelToken? dioToken,
    ProviderCancellationToken? appToken,
  ) {
    final token = dioToken ?? CancelToken();
    if (appToken != null) {
      if (appToken.isCancelled) {
        token.cancel('Cancelled by ProviderCancellationToken');
      } else {
        appToken.onCancelled(() {
          if (!token.isCancelled) {
            token.cancel('Cancelled by ProviderCancellationToken');
          }
        });
      }
    }
    return token;
  }

  Future<Response<T>> _executeWithRetry<T>(
    Future<Response<T>> Function() requestFn, {
    ProviderCancellationToken? cancellationToken,
  }) async {
    var attempt = 0;

    while (true) {
      if (cancellationToken?.isCancelled ?? false) {
        throw ProviderCancelledException(provider: provider);
      }

      // 1. Acquire rate limiter slot
      await rateLimiter.acquire();

      try {
        final response = await requestFn();
        return response;
      } on DioException catch (dioError) {
        if (dioError.type == DioExceptionType.cancel ||
            (cancellationToken?.isCancelled ?? false)) {
          throw ProviderCancelledException(
            provider: provider,
            cause: dioError,
          );
        }

        // Check for 429 to pause rate limiter
        if (dioError.response?.statusCode == 429) {
          final retryAfter =
              ProviderRetryPolicy.parseRetryAfter(dioError.response);
          if (retryAfter != null) {
            rateLimiter.pauseUntil(DateTime.now().add(retryAfter));
          }
        }

        if (retryPolicy.shouldRetry(dioError, attempt)) {
          final delay = retryPolicy.calculateDelay(dioError, attempt);
          attempt++;
          if (delay > Duration.zero) {
            await Future<void>.delayed(delay);
          }
          continue;
        }

        // Map to typed ProviderException
        throw _mapDioException(dioError);
      } catch (e) {
        if (e is ProviderException) rethrow;
        throw ProviderNetworkException(
          provider: provider,
          message: e.toString(),
          cause: e,
        );
      }
    }
  }

  ProviderException _mapDioException(DioException error) {
    final statusCode = error.response?.statusCode;
    final message = error.message ?? error.toString();

    if (error.type == DioExceptionType.cancel) {
      return ProviderCancelledException(
        provider: provider,
        cause: error,
      );
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return ProviderTimeoutException(
        provider: provider,
        message: 'Request timed out ($message)',
        cause: error,
      );
    }

    if (statusCode == 429) {
      final retryAfter = ProviderRetryPolicy.parseRetryAfter(error.response);
      return ProviderRateLimitException(
        provider: provider,
        message: 'Rate limit exceeded ($message)',
        retryAfter: retryAfter,
        cause: error,
      );
    }

    if (statusCode == 401 || statusCode == 403) {
      return ProviderAuthException(
        provider: provider,
        message: 'Authentication / Authorization failed ($statusCode)',
        statusCode: statusCode,
        cause: error,
      );
    }

    if (statusCode == 404) {
      return ProviderNotFoundException(
        provider: provider,
        message: 'Resource not found ($statusCode)',
        cause: error,
      );
    }

    return ProviderNetworkException(
      provider: provider,
      message: 'HTTP error ($statusCode): $message',
      statusCode: statusCode,
      cause: error,
    );
  }
}
