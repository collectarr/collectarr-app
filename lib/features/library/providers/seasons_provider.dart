import 'package:collectarr_app/core/models/season.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final seasonsProvider =
    FutureProvider.autoDispose.family<List<Season>, ({String provider, String providerItemId})>(
        (ref, params) async {
  final api = ref.watch(apiClientProvider);
  return api.getProviderSeasons(params.provider, params.providerItemId);
});

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
  final api = ref.watch(apiClientProvider);
  final itemId = params.itemId;
  final localMatch = _tmdbLocalIdPattern.firstMatch(itemId);
  if (localMatch != null) {
    final kind = localMatch.group(1)!;
    final tmdbId = localMatch.group(2)!;
    return api
        .getProviderSeasons('tmdb', '$kind:$tmdbId')
        .timeout(const Duration(seconds: 60));
  }
  final normalizedKind = params.kind?.trim().toLowerCase();
  if (normalizedKind == 'tv' && _uuidPattern.hasMatch(itemId)) {
    return api
        .getTvSeriesSeasons(itemId)
        .timeout(const Duration(seconds: 60));
  }
  if (!_uuidPattern.hasMatch(itemId)) {
    return const <Season>[];
  }
  return api
      .getItemSeasons(itemId, kind: params.kind)
      .timeout(const Duration(seconds: 60));
});
