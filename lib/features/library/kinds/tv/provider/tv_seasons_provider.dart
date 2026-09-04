import 'package:collectarr_app/features/library/kinds/tv/data/remote/tv_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';
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
