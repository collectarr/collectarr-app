import 'package:collectarr_app/core/models/season.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final volumesProvider =
    FutureProvider.family<List<Season>, ({String provider, String providerItemId})>(
        (ref, params) async {
  final api = ref.watch(apiClientProvider);
  return api.getProviderVolumes(params.provider, params.providerItemId);
});
