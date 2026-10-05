import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_payload.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reads the contained seasons from a flat TV Catalog Item response.
final tvSeasonsByCatalogItemIdProvider = FutureProvider.autoDispose
    .family<List<TvSeasonMetadata>, String>((ref, itemId) async {
  final api = ref.watch(apiClientProvider);
  final response = await api
      .getCatalogItemJson(kind: CatalogMediaKind.tv, id: itemId)
      .timeout(const Duration(seconds: 60));
  final item = CatalogItemDto.fromJson(response);
  if (item.mediaKind != CatalogMediaKind.tv) {
    throw StateError('TV season lookup received ${item.kind} data');
  }
  return TvMetadata.fromJson(catalogTransportPayloadFor(item))
      .seasonsWithEpisodes;
});

/// Typed TV hierarchy access at the generic catalog reference boundary.
final tvSeasonsByCatalogRefProvider = FutureProvider.autoDispose
    .family<List<TvSeasonMetadata>, CatalogItemRef>((ref, catalogRef) async {
  if (catalogRef.kind != CatalogMediaKind.tv) {
    return const <TvSeasonMetadata>[];
  }
  return ref.watch(tvSeasonsByCatalogItemIdProvider(catalogRef.id).future);
});
