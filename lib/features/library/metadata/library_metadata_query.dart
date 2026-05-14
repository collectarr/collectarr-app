import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/metadata_search_query.dart';
import 'package:collectarr_app/features/library/library_type_config.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';

MetadataSearchQuery libraryMetadataSearchQuery(
  LibraryTypeConfig type, {
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
    kind: type.workspace.kind,
    series: series,
    issueNumber: issueNumber,
    publisher: publisher,
    year: year,
    barcode: barcode,
    limit: limit,
  );
}

Future<List<CatalogItem>> searchLibraryMetadata(
  ApiClient api,
  LibraryTypeConfig type, {
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
      type,
      query: query,
      series: series,
      issueNumber: issueNumber,
      publisher: publisher,
      year: year,
      barcode: barcode,
      limit: limit,
    ),
  );
  return rows.map(CatalogItem.fromJson).toList(growable: false);
}

Future<CatalogItem> lookupLibraryBarcode(
  ApiClient api,
  LibraryTypeConfig type,
  String barcode,
) async {
  final row = await api.lookupBarcode(
    barcode,
    kind: type.workspace.kind,
  );
  return CatalogItem.fromJson(row);
}

Future<List<ProviderCandidate>> searchLibraryProviderCandidates(
  ApiClient api,
  LibraryTypeConfig type, {
  required String provider,
  required String query,
}) async {
  final rows = await api.searchProvider(
    provider: provider,
    query: query,
    kind: type.workspace.kind,
  );
  return rows
      .map(
        (row) => ProviderCandidate.fromJson(
          row,
          fallbackKind: type.workspace.kind,
        ),
      )
      .toList(growable: false);
}
