import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/domain/game_hardware_metadata.dart';

CatalogSearchCandidate gameHardwareCatalogTransportFromCoreItem(
  CatalogSearchCandidate item,
) {
  return item.kindCapability.mapTransport((transport) {
    final metadata = GameHardwareCatalogMetadata.fromJson(transport.payload);
    return item.kindCapability.replacingKindData(metadata);
  });
}
