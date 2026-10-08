import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_kind_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_metadata_registry.dart';

/// Kind codecs own the semantic title and image projection used by mixed
/// catalog surfaces. This registry only dispatches to the matching codec.
final List<CatalogKindTransportBoundary> libraryCatalogTransportCodecs =
    List<CatalogKindTransportBoundary>.unmodifiable([
  for (final capability in collectarrKindMetadata.values)
    capability.catalogTransportCodec,
]);

CatalogDisplaySummary summarizeCatalogTransportPayload(CatalogItemDto item) {
  final codec = libraryCatalogTransportCodecs.firstWhere(
    (candidate) => candidate.kind == item.mediaKind,
    orElse: () => throw StateError(
      'No Catalog Item codec is registered for ${item.mediaKind.apiValue}.',
    ),
  );
  return codec.summarizeTransport(item);
}
