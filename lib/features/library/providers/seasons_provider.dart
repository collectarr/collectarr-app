import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/season.dart';
import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/features/providers/providers_sdk.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final seasonsProvider = FutureProvider.autoDispose
    .family<List<Season>, ({String provider, String providerItemId})>(
        (ref, params) async {
  final registry = await ref.watch(providerRegistryProvider.future);
  final adapter = registry.get(params.provider);
  if (adapter != null) {
    try {
      final envelope =
          await adapter.fetchItem(params.providerItemId, kind: 'tv');
      if (envelope.normalized['seasons'] is List) {
        final seasonsList = envelope.normalized['seasons'] as List;
        return seasonsList
            .map((s) => Season.fromJson(Map<String, dynamic>.from(s as Map)))
            .toList();
      }
    } catch (_) {}
  }
  return const <Season>[];
});

final tvSeriesSeasonsProvider =
    FutureProvider.autoDispose.family<List<TvSeasonDto>, String>(
  (ref, seriesId) async {
    final api = ref.watch(apiClientProvider);
    return api
        .getTvSeriesSeasonsDto(seriesId)
        .timeout(const Duration(seconds: 60));
  },
);

final tvSeasonsBySeriesRefProvider = FutureProvider.autoDispose
    .family<List<Season>, String>((ref, seriesId) async {
  final seasons = await ref.watch(tvSeriesSeasonsProvider(seriesId).future);
  return _seasonDtosToSeasonModels(seasons);
});

final seasonsByCatalogRefProvider =
    FutureProvider.autoDispose.family<List<Season>, CatalogEntityRef>(
  (ref, catalogRef) async {
    final kind = catalogRef.kind.trim().toLowerCase();
    if (kind == 'tv') {
      return ref.watch(tvSeasonsBySeriesRefProvider(catalogRef.id).future);
    }
    return const <Season>[];
  },
);

List<Season> _seasonDtosToSeasonModels(List<TvSeasonDto> seasons) {
  return [
    for (final season in seasons)
      Season(
        seasonNumber: season.seasonNumber ?? 0,
        title: season.title,
        overview: season.description,
        episodeCount: season.episodeCount ?? 0,
        airDate: season.airDateValue?.toIso8601String(),
        posterUrl: season.coverImageUrlValue,
      ),
  ];
}
