import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/collection_item_ref.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_collection_item.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details.dart';
import 'package:drift/drift.dart';

final class GameCollectionItemLocalMapper {
  const GameCollectionItemLocalMapper._();

  static GameCollectionItemsRowsCompanion toRow(GameCollectionItem item) {
    if (item.id.value.isEmpty ||
        item.catalogRef.mediaKind != CatalogMediaKind.game) {
      throw StateError('Cannot persist an invalid GameCollectionItem');
    }

    final details = item.details;
    return GameCollectionItemsRowsCompanion.insert(
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
      completeness: Value(details.completeness),
      hasBox: Value(details.hasBox),
      hasManual: Value(details.hasManual),
      priceChartingId: Value(details.priceChartingId),
      coreRegion: Value(details.coreRegion),
      valueIsLocked: Value(details.valueIsLocked),
    );
  }

  static GameCollectionItem fromRow(GameCollectionItemsRow row) {
    final catalogRef = CatalogEntityRef(
      kind: CatalogMediaKind.game,
      entityType: CatalogEntityTypeId.catalogItem,
      id: row.itemId,
    );
    return GameCollectionItem(
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
      details: GameOwnedDetails(
        completeness: row.completeness,
        hasBox: row.hasBox,
        hasManual: row.hasManual,
        priceChartingId: row.priceChartingId,
        coreRegion: row.coreRegion,
        valueIsLocked: row.valueIsLocked,
      ),
    );
  }

}
