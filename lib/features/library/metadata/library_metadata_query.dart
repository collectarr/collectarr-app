import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/metadata_search_query.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/api/library_metadata_transport_codec.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

MetadataSearchQuery libraryMetadataSearchQuery(
  LibraryKindRuntime type, {
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

Future<List<LibraryMetadataItem>> searchLibraryMetadata(
  ApiClient api,
  LibraryKindRuntime type, {
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
  return rows
      .map(LibraryMetadataTransportCodec.fromMetadataMap)
      .toList(growable: false);
}

Future<LibraryMetadataItem> lookupLibraryBarcode(
  ApiClient api,
  LibraryKindRuntime type,
  String barcode,
) async {
  return LibraryMetadataTransportCodec.fromMetadataMap(
    await api.lookupBarcode(
      barcode,
      kind: type.kind.apiValue,
    ),
  );
}
