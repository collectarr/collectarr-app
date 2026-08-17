import 'dart:math';

import 'package:dio/dio.dart';

/// Configuration for HTTP retries with exponential backoff and 429 Retry-After support.
class ProviderRetryPolicy {
  const ProviderRetryPolicy({
    this.maxRetries = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 15),
    this.backoffMultiplier = 2.0,
    this.jitterFraction = 0.25,
  });

  final int maxRetries;
  final Duration initialDelay;
  final Duration maxDelay;
  final double backoffMultiplier;
  final double jitterFraction;

  /// Determine if a given DioException should trigger a retry attempt.
  bool shouldRetry(DioException error, int attempt) {
    if (attempt >= maxRetries) return false;

    // Do not retry on explicit cancellation
    if (error.type == DioExceptionType.cancel) return false;

    // Retry on timeouts and connection errors
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return true;
    }

    final statusCode = error.response?.statusCode;
    if (statusCode == null) return true;

    // 429 Too Many Requests
    if (statusCode == 429) return true;

    // 5xx Server Errors (500, 502, 503, 504)
    if (statusCode >= 500 && statusCode < 600) return true;

    // Do not retry client errors (400, 401, 403, 404, etc.)
    return false;
  }

  /// Calculate backoff delay for the given [attempt] (0-indexed), taking into account
  /// `Retry-After` or `RateLimit-Reset` response headers if present.
  Duration calculateDelay(DioException error, int attempt, {Random? random}) {
    final retryAfter = parseRetryAfter(error.response);
    if (retryAfter != null && retryAfter > Duration.zero) {
      // Add a small jitter to avoid thundering herd on reset
      final jitterMs = (random ?? Random()).nextInt(200);
      return retryAfter + Duration(milliseconds: jitterMs);
    }

    final rng = random ?? Random();
    final exponentialMs = initialDelay.inMilliseconds *
        pow(backoffMultiplier, attempt).toDouble();
    final jitterRange = exponentialMs * jitterFraction;
    final jitter =
        (rng.nextDouble() * 2 - 1) * jitterRange; // +/- jitterFraction
    final delayMs = (exponentialMs + jitter).clamp(
      0.0,
      maxDelay.inMilliseconds.toDouble(),
    );

    return Duration(milliseconds: delayMs.round());
  }

  /// Parse `Retry-After` or `RateLimit-Reset` from response headers.
  static Duration? parseRetryAfter(Response<dynamic>? response) {
    if (response == null) return null;

    final headers = response.headers;

    // 1. Check 'Retry-After'
    final retryAfterHeader =
        headers.value('retry-after') ?? headers.value('Retry-After');
    if (retryAfterHeader != null && retryAfterHeader.trim().isNotEmpty) {
      final seconds = int.tryParse(retryAfterHeader.trim());
      if (seconds != null) {
        return Duration(seconds: max(0, seconds));
      }
      // Try HTTP date format
      final httpDate = DateTime.tryParse(retryAfterHeader.trim());
      if (httpDate != null) {
        final diff = httpDate.difference(DateTime.now());
        return diff.isNegative ? Duration.zero : diff;
      }
    }

    // 2. Check 'X-RateLimit-Reset' / 'RateLimit-Reset' (Unix timestamp in seconds or milliseconds)
    final resetHeader = headers.value('x-ratelimit-reset') ??
        headers.value('X-RateLimit-Reset') ??
        headers.value('ratelimit-reset') ??
        headers.value('RateLimit-Reset');
    if (resetHeader != null && resetHeader.trim().isNotEmpty) {
      final resetVal = num.tryParse(resetHeader.trim());
      if (resetVal != null) {
        final nowMs = DateTime.now().millisecondsSinceEpoch;
        // If greater than 1e11 it's in milliseconds, otherwise in seconds
        final resetMs = resetVal > 100000000000
            ? resetVal.toInt()
            : (resetVal * 1000).toInt();
        final diffMs = resetMs - nowMs;
        if (diffMs > 0) {
          return Duration(milliseconds: diffMs);
        }
      }
    }

    return null;
  }
}
