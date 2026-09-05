import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_reading_state.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('persists Comic copy and reading state in kind-owned tables', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final item = ComicOwnedItem(
      id: const ComicOwnedItemId('owned-comic-1'),
      catalogRef: const CatalogEntityRef(
        kind: 'comic',
        entityType: CatalogEntityType.work,
        id: 'comic-1',
      ),
      condition: 'Fine',
      grade: '8.0',
      quantity: 2,
      updatedAt: DateTime.utc(2026, 9, 5),
      details: const ComicOwnedDetails(
        gradingCompany: 'CGC',
        keyComic: true,
      ),
      reading: const ComicReadingState(
        rating: 4,
        status: 'in_progress',
      ),
    );

    final repository = ComicOwnedRepository(db);
    await repository.upsert(item);

    final restored = await repository.findById(item.id);
    expect(restored, item);
    expect(await db.select(db.comicOwnedItemsRows).get(), hasLength(1));
    expect(await db.select(db.comicReadingRows).get(), hasLength(1));

    await repository.markDeleted(item, DateTime.utc(2026, 9, 6));
    expect(await repository.listActive(), isEmpty);
    expect((await repository.findById(item.id))?.isDeleted, isTrue);
  });
}
