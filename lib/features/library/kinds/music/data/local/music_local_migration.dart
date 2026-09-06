import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/features/library/kinds/music/data/local/music_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';

/// Backfills complete Music-owned rows from the common cache.
///
/// The common cache is intentionally left intact until all global collection
/// callers have moved to kind-owned repositories.
Future<void> migrateMusicOwnedItems(LocalDatabase db) async {
  final legacyRows = await db.select(db.ownedItemsCache).get();
  for (final row in legacyRows) {
    if (row.kind.trim().toLowerCase() != 'music') continue;
    final item = MusicOwnedItem(
      id: MusicOwnedItemId(row.id),
      catalogRef: CatalogEntityRef(
        kind: 'music',
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
      details: MusicOwnedDetails.fromJson(_decodeDetails(row.detailsJson)),
    );
    await db
        .into(db.musicOwnedItemsRows)
        .insertOnConflictUpdate(MusicLocalMapper.toOwnedItemRow(item));
  }
}

Map<String, dynamic> _decodeDetails(String? raw) {
  if (raw == null || raw.isEmpty) return const {};
  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
  } on Object {
    // Malformed legacy details are represented by Music defaults.
  }
  return const {};
}
