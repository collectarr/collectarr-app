import 'dart:convert';

import 'package:collectarr_app/core/models/collection_item_ref.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_collection_item.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details.dart';
import 'package:drift/drift.dart';

/// Maps TV-collection item state to its App-owned Drift row.
///
/// TV catalog data lives in the shared Catalog Item cache; this mapper only
/// handles personal copy state.
final class TvLocalMapper {
  const TvLocalMapper._();

  static TvCollectionItemsRowsCompanion toCollectionItemRow(TvCollectionItem item) {
    if (item.id.value.isEmpty ||
        item.catalogRef.mediaKind != CatalogMediaKind.tv) {
      throw StateError('Cannot persist an invalid TvCollectionItem');
    }

    final details = item.details;
    return TvCollectionItemsRowsCompanion.insert(
      id: item.id.value,
      itemId: item.itemId,
      createdAt: Value(item.createdAt),
      isDigital: Value(item.isDigital),
      condition: Value(item.condition),
      grade: Value(item.grade),
      purchaseDate: Value(item.purchaseDate),
      pricePaidCents: Value(item.pricePaidCents),
      currency: Value(item.currency),
      personalNotes: Value(item.personalNotes),
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

  static TvCollectionItem fromCollectionItemRow(TvCollectionItemsRow row) {
    final catalogRef = CatalogEntityRef(
      kind: CatalogMediaKind.tv,
      entityType: CatalogEntityTypeId.catalogItem,
      id: row.itemId,
    );
    return TvCollectionItem(
      id: CollectionItemId(row.id),
      catalogRef: catalogRef,
      createdAt: row.createdAt,
      isDigital: row.isDigital,
      condition: row.condition,
      grade: row.grade,
      purchaseDate: row.purchaseDate,
      pricePaidCents: row.pricePaidCents,
      currency: row.currency,
      personalNotes: row.personalNotes,
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
