import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/book/data/local/book_owned_item_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_ids.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round trips the complete Book owned copy', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final item = BookOwnedItem(
      id: const BookOwnedCopyId('owned-book-1'),
      catalogRef: const CatalogEntityRef(
        kind: CatalogMediaKind.book,
        entityType: CatalogEntityTypeId('work'),
        id: 'book-1',
      ),
      createdAt: DateTime.utc(2026, 4, 1),
      isDigital: false,
      targetRef: const CatalogEntityRef(
        kind: CatalogMediaKind.book,
        entityType: CatalogEntityTypeId('edition'),
        id: 'edition-1',
      ),
      condition: 'Fine',
      grade: '9.0',
      purchaseDate: DateTime.utc(2026, 4, 2),
      pricePaidCents: 2499,
      currency: 'USD',
      personalNotes: 'Signed hardcover',
      quantity: 2,
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

    await db.into(db.bookOwnedItemsRows).insert(
          BookOwnedItemLocalMapper.toRow(item),
        );
    final row = await db.select(db.bookOwnedItemsRows).getSingle();
    final restored = BookOwnedItemLocalMapper.fromRow(row);

    expect(row.targetRefJson, isNotNull);
    expect(restored.id, item.id);
    expect(restored.itemId, item.itemId);
    expect(restored.createdAt?.toUtc(), item.createdAt);
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

  test('rejects Book owned copies without a persisted identity', () {
    expect(
      () => BookOwnedItemLocalMapper.toRow(
        BookOwnedItem(
          id: const BookOwnedCopyId(''),
          catalogRef: const CatalogEntityRef(
            kind: CatalogMediaKind.book,
            entityType: CatalogEntityTypeId('work'),
            id: 'book-1',
          ),
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      ),
      throwsStateError,
    );
  });
}
