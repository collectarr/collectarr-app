import 'dart:convert';

import 'package:collectarr_app/core/models/collection_item_ref.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_collection_item.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
import 'package:drift/drift.dart';

/// Maps Music-collection item data to its local Drift row.
final class MusicOwnedLocalMapper {
  const MusicOwnedLocalMapper._();

  static MusicCollectionItemsRowsCompanion toCollectionItemRow(MusicCollectionItem item) {
    if (item.id.value.isEmpty ||
        item.catalogRef.mediaKind != CatalogMediaKind.music) {
      throw StateError('Cannot persist an invalid MusicCollectionItem');
    }
    item.validateCatalogItemOwnership();

    final details = item.details;
    return MusicCollectionItemsRowsCompanion.insert(
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
      signedBy: Value(details.signedBy),
      lastCleanedDate: Value(details.lastCleanedDate),
      mediumDetailsJson: Value(
        jsonEncode(details.media.map((item) => item.toJson()).toList()),
      ),
    );
  }

  static MusicCollectionItem fromCollectionItemRow(MusicCollectionItemsRow row) {
    final catalogRef = CatalogEntityRef(
      kind: CatalogMediaKind.music,
      entityType: CatalogEntityTypeId.catalogItem,
      id: row.itemId,
    );
    final item = MusicCollectionItem(
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
      details: MusicOwnedDetails(
        media: [
          for (final value in _decodeMaps(row.mediumDetailsJson))
            MusicOwnedMediumDetails.fromJson(value),
        ],
        signedBy: row.signedBy,
        lastCleanedDate: row.lastCleanedDate,
      ),
    );
    item.validateCatalogItemOwnership();
    return item;
  }

  static List<Map<String, dynamic>> _decodeMaps(String raw) {
    dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return const <Map<String, dynamic>>[];
    }
    if (decoded is! List) return const <Map<String, dynamic>>[];
    return [
      for (final value in decoded)
        if (value is Map) Map<String, dynamic>.from(value),
    ];
  }
}
