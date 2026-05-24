import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/logging/app_log.dart';
import 'package:collectarr_app/state/connection_settings_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final apiAuthTokenProvider = StateProvider<String?>((ref) => null);

final apiClientProvider = Provider<ApiClient>((ref) {
  final settings = ref.watch(connectionSettingsProvider);
  final token = ref.watch(apiAuthTokenProvider);
  final client = ApiClient(baseUrl: settings.metadataBaseUrl);
  if (token != null) {
    client.setToken(token);
  }
  // Log API errors centrally.
  client.addInterceptor(InterceptorsWrapper(
    onError: (DioException e, ErrorInterceptorHandler handler) {
      final method = e.requestOptions.method;
      final path = e.requestOptions.path;
      final status = e.response?.statusCode;
      final msg = status != null
          ? '$method $path → $status'
          : '$method $path → ${e.type.name}';
      ref.read(appLogProvider.notifier).error('api', msg,
          detail: e.message);
      handler.next(e);
    },
  ));
  return client;
});
