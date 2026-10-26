import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';

CatalogSearchCandidate gameCatalogTransportFromCoreItem(
  CatalogSearchCandidate item,
) {
  return item.kindCapability.mapTransport((transport) {
    final metadata = GameCatalogMetadata.fromJson(transport.payload);
    return item.kindCapability.replacingKindData(metadata);
  });
}
