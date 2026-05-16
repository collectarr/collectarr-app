import 'dart:async';

import 'package:dio/dio.dart';

class ConnectionDiagnostics {
  const ConnectionDiagnostics._();

  static String metadataError(Object error, String baseUrl) {
    return _formatError(
      error,
      serviceName: 'metadata server',
      baseUrl: baseUrl,
    );
  }

  static String syncError(Object error, String baseUrl) {
    return _formatError(
      error,
      serviceName: 'sync service',
      baseUrl: baseUrl,
      credentialName: 'Sync key',
    );
  }

  static String _formatError(
    Object error, {
    required String serviceName,
    required String baseUrl,
    String? credentialName,
  }) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final responseCode = _responseCode(error.response?.data);
      if (statusCode == 401) {
        if (responseCode == 'missing_bearer_token') {
          return 'Sign in to the metadata server to use this action.';
        }
        if (responseCode == 'invalid_bearer_token' ||
            responseCode == 'user_not_found') {
          return 'Metadata session is no longer valid. Sign in again.';
        }
      }
      final responseDetail = _responseDetail(error.response?.data);
      if (responseDetail != null) {
        return '$responseDetail${statusCode == null ? '' : ' (HTTP $statusCode).'}';
      }
      if (statusCode == 401 || statusCode == 403) {
        if (credentialName != null) {
          return '$credentialName rejected ($statusCode). Check the configured key.';
        }
        return 'Request rejected ($statusCode). Check $serviceName access.';
      }
      if (statusCode != null) {
        return '${_capitalize(serviceName)} returned HTTP $statusCode.';
      }
      return switch (error.type) {
        DioExceptionType.connectionError ||
        DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.sendTimeout =>
          'Could not reach $serviceName at ${baseUrl.trim()}.',
        DioExceptionType.badCertificate =>
          'TLS certificate rejected for $serviceName.',
        DioExceptionType.cancel => 'Connection check was cancelled.',
        DioExceptionType.badResponse =>
          'Unexpected response from $serviceName.',
        DioExceptionType.unknown =>
          'Could not check $serviceName: ${_cleanMessage(error.message)}',
      };
    }
    if (error is FormatException) {
      return 'Could not read $serviceName response: ${error.message}';
    }
    if (error is TimeoutException) {
      return 'Timed out waiting for $serviceName at ${baseUrl.trim()}.';
    }
    if (error is StateError) {
      return 'Could not read $serviceName response.';
    }
    return 'Could not check $serviceName: $error';
  }

  static String _cleanMessage(String? message) {
    final value = message?.trim();
    if (value == null || value.isEmpty) {
      return 'unknown error';
    }
    return value;
  }

  static String? _responseDetail(Object? data) {
    if (data is Map) {
      final detail = data['detail']?.toString().trim();
      if (detail != null && detail.isNotEmpty) {
        return detail;
      }
    }
    return null;
  }

  static String? _responseCode(Object? data) {
    if (data is Map) {
      final code = data['code']?.toString().trim();
      if (code != null && code.isNotEmpty) {
        return code;
      }
    }
    return null;
  }

  static String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}
