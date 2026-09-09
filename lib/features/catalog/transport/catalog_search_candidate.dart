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

  final CatalogItemDto _item;
  final CatalogDisplaySummary summary;
  final String? normalizedBarcode;

  String get id => summary.id;
  CatalogMediaKind get kind => summary.kind;
  String get title => summary.title;
  String? get subtitle => summary.subtitle;
  String? get imageUrl => summary.imageUrl;

  CatalogItemDto toTransportItem() => _item;

  CatalogImportSnapshot toImportSnapshot() =>
      CatalogImportSnapshot.fromItem(_item);
}
