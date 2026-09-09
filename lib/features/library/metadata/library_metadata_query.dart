import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/dto/metadata_search_query.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/models/library_entry.dart';

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

/// Searches the Core transport and immediately projects results into the
/// small shape required by mixed/global import UI. The full DTO remains
/// available only behind [CatalogSearchCandidate.toTransportItem].
Future<List<CatalogSearchCandidate>> searchLibraryMetadataCandidates(
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
  final items = await searchLibraryMetadata(
    api,
    type,
    query: query,
    series: series,
    issueNumber: issueNumber,
    publisher: publisher,
    year: year,
    barcode: barcode,
    limit: limit,
  );
  return [
    for (final item in items) _catalogSearchCandidateForItem(item),
  ];
}

CatalogSearchCandidate _catalogSearchCandidateForItem(CatalogItemDto item) {
  final projection = libraryCollectionCsvProjectionForKind(item.mediaKind);
  final workspaceEntry = LibraryWorkspaceEntry(
    itemId: item.id,
    catalogItem: item,
  );
  final cells = projection?.catalogCells(workspaceEntry);
  final rawBarcode = cells != null && cells.length > 10 ? cells[10] : null;
  final normalizedBarcode = rawBarcode == null || rawBarcode.trim().isEmpty
      ? null
      : MetadataSearchQuery.normalizeBarcode(rawBarcode);
  return CatalogSearchCandidate.fromTransport(
    item: item,
    summary: CatalogDisplaySummary.work(
      kind: item.mediaKind,
      id: item.id,
      title: item.title,
      imageUrl: item.displayCoverUrl,
    ),
    normalizedBarcode: normalizedBarcode,
  );
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
