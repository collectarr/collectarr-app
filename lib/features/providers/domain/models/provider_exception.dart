import 'package:flutter/foundation.dart';

@immutable
class ProviderException implements Exception {
  const ProviderException({
    required this.provider,
    required this.message,
    this.statusCode,
    this.retryAfter,
    this.cause,
  });

  final String provider;
  final String message;
  final int? statusCode;
  final Duration? retryAfter;
  final Object? cause;

  @override
  String toString() {
    final statusStr = statusCode != null ? ' (status: $statusCode)' : '';
    final retryStr =
        retryAfter != null ? ' (retry-after: ${retryAfter!.inSeconds}s)' : '';
    return 'ProviderException[$provider]$statusStr: $message$retryStr';
  }
}

class ProviderRateLimitException extends ProviderException {
  const ProviderRateLimitException({
    required super.provider,
    required super.message,
    super.statusCode = 429,
    super.retryAfter,
    super.cause,
  });
}

class ProviderAuthException extends ProviderException {
  const ProviderAuthException({
    required super.provider,
    required super.message,
    super.statusCode = 401,
    super.cause,
  });
}

class ProviderNotFoundException extends ProviderException {
  const ProviderNotFoundException({
    required super.provider,
    required super.message,
    super.statusCode = 404,
    super.cause,
  });
}

class ProviderNetworkException extends ProviderException {
  const ProviderNetworkException({
    required super.provider,
    required super.message,
    super.statusCode,
    super.cause,
  });
}

class ProviderTimeoutException extends ProviderException {
  const ProviderTimeoutException({
    required super.provider,
    required super.message,
    super.cause,
  });
}

class ProviderInvalidPayloadException extends ProviderException {
  const ProviderInvalidPayloadException({
    required super.provider,
    required super.message,
    super.cause,
  });
}

class ProviderCancelledException extends ProviderException {
  const ProviderCancelledException({
    required super.provider,
    super.message = 'Operation was cancelled',
    super.cause,
  });
}
