import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/collection_item_ref.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/book/data/local/book_collection_item_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_collection_item.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round trips the complete Book collection item', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final item = BookCollectionItem(
      id: const CollectionItemId('owned-book-1'),
      catalogRef: const CatalogEntityRef(
        kind: CatalogMediaKind.book,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'book-1',
      ),
      createdAt: DateTime.utc(2026, 4, 1),
      isDigital: false,
      condition: 'Fine',
      grade: '9.0',
      purchaseDate: DateTime.utc(2026, 4, 2),
      pricePaidCents: 2499,
      currency: 'USD',
      personalNotes: 'Signed hardcover',
      indexNumber: 3,
      tags: 'favorite,signed',
      updatedAt: DateTime.utc(2026, 4, 3),
      ownerUserId: 'user-1',
      ownerLabel: 'Book collector',
      locationId: 'shelf-books',
      purchaseStore: 'Independent bookstore',
      collectionStatus: 'owned',
      marketValueCents: 4000,
      details: const BookOwnedDetails(
        signedBy: 'Ursula K. Le Guin',
        dustJacketPresent: true,
        dustJacketCondition: 'Very good',
      ),
    );

    await db.into(db.bookCollectionItemsRows).insert(
          BookCollectionItemLocalMapper.toRow(item),
        );
    final row = await db.select(db.bookCollectionItemsRows).getSingle();
    final restored = BookCollectionItemLocalMapper.fromRow(row);

    expect(restored.id, item.id);
    expect(restored.itemId, item.itemId);
    expect(restored.createdAt?.toUtc(), item.createdAt);
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

  test('rejects Book collection items without a persisted identity', () {
    expect(
      () => BookCollectionItemLocalMapper.toRow(
        BookCollectionItem(
          id: const CollectionItemId(''),
          catalogRef: const CatalogEntityRef(
            kind: CatalogMediaKind.book,
            entityType: CatalogEntityTypeId.catalogItem,
            id: 'book-1',
          ),
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      ),
      throwsStateError,
    );
  });
}
