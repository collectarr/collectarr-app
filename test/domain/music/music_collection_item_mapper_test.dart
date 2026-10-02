import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/collection_item_ref.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/data/local/music_owned_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_collection_item.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Music-owned mapper round-trips a complete collection item', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final item = MusicCollectionItem(
      id: const CollectionItemId('owned-music-1'),
      catalogRef: const CatalogEntityRef(
        kind: CatalogMediaKind.music,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'album-1',
      ),
      createdAt: DateTime.utc(2026, 4, 1),
      isDigital: false,
      condition: 'Near Mint',
      grade: '9.5',
      purchaseDate: DateTime.utc(2026, 4, 2),
      pricePaidCents: 3999,
      currency: 'EUR',
      personalNotes: 'Signed first pressing',
      indexNumber: 3,
      tags: 'favorite,limited',
      updatedAt: DateTime.utc(2026, 4, 3),
      ownerUserId: 'user-1',
      ownerLabel: 'Music collector',
      locationId: 'shelf-music',
      purchaseStore: 'Specialist shop',
      collectionStatus: 'owned',
      marketValueCents: 4500,
      soldAt: DateTime.utc(2026, 5, 1),
      sellPriceCents: 5000,
      soldTo: 'Record collector',
      details: MusicOwnedDetails(
        signedBy: 'Roger Waters',
        lastCleanedDate: DateTime.utc(2026, 4, 4),
        media: const [
          MusicOwnedMediumDetails(
            mediumIndex: 1,
            storageDevice: 'Vinyl shelf',
            storageSlot: 'M-01',
            matrixRunouts: [
              MusicMatrixRunout(side: 'A', runoutText: 'SHVL 804 A-2'),
            ],
          ),
        ],
      ),
    );

    await db.into(db.musicCollectionItemsRows).insert(
          MusicOwnedLocalMapper.toCollectionItemRow(item),
        );
    final row = await db.select(db.musicCollectionItemsRows).getSingle();
    final restored = MusicOwnedLocalMapper.fromCollectionItemRow(row);

    expect(restored.id, item.id);
    expect(restored.itemId, item.itemId);
    expect(restored.catalogRef.entityType, CatalogEntityTypeId.catalogItem);
    expect(restored.toJson().containsKey('target_ref'), isFalse);
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
    expect(restored.soldAt?.toUtc(), item.soldAt);
    expect(restored.sellPriceCents, item.sellPriceCents);
    expect(restored.soldTo, item.soldTo);
    expect(restored.details.media, hasLength(1));
    expect(restored.details.media.single.storageDevice, 'Vinyl shelf');
    expect(restored.details.media.single.storageSlot, 'M-01');
    expect(restored.details.signedBy, item.details.signedBy);
    expect(restored.details.media.single.matrixRunouts, hasLength(1));
    expect(restored.details.media.single.matrixRunouts.single.runoutText,
        'SHVL 804 A-2');
  });
}
