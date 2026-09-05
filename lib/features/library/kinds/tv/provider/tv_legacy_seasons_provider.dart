import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/season.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';
import 'package:collectarr_app/features/library/kinds/tv/provider/tv_seasons_provider.dart';
import 'package:collectarr_app/features/providers/providers_sdk.dart';
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
            .map((season) =>
                Season.fromJson(Map<String, dynamic>.from(season as Map)))
            .toList();
      }
    } catch (_) {}
  }
  return const <Season>[];
});

final tvSeasonsBySeriesRefProvider = FutureProvider.autoDispose
    .family<List<Season>, String>((ref, seriesId) async {
  final seasons = await ref.watch(tvSeasonsBySeriesProvider(seriesId).future);
  return _seasonModelsToLegacySeasons(seasons);
});

final seasonsByCatalogRefProvider =
    FutureProvider.autoDispose.family<List<Season>, CatalogEntityRef>(
  (ref, catalogRef) async {
    if (catalogRef.kind.trim().toLowerCase() == 'tv') {
      return ref.watch(tvSeasonsBySeriesRefProvider(catalogRef.id).future);
    }
    return const <Season>[];
  },
);

List<Season> _seasonModelsToLegacySeasons(List<TvSeason> seasons) {
  return [
    for (final season in seasons)
      Season(
        seasonNumber: season.seasonNumber ?? 0,
        title: season.title ?? 'Season ${season.seasonNumber ?? 0}',
        overview: season.description,
        episodeCount: season.episodeCount ?? 0,
        airDate: season.airDate?.toIso8601String(),
        posterUrl: season.coverImageUrl,
      ),
  ];
}
