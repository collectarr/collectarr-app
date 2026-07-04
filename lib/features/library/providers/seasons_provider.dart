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

/// Matches local-synthetic item IDs created by TMDB import
/// (e.g. `tmdb-local:tv:12345`).
final _tmdbLocalIdPattern = RegExp(r'^tmdb-local:(\w+):(\d+)$');
final _uuidPattern = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  caseSensitive: false,
);

final itemSeasonsProvider = FutureProvider.autoDispose.family<
    List<Season>,
    ({String itemId, String? kind})>((ref, params) async {
  final itemId = params.itemId;
  final localMatch = _tmdbLocalIdPattern.firstMatch(itemId);
  if (localMatch != null) {
    final kind = localMatch.group(1)!;
    final tmdbId = localMatch.group(2)!;
    final api = ref.watch(apiClientProvider);
    return api
        .getProviderSeasons('tmdb', '$kind:$tmdbId')
        .timeout(const Duration(seconds: 60));
  }
  final normalizedKind = params.kind?.trim().toLowerCase();
  if (normalizedKind == 'tv' && _uuidPattern.hasMatch(itemId)) {
    final seasons = await ref.watch(tvSeriesSeasonsProvider(itemId).future);
    return _seasonDtosToSeasonModels(seasons);
  }
  return const <Season>[];
});

final seasonsByCatalogRefProvider =
    FutureProvider.autoDispose.family<List<Season>, CatalogEntityRef>(
  (ref, catalogRef) async {
    final kind = catalogRef.kind.trim().toLowerCase();
    if (kind == 'tv') {
      final seasons = await ref.watch(tvSeriesSeasonsProvider(catalogRef.id).future);
      return _seasonDtosToSeasonModels(seasons);
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
