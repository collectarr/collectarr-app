import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/state/connection_settings_provider.dart';
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
  return client;
});
