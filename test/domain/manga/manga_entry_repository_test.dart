import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_ids.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/manga/entries/manga_grading_details.dart';
import 'package:collectarr_app/features/library/kinds/manga/entries/manga_entry_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MangaEntryRepository round-trips and soft-deletes copies', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = MangaEntryRepository(db);
    final item = MangaLibraryEntry(
      id: const LibraryEntryId('entry-manga-1'),
      catalogRef: const CatalogEntityRef(
        kind: CatalogMediaKind.manga,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'manga-1',
      ),
      condition: 'Mint',
      updatedAt: DateTime.utc(2026, 9, 1),
      details: const MangaEntryDetails(
        grading: MangaGradingDetails(
          gradingCompany: 'CGC',
          rawOrSlabbed: 'Slabbed',
        ),
        signedBy: 'Takehiko Inoue',
        obiStripPresent: true,
        insertsPresent: true,
        printing: '1st Print',
      ),
    );

    await repository.upsert(item);

    final restored = await repository.findById(item.id);
    expect(restored?.itemId, item.itemId);
    expect(restored?.condition, 'Mint');
    expect(restored?.details.gradingCompany, 'CGC');
    expect(restored?.details.signedBy, 'Takehiko Inoue');
    expect(restored?.details.obiStripPresent, true);
    expect((await repository.listActive()).single.id, item.id);

    await repository.markDeleted(item, DateTime.utc(2026, 9, 2));

    expect(await repository.findById(item.id), isNotNull);
    expect(await repository.listActive(), isEmpty);
    expect((await repository.findById(item.id))?.isDeleted, isTrue);
  });

  test('MangaEntryRepository rejects a non-Manga reference', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = MangaEntryRepository(db);
    final item = MangaLibraryEntry(
      id: const LibraryEntryId('entry-manga-invalid'),
      catalogRef: const CatalogEntityRef(
        kind: CatalogMediaKind.book,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'book-1',
      ),
      updatedAt: DateTime.utc(2026, 9, 1),
    );

    expect(() => repository.upsert(item), throwsStateError);
  });
}
