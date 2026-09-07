import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/library/config/library_facet_types.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';

/// Kind-owned facet execution contract.
///
/// The generic host may render the structural definitions and ask the
/// composition root for this module, but it does not interpret facet values
/// or metadata payloads itself.
final class LibraryFacetModule {
  const LibraryFacetModule({
    this.loadRows,
    this.getFacetValues,
    this.externalFacetBucketIdsByMode = const {},
  });

  final LibraryFacetRowsLoader? loadRows;
  final Iterable<String> Function(
          LibraryProjectionRuntime item, LibraryFacetIdRuntime facetId)?
      getFacetValues;
  final Map<String, LibraryFacetIdRuntime> externalFacetBucketIdsByMode;
}

typedef LibraryFacetRowsLoader = Future<List<Map<String, dynamic>>> Function({
  required LibraryFacetIdRuntime facetId,
  required Set<String> itemIds,
  required ApiClient api,
});
