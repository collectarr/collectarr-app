import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';

CatalogSearchCandidate movieCatalogTransportFromCoreItem(
  CatalogSearchCandidate item,
) {
  return item.kindCapability.mapTransport((transport) {
    final metadata = MovieCatalogMetadata.fromJson(transport.kindData);
    return item.kindCapability.replacingKindData(metadata);
  });
}
