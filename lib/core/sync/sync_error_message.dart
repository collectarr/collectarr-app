import 'package:collectarr_app/core/sync/sync_account.dart';
import 'package:dio/dio.dart';

/// The banner explains recovery; the application log keeps the original error.
String syncErrorMessage(Object error) {
  if (error is SyncAccountException) return error.message;
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
        return 'Cannot reach the sync service. Check that it is running and try '
            'again. Your changes are saved on this device.';
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'The sync service did not respond in time. Try again later. '
            'Your changes are saved on this device.';
      case DioExceptionType.badCertificate:
        return 'A secure connection to the sync service could not be established. '
            'Check its certificate and connection settings.';
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        if (status == 401 || status == 403) {
          return 'The sync service did not accept your credentials. Check your '
              'account and connection settings.';
        }
        if (status == 429) {
          return 'The sync service is busy. Try again later.';
        }
        if (status != null && status >= 500) {
          return 'The sync service is temporarily unavailable. Try again later. '
              'Your changes are saved on this device.';
        }
        break;
      case DioExceptionType.cancel:
        return 'Sync was cancelled. Your changes are saved on this device.';
      case DioExceptionType.transformTimeout:
      case DioExceptionType.unknown:
        break;
    }
  }
  return 'Sync could not finish. Open Logs for details. '
      'Your changes are saved on this device.';
}
