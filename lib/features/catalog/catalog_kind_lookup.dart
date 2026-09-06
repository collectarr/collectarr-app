import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_search_hit.dart';

export 'package:collectarr_app/core/models/catalog_search_hit.dart';

/// Typed lookup boundary for one catalog kind.
///
/// The returned hit is intentionally a small cross-kind projection. The
/// lookup itself must inspect the owning kind's typed repository/domain.
abstract interface class CatalogKindLookup {
  CatalogMediaKind get kind;

  Future<CatalogSearchHit?> findByBarcode(String barcode);

  Future<CatalogSearchHit?> findByTitleAndItemNumber({
    required String title,
    String? itemNumber,
  });
}

String normalizeCatalogLookupValue(String value) {
  return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
}

String normalizeCatalogLookupTitle(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

CatalogSearchHit catalogLookupHit({
  required CatalogMediaKind kind,
  required String id,
  required String title,
  String? subtitle,
}) {
  return CatalogSearchHit(
    ref: CatalogEntityRef(
      kind: kind.apiValue,
      entityType: CatalogEntityType.work,
      id: id,
    ),
    kind: kind,
    title: title,
    subtitle: subtitle,
  );
}
