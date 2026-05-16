import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final metadataProviderStatusesProvider =
    FutureProvider<Map<String, AdminProviderStatus>>((ref) async {
  final api = ref.watch(apiClientProvider);
  try {
    final statuses = await api.adminProviderStatuses();
    return {
      for (final status in statuses) status.name: status,
    };
  } catch (_) {
    return const {};
  }
});
