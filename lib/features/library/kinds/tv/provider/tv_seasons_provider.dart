import 'package:collectarr_app/features/library/kinds/tv/data/remote/tv_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reads the contained seasons from a flat TV Catalog Item response.
final tvSeasonsByCatalogItemIdProvider = FutureProvider.autoDispose
    .family<List<TvSeason>, String>((ref, itemId) async {
  final api = ref.watch(apiClientProvider);
  final item = await api
      .getCatalogItemJson(kind: CatalogMediaKind.tv, id: itemId)
      .timeout(const Duration(seconds: 60));
  return TvCoreMapper.fromCatalogItemJson(item).seasons;
});

/// Typed TV hierarchy access at the generic catalog reference boundary.
final tvSeasonsByCatalogRefProvider = FutureProvider.autoDispose
    .family<List<TvSeason>, CatalogEntityRef>((ref, catalogRef) async {
  if (catalogRef.mediaKind != CatalogMediaKind.tv) {
    return const <TvSeason>[];
  }
  return ref.watch(tvSeasonsByCatalogItemIdProvider(catalogRef.id).future);
});
