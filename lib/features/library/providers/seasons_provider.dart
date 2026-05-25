import 'package:collectarr_app/core/models/season.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final seasonsProvider =
    FutureProvider.autoDispose.family<List<Season>, ({String provider, String providerItemId})>(
        (ref, params) async {
  final api = ref.watch(apiClientProvider);
  return api.getProviderSeasons(params.provider, params.providerItemId);
});

final itemSeasonsProvider =
    FutureProvider.autoDispose.family<List<Season>, String>((ref, itemId) async {
  final api = ref.watch(apiClientProvider);
  return api.getItemSeasons(itemId).timeout(const Duration(seconds: 60));
});
