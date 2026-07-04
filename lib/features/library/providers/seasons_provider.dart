import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/season.dart';
import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final seasonsProvider =
    FutureProvider.autoDispose.family<List<Season>, ({String provider, String providerItemId})>(
        (ref, params) async {
  final api = ref.watch(apiClientProvider);
  return api.getProviderSeasons(params.provider, params.providerItemId);
});

final tvSeriesSeasonsProvider = FutureProvider.autoDispose.family<List<TvSeasonDto>, String>(
  (ref, seriesId) async {
    final api = ref.watch(apiClientProvider);
    return api.getTvSeriesSeasonsDto(seriesId).timeout(const Duration(seconds: 60));
  },
);

final tvSeasonsBySeriesRefProvider = FutureProvider.autoDispose.family<
    List<Season>,
    String>((ref, seriesId) async {
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
        providerItemId: season.id,
        overview: season.description,
        airDate: season.releaseDate?.toIso8601String(),
        episodeCount: season.episodeCount,
        posterUrl: season.coverImageUrl,
        episodes: [
          for (final episode in season.episodes)
            Episode(
              episodeNumber: episode.episodeNumber?.toInt() ?? 0,
              title: episode.title,
              providerItemId: episode.id,
              overview: episode.description,
              airDate: episode.releaseDate?.toIso8601String(),
              runtimeMinutes: episode.runtimeMinutes,
            ),
        ],
      ),
  ];
}
