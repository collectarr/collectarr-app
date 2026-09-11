import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/dto/metadata_search_query.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';

MetadataSearchQuery libraryMetadataSearchQuery(
  CatalogMediaKind kind, {
  String? query,
  String? series,
  String? issueNumber,
  String? publisher,
  int? year,
  String? barcode,
  int? limit,
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
}) async {
  final rows = await api.searchMetadata(
    libraryMetadataSearchQuery(
      kind,
      query: query,
      series: series,
      issueNumber: issueNumber,
      publisher: publisher,
      year: year,
      barcode: barcode,
      limit: limit,
    ),
  );
  final decoder =
      libraryKindRegistrationForKind(kind).metadata.catalogMetadataDecoder;
  return [
    for (final row in rows)
      CatalogSearchCandidate.fromApiJson(
        json: row,
        metadataDecoder: decoder,
      ),
  ];
}

/// Searches the Core transport and immediately projects results into the
/// small shape required by mixed/global import UI. The full DTO remains
/// available only behind [CatalogSearchCandidate.toImportSnapshot].
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
  );
}

Future<CatalogSearchCandidate> lookupLibraryBarcode(
  ApiClient api,
  CatalogMediaKind kind,
  String barcode,
) async {
  final resolvedBarcode = resolveLibraryBarcodeForKind(kind, barcode);
  if (resolvedBarcode == null) {
    throw FormatException(
      'Barcode is not supported for ${kind.apiValue}: $barcode',
    );
  }
  final decoder =
      libraryKindRegistrationForKind(kind).metadata.catalogMetadataDecoder;
  return CatalogSearchCandidate.fromApiJson(
    json: await api.lookupBarcode(
      resolvedBarcode,
      kind: kind.apiValue,
    ),
    metadataDecoder: decoder,
  );
}
