import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';

CatalogSearchCandidate comicCatalogTransportFromCoreItem(
  CatalogSearchCandidate item,
) {
  return item.kindCapability.mapTransport((transport) {
    final metadata = ComicCatalogItem.fromJson(transport.kindData);
    return item.kindCapability.replacingKindData(metadata);
  });
}
