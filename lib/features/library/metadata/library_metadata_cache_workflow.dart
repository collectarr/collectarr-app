import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/dto/metadata_search_query.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_query.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';

typedef LibraryBarcodeLookupResultCallback = void Function(
  LibraryBarcodeLookupResult result,
);

class LibraryBarcodeLookupResult {
  const LibraryBarcodeLookupResult.found({
    required this.code,
    required CatalogSearchCandidate this.item,
  }) : error = null;

  const LibraryBarcodeLookupResult.missing({
    required this.code,
    required Object this.error,
  }) : item = null;

  final String code;
  final CatalogSearchCandidate? item;
  final Object? error;

  bool get found => item != null;
}

Future<List<CatalogSearchCandidate>> searchAndCacheLibraryMetadata({
  required ApiClient api,
  required CatalogMediaKind kind,
  required CatalogTransportRepository catalog,
  required MetadataSearchQuery input,
}) async {
  final items = await searchLibraryMetadata(
    api,
    kind,
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
  required CatalogMediaKind kind,
  required CatalogTransportRepository catalog,
  required Iterable<String> codes,
  LibraryBarcodeLookupResultCallback? onResult,
}) async {
  final results = <LibraryBarcodeLookupResult>[];
  final foundItems = <CatalogSearchCandidate>[];
  for (final code in codes) {
    try {
      final item = await lookupLibraryBarcode(api, kind, code);
      foundItems.add(item);
      final result = LibraryBarcodeLookupResult.found(
        code: code,
        item: item,
      );
      results.add(result);
      onResult?.call(result);
    } catch (error) {
      final result = LibraryBarcodeLookupResult.missing(
        code: code,
        error: error,
      );
      results.add(result);
      onResult?.call(result);
    }
  }
  await catalog.upsertSearchCandidates(foundItems);
  return results;
}
