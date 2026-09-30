import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/local/boardgame_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_ids.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round trips the complete BoardGame owned copy', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final item = BoardGameOwnedItem(
      id: const BoardGameOwnedCopyId('owned-boardgame-1'),
      catalogRef: const CatalogEntityRef(
        kind: CatalogMediaKind.boardgame,
        entityType: CatalogEntityTypeId('work'),
        id: 'boardgame-1',
      ),
      createdAt: DateTime.utc(2026, 4, 1),
      isDigital: false,
      targetRef: const CatalogEntityRef(
        kind: CatalogMediaKind.boardgame,
        entityType: CatalogEntityTypeId('edition'),
        id: 'edition-1',
      ),
      condition: 'Near Mint',
      grade: '9.5',
      purchaseDate: DateTime.utc(2026, 4, 2),
      pricePaidCents: 7999,
      currency: 'EUR',
      personalNotes: 'Deluxe components intact',
      quantity: 2,
      indexNumber: 3,
      tags: 'favorite,complete',
      updatedAt: DateTime.utc(2026, 4, 3),
      ownerUserId: 'user-1',
      ownerLabel: 'Board game collector',
      locationId: 'shelf-boardgame',
      purchaseStore: 'Specialist shop',
      collectionStatus: 'owned',
      marketValueCents: 9000,
      details: const BoardgameOwnedDetails(
        editionLanguage: 'English',
        editionRegion: 'US',
        componentCondition: 'Like New',
        componentCompleteness: 'Complete',
        missingPiecesNotes: 'None',
        isSleeved: true,
        hasCustomInsert: true,
        hasPaintedMiniatures: true,
        storageNotes: 'Shelf 3',
      ),
    );

    await db.into(db.boardGameOwnedItemsRows).insert(
          BoardGameLocalMapper.toOwnedItemRow(item),
        );
    final row = await db.select(db.boardGameOwnedItemsRows).getSingle();
    final restored = BoardGameLocalMapper.fromOwnedItemRow(row);

    expect(row.targetRefJson, isNotNull);
    expect(restored.id, item.id);
    expect(restored.itemId, item.itemId);
    expect(restored.createdAt?.toUtc(), item.createdAt);
    expect(restored.isDigital, false);
    expect(restored.targetRef?.entityType.apiValue, 'edition');
    expect(restored.targetRef?.id, 'edition-1');
    expect(restored.condition, item.condition);
    expect(restored.grade, item.grade);
    expect(restored.purchaseDate?.toUtc(), item.purchaseDate);
    expect(restored.pricePaidCents, item.pricePaidCents);
    expect(restored.currency, item.currency);
    expect(restored.personalNotes, item.personalNotes);
    expect(restored.quantity, item.quantity);
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

  test('requires persisted BoardGame owned-copy identities', () {
    expect(
      () => BoardGameLocalMapper.toOwnedItemRow(
        BoardGameOwnedItem(
          id: const BoardGameOwnedCopyId(''),
          catalogRef: const CatalogEntityRef(
            kind: CatalogMediaKind.boardgame,
            entityType: CatalogEntityTypeId('work'),
            id: 'boardgame-1',
          ),
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      ),
      throwsStateError,
    );
  });
}
