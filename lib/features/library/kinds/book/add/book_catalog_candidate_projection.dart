import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';

CatalogSearchCandidate bookCatalogTransportFromCoreItem(
  CatalogSearchCandidate item,
) {
  return item.kindCapability.mapTransport((transport) {
    final metadata = BookCatalogMetadata.fromJson(transport.kindData);
    return item.kindCapability.replacingKindData(metadata);
  });
}
