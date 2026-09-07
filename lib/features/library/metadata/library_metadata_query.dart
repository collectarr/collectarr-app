import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/metadata_search_query.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

MetadataSearchQuery libraryMetadataSearchQuery(
  LibraryKindModule type, {
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
    kind: type.kind.apiValue,
    series: series,
    issueNumber: issueNumber,
    publisher: publisher,
    year: year,
    barcode: barcode,
    limit: limit,
  );
}

Future<List<CatalogItemDto>> searchLibraryMetadata(
  ApiClient api,
  LibraryKindModule type, {
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
  final decoder = libraryKindCatalogMetadataDecoderForKind(type.kind);
  return [
    for (final row in rows)
      () {
        final item = CatalogItemDto.fromJson(row);
        return decoder == null
            ? item
            : item.withKindMetadata(decoder(item.payload));
      }(),
  ];
}

Future<CatalogItemDto> lookupLibraryBarcode(
  ApiClient api,
  LibraryKindModule type,
  String barcode,
) async {
  final resolvedBarcode = resolveLibraryBarcodeForKind(type.kind, barcode);
  if (resolvedBarcode == null) {
    throw FormatException(
      'Barcode is not supported for ${type.kind.apiValue}: $barcode',
    );
  }
  final item = CatalogItemDto.fromJson(
    await api.lookupBarcode(
      resolvedBarcode,
      kind: type.kind.apiValue,
    ),
  );
  final decoder = libraryKindCatalogMetadataDecoderForKind(type.kind);
  return decoder == null ? item : item.withKindMetadata(decoder(item.payload));
}
