import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';

CatalogSearchCandidate animeCatalogTransportFromCoreItem(
  CatalogSearchCandidate item,
) {
  return item.kindCapability.mapTransport((transport) {
    final metadata = AnimeMetadata.fromJson(transport.payload);
    return item.kindCapability.withKindData(metadata);
  });
}
