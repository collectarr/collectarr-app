import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/dto/metadata_search_query.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_summary_registry.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:dio/dio.dart';

MetadataSearchQuery libraryMetadataSearchQuery(
  CatalogMediaKind kind, {
  String? query,
  String? series,
  String? issueNumber,
  String? publisher,
  int? year,
  String? barcode,
  int? limit,
  int? offset,
}) {
  return MetadataSearchQuery(
    query: query,
    kind: kind.apiValue,
    series: series,
    issueNumber: issueNumber,
    publisher: publisher,
    year: year,
    barcode: barcode,
    limit: limit,
    offset: offset,
  );
}

Future<List<CatalogSearchCandidate>> searchLibraryMetadata(
  ApiClient api,
  CatalogMediaKind kind, {
  String? query,
  String? series,
  String? issueNumber,
  String? publisher,
  int? year,
  String? barcode,
  int? limit,
  int? offset,
  CancelToken? cancelToken,
}) async {
  return (await searchLibraryMetadataPage(
    api,
    kind,
    query: query,
    series: series,
    issueNumber: issueNumber,
    publisher: publisher,
    year: year,
    barcode: barcode,
    limit: limit,
    offset: offset,
    cancelToken: cancelToken,
  ))
      .items;
}

final class LibraryMetadataSearchPage {
  const LibraryMetadataSearchPage({
    required this.items,
    required this.nextOffset,
    required this.hasMore,
  });

  final List<CatalogSearchCandidate> items;
  final int? nextOffset;
  final bool hasMore;
}

Future<LibraryMetadataSearchPage> searchLibraryMetadataPage(
  ApiClient api,
  CatalogMediaKind kind, {
  String? query,
  String? series,
  String? issueNumber,
  String? publisher,
  int? year,
  String? barcode,
  int? limit,
  int? offset,
  CancelToken? cancelToken,
}) async {
  final capability = libraryMetadataForKind(kind);
  final input = libraryMetadataSearchQuery(
    kind,
    query: query,
    series: series,
    issueNumber: issueNumber,
    publisher: publisher,
    year: year,
    barcode: barcode,
    limit: limit,
    offset: offset,
  );
  final requestedOffset = input.offset ?? 0;
  final page = capability.catalogSearchBuilder == null
      ? await api.searchMetadataPage(input, cancelToken: cancelToken)
      : await capability.catalogSearchBuilder!(
          api: api,
          query: input,
          cancelToken: cancelToken,
        );
  final decoder = capability.catalogMetadataDecoder;
  final items = [
    for (final row in page.items)
      CatalogSearchCandidate.fromApiJson(
        json: row,
        metadataDecoder: decoder,
        summaryBuilder: summarizeCatalogTransportPayload,
      ),
  ];
  return LibraryMetadataSearchPage(
    items: items,
    nextOffset: page.hasMore
        ? (page.nextOffset ?? requestedOffset + page.items.length)
        : null,
    hasMore: page.hasMore,
  );
}

/// Searches the Core transport and immediately projects results into the
/// small shape required by mixed/global import UI. The DTO stays inside the
/// candidate until kind-entry code crosses its explicit transport boundary.
Future<List<CatalogSearchCandidate>> searchLibraryMetadataCandidates(
  ApiClient api,
  CatalogMediaKind kind, {
  String? query,
  String? series,
  String? issueNumber,
  String? publisher,
  int? year,
  String? barcode,
  int? limit,
  int? offset,
}) async {
  return searchLibraryMetadata(
    api,
    kind,
    query: query,
    series: series,
    issueNumber: issueNumber,
    publisher: publisher,
    year: year,
    barcode: barcode,
    limit: limit,
    offset: offset,
  );
}

Future<CatalogSearchCandidate> lookupLibraryBarcode(
    ApiClient api, CatalogMediaKind kind, String barcode,
    {CancelToken? cancelToken}) async {
  final resolvedBarcode = resolveLibraryBarcodeForKind(kind, barcode);
  if (resolvedBarcode == null) {
    throw FormatException(
      'Barcode is not supported for ${kind.apiValue}: $barcode',
    );
  }
  final capability = libraryMetadataForKind(kind);
  final searchBuilder = capability.catalogSearchBuilder;
  final row = searchBuilder == null
      ? await api.lookupBarcode(
          resolvedBarcode,
          kind: kind.apiValue,
          cancelToken: cancelToken,
        )
      : (await searchBuilder(
          api: api,
          query: MetadataSearchQuery(
            kind: kind.apiValue,
            barcode: resolvedBarcode,
            limit: 1,
          ),
          cancelToken: cancelToken,
        ))
          .items
          .firstOrNull;
  if (row == null) {
    throw StateError(
        'Core found no catalog item for barcode $resolvedBarcode.');
  }
  return CatalogSearchCandidate.fromApiJson(
    json: row,
    metadataDecoder: capability.catalogMetadataDecoder,
    summaryBuilder: summarizeCatalogTransportPayload,
  );
}
