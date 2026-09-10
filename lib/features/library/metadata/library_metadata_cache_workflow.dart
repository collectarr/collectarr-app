import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/dto/metadata_search_query.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_query.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';

typedef LibraryBarcodeLookupResultCallback = void Function(
  LibraryBarcodeLookupResult result,
);

class LibraryBarcodeLookupResult {
  const LibraryBarcodeLookupResult.found({
    required this.barcode,
    required CatalogSearchCandidate this.item,
  }) : error = null;

  const LibraryBarcodeLookupResult.missing({
    required this.barcode,
    required Object this.error,
  }) : item = null;

  final String barcode;
  final CatalogSearchCandidate? item;
  final Object? error;

  bool get found => item != null;
}

Future<List<CatalogSearchCandidate>> searchAndCacheLibraryMetadata({
  required ApiClient api,
  required LibraryKindModule type,
  required CatalogTransportRepository catalog,
  required MetadataSearchQuery input,
}) async {
  final items = await searchLibraryMetadata(
    api,
    type,
    query: input.query,
    series: input.series,
    issueNumber: input.issueNumber,
    publisher: input.publisher,
    year: input.year,
    barcode: input.barcode,
    limit: input.limit,
  );
  await catalog.upsertSearchCandidates(items);
  return items;
}

Future<List<LibraryBarcodeLookupResult>> lookupAndCacheLibraryBarcodes({
  required ApiClient api,
  required LibraryKindModule type,
  required CatalogTransportRepository catalog,
  required Iterable<String> barcodes,
  LibraryBarcodeLookupResultCallback? onResult,
}) async {
  final results = <LibraryBarcodeLookupResult>[];
  final foundItems = <CatalogSearchCandidate>[];
  for (final barcode in barcodes) {
    try {
      final item = await lookupLibraryBarcode(api, type, barcode);
      foundItems.add(item);
      final result = LibraryBarcodeLookupResult.found(
        barcode: barcode,
        item: item,
      );
      results.add(result);
      onResult?.call(result);
    } catch (error) {
      final result = LibraryBarcodeLookupResult.missing(
        barcode: barcode,
        error: error,
      );
      results.add(result);
      onResult?.call(result);
    }
  }
  await catalog.upsertSearchCandidates(foundItems);
  return results;
}
