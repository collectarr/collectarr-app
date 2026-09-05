import 'package:collectarr_app/features/library/kinds/tv/data/remote/tv_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Loads TV hierarchy through TV-owned models rather than shared video types.
final tvSeasonsBySeriesProvider = FutureProvider.autoDispose
    .family<List<TvSeason>, String>((ref, seriesId) async {
  final api = ref.watch(apiClientProvider);
  final seasons = await api
      .getTvSeriesSeasonsDto(seriesId)
      .timeout(const Duration(seconds: 60));
  return [
    for (final season in seasons) TvCoreMapper.fromSeasonDto(season),
  ];
});

/// Typed TV hierarchy access for callers that already have a series identity.
final tvSeasonsBySeriesRefProvider = FutureProvider.autoDispose
    .family<List<TvSeason>, String>((ref, seriesId) async {
  return ref.watch(tvSeasonsBySeriesProvider(seriesId).future);
});

/// Typed TV hierarchy access at the generic catalog reference boundary.
final tvSeasonsByCatalogRefProvider = FutureProvider.autoDispose
    .family<List<TvSeason>, CatalogEntityRef>((ref, catalogRef) async {
  if (catalogRef.kind.trim().toLowerCase() != 'tv') {
    return const <TvSeason>[];
  }
  return ref.watch(tvSeasonsBySeriesRefProvider(catalogRef.id).future);
});
