import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/local/comic_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_reading_state.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round trips owned copy grading and reading details', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final updatedAt = DateTime.utc(2026, 9, 30);
    final input = ComicOwnedItem(
      id: const ComicOwnedCopyId('owned-comic-1'),
      catalogRef: const CatalogEntityRef(
        kind: CatalogMediaKind.comic,
        entityType: CatalogEntityTypeId.root,
        id: 'comic-1',
      ),
      condition: 'Very Fine',
      pricePaidCents: 1299,
      updatedAt: updatedAt,
      details: const ComicOwnedDetails(
        rawOrSlabbed: 'Slabbed',
        gradingCompany: 'CGC',
        certificationNumber: '1234567890',
        pageQuality: 'White',
      ),
      reading: ComicReadingState(
        rating: 5,
        status: 'completed',
        startedAt: DateTime.utc(2026, 9, 1),
        finishedAt: DateTime.utc(2026, 9, 2),
      ),
    );

    await db.into(db.comicOwnedItemsRows).insert(
          ComicLocalMapper.toOwnedItemRow(input),
        );
    await db.into(db.comicReadingRows).insert(
          ComicLocalMapper.toReadingRow(input),
        );
    final ownedRow = await db.select(db.comicOwnedItemsRows).getSingle();
    final readingRow = await db.select(db.comicReadingRows).getSingle();
    final restored = ComicLocalMapper.fromOwnedItemRow(
      ownedRow,
      reading: ComicLocalMapper.fromReadingRow(readingRow),
    );

    expect(restored.id, input.id);
    expect(restored.itemId, 'comic-1');
    expect(restored.condition, 'Very Fine');
    expect(restored.pricePaidCents, 1299);
    expect(restored.details.gradingCompany, 'CGC');
    expect(restored.details.certificationNumber, '1234567890');
    expect(restored.details.pageQuality, 'White');
    expect(restored.reading.rating, 5);
    expect(restored.reading.status, 'completed');
    expect(restored.reading.finishedAt, DateTime.utc(2026, 9, 2));
  });
}
