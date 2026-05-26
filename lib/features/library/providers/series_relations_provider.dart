import 'package:collectarr_app/core/models/series_relation.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final seriesRelationsProvider =
    FutureProvider.autoDispose.family<List<SeriesRelation>, String>(
        (ref, seriesId) async {
  final api = ref.watch(apiClientProvider);
  return api.getSeriesRelations(seriesId);
});
