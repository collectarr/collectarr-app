import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';

/// Decodes the provider-ingest response into the Add transport wrapper.
///
/// This is deliberately kept at the provider transport boundary.  The Add
/// host receives an opaque [CatalogSearchCandidate] and dispatches it to the
/// owning kind before constructing any canonical domain object.
CatalogSearchCandidate libraryAddCatalogItemFromIngestResult(
  AdminMetadataItem item,
) {
  return CatalogSearchCandidate.fromJson({
    ...item.canonicalFieldValues,
    'id': item.id,
    'kind': item.kind,
    'title': item.title,
    if (item.itemNumber != null) 'item_number': item.itemNumber,
  });
}
