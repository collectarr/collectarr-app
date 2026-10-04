import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_reading_state.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('persists Comic copy and reading state in kind-entry tables', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final item = ComicLibraryEntry(
      id: const LibraryEntryId('entry-comic-1'),
      catalogRef: const CatalogEntityRef(
        kind: CatalogMediaKind.comic,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'comic-1',
      ),
      condition: 'Fine',
      grade: '8.0',
      updatedAt: DateTime.utc(2026, 9, 5),
      details: const ComicEntryDetails(
        gradingCompany: 'CGC',
        keyComic: true,
      ),
      reading: const ComicReadingState(
        rating: 4,
        status: 'in_progress',
      ),
    );

    final repository = ComicEntryRepository(db);
    await repository.upsert(item);

    final restored = await repository.findById(item.id);
    expect(restored, item);
    final entryRows = await db.select(db.comicLibraryEntriesRows).get();
    expect(entryRows, hasLength(1));
    expect(entryRows.single.itemId, 'comic-1');
    expect(await db.select(db.comicReadingRows).get(), hasLength(1));

    await repository.markDeleted(item, DateTime.utc(2026, 9, 6));
    expect(await repository.listActive(), isEmpty);
    expect((await repository.findById(item.id))?.isDeleted, isTrue);
  });
}
