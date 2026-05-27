import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/logging/recoverable_error.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final metadataProviderStatusesProvider =
    FutureProvider.autoDispose<Map<String, AdminProviderStatus>>((ref) async {
  final isAdmin = ref.watch(authControllerProvider).isAdmin;
  if (!isAdmin) return const {};
  final api = ref.watch(apiClientProvider);
  try {
    final statuses = await api.adminProviderStatuses();
    return {
      for (final status in statuses) status.name: status,
    };
  } catch (error, stackTrace) {
    logRecoverableError(
      source: 'provider_status',
      message: 'Failed to load admin provider statuses.',
      error: error,
      stackTrace: stackTrace,
    );
    return const {};
  }
});
