import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';

CatalogSearchCandidate comicCatalogTransportFromCoreItem(
  CatalogSearchCandidate item,
) {
  return item.kindCapability.mapTransport((transport) {
    final metadata = ComicMedia.fromJson(transport.payload);
    return item.kindCapability.withKindMetadata(metadata);
  });
}

