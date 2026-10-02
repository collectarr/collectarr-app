import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';

CatalogSearchCandidate mangaCatalogTransportFromCoreItem(
  CatalogSearchCandidate item,
) {
  return item.kindCapability.mapTransport((transport) {
    final metadata = MangaMetadata.fromJson(transport.payload);
    return item.kindCapability.withKindData(metadata);
  });
}
