import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';

import 'catalog_import_snapshot.dart';

/// Search result that can cross into a mixed/global UI without exposing the
/// canonical catalog DTO. The DTO remains opaque until the catalog transport
/// repository persists the selected result.
final class CatalogSearchCandidate {
  const CatalogSearchCandidate._({
    required CatalogItemDto item,
    required this.summary,
    this.normalizedBarcode,
  }) : _item = item;

  factory CatalogSearchCandidate.fromTransport({
    required CatalogItemDto item,
    required CatalogDisplaySummary summary,
    String? normalizedBarcode,
  }) {
    return CatalogSearchCandidate._(
      item: item,
      summary: summary,
      normalizedBarcode: normalizedBarcode,
    );
  }

  /// Decodes a Core search response at the catalog transport boundary and
  /// immediately projects it to the small candidate shape used by mixed
  /// search/import hosts. The generated catalog DTO never leaves this
  /// transport object unless the user selects the candidate.
  factory CatalogSearchCandidate.fromApiJson({
    required Map<String, dynamic> json,
    Object? Function(Map<String, dynamic> payload)? metadataDecoder,
  }) {
    var item = CatalogItemDto.fromJson(json);
    if (metadataDecoder != null) {
      item = item.withKindMetadata(metadataDecoder(item.payload));
    }
    final rawBarcode = item.payload['barcode'] ?? item.payload['upc'];
    final normalizedBarcode =
        rawBarcode is String && rawBarcode.trim().isNotEmpty
            ? rawBarcode.replaceAll(RegExp(r'[^0-9A-Za-z]'), '').toUpperCase()
            : null;
    return CatalogSearchCandidate._(
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

  final CatalogItemDto _item;
  final CatalogDisplaySummary summary;
  final String? normalizedBarcode;

  String get id => summary.id;
  CatalogMediaKind get kind => summary.kind;
  String get title => summary.title;
  String? get subtitle => summary.subtitle;
  String? get imageUrl => summary.imageUrl;
  int? get releaseYear => _item.releaseYear;
  List<String> get searchAliases => _item.searchAliases ?? const [];

  CatalogItemDto toTransportItem() => _item;

  CatalogImportSnapshot toImportSnapshot() =>
      CatalogImportSnapshot.fromItem(_item);
}
