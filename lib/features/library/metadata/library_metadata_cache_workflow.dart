import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/dto/metadata_search_query.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_query.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:dio/dio.dart';

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
  CancelToken? cancelToken,
}) async {
  return (await searchAndCacheLibraryMetadataPage(
    api: api,
    kind: kind,
    catalog: catalog,
    input: input,
    cancelToken: cancelToken,
  ))
      .items;
}

Future<LibraryMetadataSearchPage> searchAndCacheLibraryMetadataPage({
  required ApiClient api,
  required CatalogMediaKind kind,
  required CatalogTransportRepository catalog,
  required MetadataSearchQuery input,
  CancelToken? cancelToken,
}) async {
  final page = await searchLibraryMetadataPage(
    api,
    kind,
    query: input.query,
    series: input.series,
    issueNumber: input.issueNumber,
    publisher: input.publisher,
    year: input.year,
    barcode: input.barcode,
    limit: input.limit,
    offset: input.offset,
    cancelToken: cancelToken,
  );
  await catalog.upsertTransports(
    page.items.map((item) => item.toImportTransport()),
  );
  return page;
}

Future<List<LibraryBarcodeLookupResult>> lookupAndCacheLibraryBarcodes({
  required ApiClient api,
  required CatalogMediaKind kind,
  required CatalogTransportRepository catalog,
  required Iterable<String> codes,
  LibraryBarcodeLookupResultCallback? onResult,
  CancelToken? cancelToken,
}) async {
  final results = <LibraryBarcodeLookupResult>[];
  final foundItems = <CatalogSearchCandidate>[];
  for (final code in codes) {
    try {
      final item = await lookupLibraryBarcode(
        api,
        kind,
        code,
        cancelToken: cancelToken,
      );
      foundItems.add(item);
      final result = LibraryBarcodeLookupResult.found(
        code: code,
        item: item,
      );
      results.add(result);
      onResult?.call(result);
    } catch (error) {
      if (cancelToken?.isCancelled ?? false) rethrow;
      final result = LibraryBarcodeLookupResult.missing(
        code: code,
        error: error,
      );
      results.add(result);
      onResult?.call(result);
    }
  }
  await catalog.upsertTransports(
    foundItems.map((item) => item.toImportTransport()),
  );
  return results;
}
