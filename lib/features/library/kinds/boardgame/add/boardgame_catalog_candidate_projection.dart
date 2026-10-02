import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';

CatalogSearchCandidate boardGameCatalogTransportFromCoreItem(
  CatalogSearchCandidate item,
) {
  return item.kindCapability.mapTransport((transport) {
    final metadata = BoardGameMetadata.fromJson(transport.payload);
    return item.kindCapability.withKindData(metadata);
  });
}
