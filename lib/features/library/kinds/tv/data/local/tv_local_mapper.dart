import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details.dart';
import 'package:drift/drift.dart';

/// Maps TV-owned copy state to its App-owned Drift row.
///
/// TV catalog data lives in the shared Catalog Item cache; this mapper only
/// handles personal copy state.
final class TvLocalMapper {
  const TvLocalMapper._();

  static TvOwnedItemsRowsCompanion toOwnedItemRow(TvOwnedItem item) {
    if (item.id.value.isEmpty ||
        item.catalogRef.mediaKind != CatalogMediaKind.tv) {
      throw StateError('Cannot persist an invalid TvOwnedItem');
    }

    final details = item.details;
    return TvOwnedItemsRowsCompanion.insert(
      id: item.id.value,
      itemId: item.itemId,
      createdAt: Value(item.createdAt),
      isDigital: Value(item.isDigital),
      targetRefJson: Value(_encodeTargetRef(item.targetRef)),
      condition: Value(item.condition),
      grade: Value(item.grade),
      purchaseDate: Value(item.purchaseDate),
      pricePaidCents: Value(item.pricePaidCents),
      currency: Value(item.currency),
      personalNotes: Value(item.personalNotes),
      quantity: Value(item.quantity),
      indexNumber: Value(item.indexNumber),
      tags: Value(item.tags),
      updatedAt: item.updatedAt,
      deletedAt: Value(item.deletedAt),
      soldAt: Value(item.soldAt),
      sellPriceCents: Value(item.sellPriceCents),
      soldTo: Value(item.soldTo),
      ownerUserId: Value(item.ownerUserId),
      ownerLabel: Value(item.ownerLabel),
      locationId: Value(item.locationId),
      purchaseStore: Value(item.purchaseStore),
      collectionStatus: Value(item.collectionStatus),
      marketValueCents: Value(item.marketValueCents),
      features: Value(details.features),
      hdrFormatsJson: Value(jsonEncode(details.hdrFormats)),
      boxSetId: Value(details.boxSetId),
      boxSetName: Value(details.boxSetName),
      region: Value(details.region),
      packaging: Value(details.packaging),
      distributor: Value(details.distributor),
    );
  }

  static TvOwnedItem fromOwnedItemRow(TvOwnedItemsRow row) {
    final catalogRef = CatalogEntityRef(
      kind: CatalogMediaKind.tv,
      entityType: CatalogEntityTypeId.root,
      id: row.itemId,
    );
    return TvOwnedItem(
      id: TvOwnedCopyId(row.id),
      catalogRef: catalogRef,
      createdAt: row.createdAt,
      isDigital: row.isDigital,
      targetRef: _decodeTargetRef(row.targetRefJson),
      condition: row.condition,
      grade: row.grade,
      purchaseDate: row.purchaseDate,
      pricePaidCents: row.pricePaidCents,
      currency: row.currency,
      personalNotes: row.personalNotes,
      quantity: row.quantity,
      indexNumber: row.indexNumber,
      tags: row.tags,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
      soldAt: row.soldAt,
      sellPriceCents: row.sellPriceCents,
      soldTo: row.soldTo,
      ownerUserId: row.ownerUserId,
      ownerLabel: row.ownerLabel,
      locationId: row.locationId,
      purchaseStore: row.purchaseStore,
      collectionStatus: row.collectionStatus,
      marketValueCents: row.marketValueCents,
      details: TvOwnedDetails(
        features: row.features,
        hdrFormats: _decodeStrings(row.hdrFormatsJson),
        boxSetId: row.boxSetId,
        boxSetName: row.boxSetName,
        region: row.region,
        packaging: row.packaging,
        distributor: row.distributor,
      ),
    );
  }

  static String? _encodeTargetRef(CatalogEntityRef? targetRef) =>
      targetRef == null ? null : jsonEncode(targetRef.toJson());

  static CatalogEntityRef? _decodeTargetRef(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final decoded = _decodeJson(raw);
    if (decoded is! Map) return null;
    return CatalogEntityRef.fromJson(Map<String, Object?>.from(decoded));
  }

  static dynamic _decodeJson(String raw) {
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
  }

  static List<String> _decodeStrings(String raw) {
    final decoded = _decodeJson(raw);
    if (decoded is! List) return const <String>[];
    return decoded.whereType<String>().toList(growable: false);
  }
}
