import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/domain/game_toy_metadata.dart';

CatalogSearchCandidate gameToyCatalogTransportFromCoreItem(
  CatalogSearchCandidate item,
) {
  return item.kindCapability.mapTransport((transport) {
    final metadata = GameToyCatalogMetadata.fromJson(transport.payload);
    return item.kindCapability.replacingKindData(metadata);
  });
}
