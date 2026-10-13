import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_payload.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';

CatalogSearchCandidate tvCatalogTransportFromCoreItem(
  CatalogSearchCandidate item,
) {
  return item.kindCapability.mapTransport((transport) {
    final metadata = TvMetadata.fromJson(
      catalogTransportPayloadFor(transport),
    );
    return item.kindCapability.replacingKindData(metadata);
  });
}
