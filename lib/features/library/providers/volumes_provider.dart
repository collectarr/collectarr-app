import 'package:collectarr_app/core/models/season.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final volumesProvider = FutureProvider.autoDispose.family<List<Season>,
    ({String provider, String providerItemId})>((ref, params) async {
  final api = ref.watch(apiClientProvider);
  return api
      .getProviderVolumes(params.provider, params.providerItemId)
      .timeout(const Duration(seconds: 60));
});

final itemVolumesProvider = FutureProvider.autoDispose.family<
    List<Season>,
    ({String itemId, String? kind, bool canHydrateFromCore})>((ref, params) async {
  if (!params.canHydrateFromCore) {
    return const <Season>[];
  }
  final api = ref.watch(apiClientProvider);
  return api
      .getItemVolumes(params.itemId, kind: params.kind)
      .timeout(const Duration(seconds: 60));
});
