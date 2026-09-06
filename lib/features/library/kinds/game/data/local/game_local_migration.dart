import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/features/library/kinds/game/data/local/game_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_ids.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details.dart';

/// Backfills complete Game-owned rows from the common cache.
Future<void> migrateGameOwnedItems(LocalDatabase db) async {
  final legacyRows = await db.select(db.ownedItemsCache).get();
  for (final row in legacyRows) {
    if (row.kind.trim().toLowerCase() != 'game') continue;
    final item = GameOwnedItem(
      id: GameOwnedItemId(row.id),
      catalogRef: CatalogEntityRef(
        kind: 'game',
        entityType: CatalogEntityType.work,
        id: row.itemId,
      ),
      createdAt: row.createdAt,
      isDigital: row.isDigital,
      anchor: PersonalItemAnchor.fromRaw(
        anchorType: row.anchorType,
        editionId: row.editionId,
        variantId: row.variantId,
        bundleReleaseId: row.bundleReleaseId,
      ),
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
      details: GameOwnedDetails.fromJson(_decodeDetails(row.detailsJson)),
    );
    await db
        .into(db.gameOwnedItemsRows)
        .insertOnConflictUpdate(GameLocalMapper.toOwnedItemRow(item));
  }
}

Map<String, dynamic> _decodeDetails(String? raw) {
  if (raw == null || raw.isEmpty) return const {};
  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
  } on Object {
    // Malformed legacy details are represented by Game defaults.
  }
  return const {};
}
