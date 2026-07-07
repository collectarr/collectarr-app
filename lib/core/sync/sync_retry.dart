import 'dart:async';
import 'dart:math' as math;

import 'package:dio/dio.dart';

/// Returns `true` when [error] looks like a transient network/server condition
/// that is worth retrying (connection dropped, timeouts, 429, or 5xx), rather
/// than a deterministic failure (4xx other than 429, parsing errors, etc.).
bool isTransientSyncError(Object error) {
  if (error is! DioException) {
    return false;
  }
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return true;
    case DioExceptionType.badResponse:
      final status = error.response?.statusCode;
      if (status == null) {
        return false;
      }
      return status == 429 || status >= 500;
    case DioExceptionType.cancel:
    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
      return false;
  }
}

/// Returns `true` when [error] should put the client into an "offline" state
/// (the request never reached, or was not answered by, the server).
bool isOfflineSyncError(Object error) {
  if (error is! DioException) {
    return false;
  }
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return true;
    case DioExceptionType.badResponse:
    case DioExceptionType.cancel:
    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
      return false;
  }
}

/// Exponential-backoff retry policy for transient sync failures.
///
/// The sync protocol is idempotent per `(entityType, entityId, clientChangedAt)`,
/// so re-issuing a push/pull after a transient failure is safe.
class SyncRetryPolicy {
  const SyncRetryPolicy({
    this.maxAttempts = 3,
    this.baseDelay = const Duration(milliseconds: 400),
    this.maxDelay = const Duration(seconds: 5),
    this.isRetryable = isTransientSyncError,
    Future<void> Function(Duration)? sleep,
  }) : _sleep = sleep;

  /// Total number of attempts (including the first). Must be >= 1.
  final int maxAttempts;

  /// Delay before the first retry; doubles each subsequent attempt.
  final Duration baseDelay;

  /// Upper bound applied to the exponential backoff delay.
  final Duration maxDelay;

  /// Predicate deciding whether a thrown error is worth retrying.
  final bool Function(Object error) isRetryable;

  final Future<void> Function(Duration)? _sleep;

  /// A policy that performs a single attempt (no retries). Useful for tests.
  static const SyncRetryPolicy none = SyncRetryPolicy(maxAttempts: 1);

  Duration _delayForAttempt(int attempt) {
    final millis = baseDelay.inMilliseconds * math.pow(2, attempt - 1);
    final capped = math.min(millis.toDouble(), maxDelay.inMilliseconds.toDouble());
    return Duration(milliseconds: capped.round());
  }

  /// Runs [action], retrying transient failures with exponential backoff.
  Future<T> run<T>(Future<T> Function() action) async {
    var attempt = 0;
    while (true) {
      attempt++;
      try {
        return await action();
      } catch (error) {
        if (attempt >= maxAttempts || !isRetryable(error)) {
          rethrow;
        }
        final delay = _delayForAttempt(attempt);
        if (_sleep != null) {
          await _sleep(delay);
        } else {
          await Future<void>.delayed(delay);
        }
      }
    }
  }
}
