import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_ids.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/book/entries/book_entry_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('BookEntryRepository round-trips and soft-deletes local entries',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = BookEntryRepository(db);
    final item = BookLibraryEntry(
      id: const LibraryEntryId('entry-book-1'),
      catalogRef: const CatalogEntityRef(
        kind: CatalogMediaKind.book,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'entry-book-1',
      ),
      catalogData: const {'title': 'Project Hail Mary'},
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
      updatedAt: DateTime.utc(2026, 9, 1),
      ownerUserId: 'user-1',
      ownerLabel: 'Book collector',
      locationId: 'shelf-books',
      purchaseStore: 'Independent bookstore',
      collectionStatus: 'In Collection',
      marketValueCents: 4000,
      details: const BookEntryDetails(
        signedBy: 'Andy Weir',
        dustJacketPresent: true,
        dustJacketCondition: 'Fine',
      ),
    );

    await repository.upsert(item);

    final restored = await repository.findById(item.id);
    expect(restored?.catalogData, {'title': 'Project Hail Mary'});
    expect(restored?.itemId, item.itemId);
    expect(restored?.createdAt?.toUtc(), item.createdAt);
    expect(restored?.isDigital, false);
    expect(restored?.condition, 'Fine');
    expect(restored?.grade, '9.0');
    expect(restored?.purchaseDate?.toUtc(), item.purchaseDate);
    expect(restored?.pricePaidCents, 2499);
    expect(restored?.currency, 'USD');
    expect(restored?.personalNotes, 'Signed hardcover');
    expect(restored?.indexNumber, 3);
    expect(restored?.tags, 'favorite,signed');
    expect(restored?.ownerUserId, 'user-1');
    expect(restored?.ownerLabel, 'Book collector');
    expect(restored?.locationId, 'shelf-books');
    expect(restored?.purchaseStore, 'Independent bookstore');
    expect(restored?.collectionStatus, 'In Collection');
    expect(restored?.marketValueCents, 4000);
    expect(restored?.details.signedBy, 'Andy Weir');
    expect(restored?.details.dustJacketPresent, true);
    expect((await repository.listActive()).single.id, item.id);

    await repository.markDeleted(item, DateTime.utc(2026, 9, 2));

    expect(await repository.findById(item.id), isNotNull);
    expect(await repository.listActive(), isEmpty);
    expect((await repository.findById(item.id))?.isDeleted, isTrue);
  });

  test('BookEntryRepository rejects a non-Book reference', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = BookEntryRepository(db);
    final item = BookLibraryEntry(
      id: const LibraryEntryId('entry-book-invalid'),
      catalogRef: const CatalogEntityRef(
        kind: CatalogMediaKind.comic,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'comic-1',
      ),
      updatedAt: DateTime.utc(2026, 9, 1),
    );

    await expectLater(repository.upsert(item), throwsStateError);
  });
}
