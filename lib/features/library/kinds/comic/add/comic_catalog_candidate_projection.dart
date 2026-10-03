import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/remote/comic_core_mapper.dart';

CatalogSearchCandidate comicCatalogTransportFromCoreItem(
  CatalogSearchCandidate item,
) {
  return item.kindCapability.mapTransport((transport) {
    final metadata = ComicCoreMapper.fromCatalogItem(transport);
    return item.kindCapability.replacingKindData(metadata);
  });
}
