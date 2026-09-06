import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_ids.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('BookOwnedRepository round-trips and soft-deletes copies', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = BookOwnedRepository(db);
    final item = BookOwnedItem(
      id: const BookOwnedItemId('owned-book-1'),
      catalogRef: const CatalogEntityRef(
        kind: 'book',
        entityType: CatalogEntityType.work,
        id: 'book-1',
      ),
      condition: 'Fine',
      quantity: 1,
      updatedAt: DateTime.utc(2026, 9, 1),
      details: const BookOwnedDetails(
        signedBy: 'Andy Weir',
        dustJacketPresent: true,
        dustJacketCondition: 'Fine',
      ),
    );

    await repository.upsert(item);

    final restored = await repository.findById(item.id);
    expect(restored?.itemId, item.itemId);
    expect(restored?.condition, 'Fine');
    expect(restored?.details.signedBy, 'Andy Weir');
    expect(restored?.details.dustJacketPresent, true);
    expect((await repository.listActive()).single.id, item.id);

    await repository.markDeleted(item, DateTime.utc(2026, 9, 2));

    expect(await repository.findById(item.id), isNotNull);
    expect(await repository.listActive(), isEmpty);
    expect((await repository.findById(item.id))?.isDeleted, isTrue);
  });

  test('BookOwnedRepository rejects a non-Book reference', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = BookOwnedRepository(db);
    final item = BookOwnedItem(
      id: const BookOwnedItemId('owned-book-invalid'),
      catalogRef: const CatalogEntityRef(
        kind: 'comic',
        entityType: CatalogEntityType.work,
        id: 'comic-1',
      ),
      updatedAt: DateTime.utc(2026, 9, 1),
    );

    expect(() => repository.upsert(item), throwsStateError);
  });
}
