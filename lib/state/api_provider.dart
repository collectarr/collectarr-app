import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/state/connection_settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final settings = ref.watch(connectionSettingsProvider);
  return ApiClient(baseUrl: settings.metadataBaseUrl);
});
