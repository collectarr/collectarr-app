import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/collection_item_ref.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/game/data/local/game_collection_item_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_collection_item.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round trips the complete Game collection item', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final item = GameCollectionItem(
      id: const CollectionItemId('owned-game-1'),
      catalogRef: const CatalogEntityRef(
        kind: CatalogMediaKind.game,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'game-1',
      ),
      createdAt: DateTime.utc(2026, 4, 1),
      isDigital: false,
      condition: 'Near Mint',
      grade: '9.5',
      purchaseDate: DateTime.utc(2026, 4, 2),
      pricePaidCents: 5999,
      currency: 'EUR',
      personalNotes: 'Complete launch edition',
      indexNumber: 3,
      tags: 'favorite,complete',
      updatedAt: DateTime.utc(2026, 4, 3),
      ownerUserId: 'user-1',
      ownerLabel: 'Game collector',
      locationId: 'shelf-game',
      purchaseStore: 'Specialist shop',
      collectionStatus: 'owned',
      marketValueCents: 7500,
      details: const GameOwnedDetails(
        completeness: 'Complete in box',
        hasBox: true,
        hasManual: true,
        priceChartingId: 'pc-123',
        coreRegion: 'NTSC-U',
        valueIsLocked: false,
      ),
    );

    await db.into(db.gameCollectionItemsRows).insert(
          GameCollectionItemLocalMapper.toRow(item),
        );
    final row = await db.select(db.gameCollectionItemsRows).getSingle();
    final restored = GameCollectionItemLocalMapper.fromRow(row);

    expect(restored.id, item.id);
    expect(restored.itemId, item.itemId);
    expect(restored.createdAt?.toUtc(), item.createdAt);
    expect(restored.isDigital, false);
    expect(restored.catalogRef.entityType, CatalogEntityTypeId.catalogItem);
    expect(restored.catalogRef.id, 'game-1');
    expect(item.toJson(), isNot(contains('target_ref')));
    expect(restored.condition, item.condition);
    expect(restored.grade, item.grade);
    expect(restored.purchaseDate?.toUtc(), item.purchaseDate);
    expect(restored.pricePaidCents, item.pricePaidCents);
    expect(restored.currency, item.currency);
    expect(restored.personalNotes, item.personalNotes);
    expect(restored.indexNumber, item.indexNumber);
    expect(restored.tags, item.tags);
    expect(restored.updatedAt.toUtc(), item.updatedAt);
    expect(restored.ownerUserId, item.ownerUserId);
    expect(restored.ownerLabel, item.ownerLabel);
    expect(restored.locationId, item.locationId);
    expect(restored.purchaseStore, item.purchaseStore);
    expect(restored.collectionStatus, item.collectionStatus);
    expect(restored.marketValueCents, item.marketValueCents);
    expect(restored.details, item.details);
  });

  test('rejects Game collection items without a persisted identity', () {
    expect(
      () => GameCollectionItemLocalMapper.toRow(
        GameCollectionItem(
          id: const CollectionItemId(''),
          catalogRef: const CatalogEntityRef(
            kind: CatalogMediaKind.game,
            entityType: CatalogEntityTypeId.catalogItem,
            id: 'game-1',
          ),
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      ),
      throwsStateError,
    );
  });
}
