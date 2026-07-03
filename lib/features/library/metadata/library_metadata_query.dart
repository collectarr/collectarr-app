import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/generated/catalog_metadata_dto.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/metadata_search_query.dart';
import 'package:collectarr_app/core/api/mappers/catalog_typed_mapper.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
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
    kind: type.workspace.kind.apiValue,
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
  final rows = await searchLibraryMetadataDtos(
    api,
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
  return rows.map(catalogItemFromMetadataDto).toList(growable: false);
}

Future<List<CatalogMetadataDto>> searchLibraryMetadataDtos(
  ApiClient api,
  MetadataSearchQuery query,
) async {
  return api.searchMetadataDtos(query);
}

Future<CatalogItem> lookupLibraryBarcode(
  ApiClient api,
  LibraryTypeConfig type,
  String barcode,
) async {
  return catalogItemFromMetadataDto(
    await lookupLibraryBarcodeTyped(api, type, barcode),
  );
}

Future<CatalogMetadataDto> lookupLibraryBarcodeTyped(
  ApiClient api,
  LibraryTypeConfig type,
  String barcode,
) async {
  return api.lookupBarcodeDto(
    barcode,
    kind: type.workspace.kind.apiValue,
  );
}

Future<CatalogMetadataDto> lookupLibraryBarcodeDto(
  ApiClient api,
  LibraryTypeConfig type,
  String barcode,
) async {
  return lookupLibraryBarcodeTyped(api, type, barcode);
}

Future<List<ProviderCandidate>> searchLibraryProviderCandidates(
  ApiClient api,
  LibraryTypeConfig type, {
  String? provider,
  required String query,
  String? series,
  String? issueNumber,
  int? year,
  String? kindOverride,
}) async {
  final rows = await api.searchProvider(
    provider: provider,
    query: query,
    kind: kindOverride ?? type.workspace.kind.apiValue,
    series: series,
    issueNumber: issueNumber,
    year: year,
  );
  return rows
      .map(
        (row) => ProviderCandidate.fromJson(
          row,
          fallbackKind: type.workspace.kind.apiValue,
        ),
      )
      .toList(growable: false);
}
