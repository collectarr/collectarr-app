import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_reading_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final updatedAt = DateTime.utc(2024, 5, 1, 12);
  final startedAt = DateTime.utc(2024, 4, 1);
  final item = ComicLibraryEntry(
    id: const LibraryEntryId('entry-comic-1'),
    catalogRef: const CatalogEntityRef(
      kind: CatalogMediaKind.comic,
      entityType: CatalogEntityTypeId.catalogItem,
      id: 'comic-1',
    ),
    createdAt: DateTime.utc(2024, 1, 1),
    isDigital: false,
    condition: 'Near Mint',
    grade: '9.8',
    purchaseDate: DateTime.utc(2024, 2, 10),
    pricePaidCents: 499,
    currency: 'USD',
    personalNotes: 'Signed at the convention',
    indexNumber: 7,
    tags: 'key, signed',
    updatedAt: updatedAt,
    soldTo: null,
    ownerLabel: 'Alex',
    locationId: 'location-a',
    purchaseStore: 'Local shop',
    collectionStatus: 'entry',
    marketValueCents: 1250,
    details: const ComicEntryDetails(
      rawOrSlabbed: 'Slabbed',
      gradingCompany: 'CGC',
      certificationNumber: 'CGC-123',
      keyComic: true,
      keyReason: 'First appearance',
      coverPriceCents: 10,
    ),
    reading: ComicReadingState(
      rating: 5,
      status: 'completed',
      startedAt: startedAt,
      finishedAt: DateTime.utc(2024, 4, 2),
    ),
  );

  test('typed Comic collection item round-trips all entry and reading state',
      () {
    final restored = ComicLibraryEntry.fromJson(item.toJson());

    expect(restored, item);
    expect(restored.details.gradingCompany, 'CGC');
    expect(restored.details.keyComic, isTrue);
    expect(restored.reading.status, 'completed');
    expect(restored.reading.isFinished, isTrue);
  });

  test('projection keeps tracking outside Comic copy state', () {
    final payload = Map<String, dynamic>.from(item.toJson())..remove('reading');
    final restored = ComicLibraryEntry.fromJson(payload);

    expect(restored.id, item.id);
    expect(restored.details, item.details);
    expect(restored.reading, const ComicReadingState());
    expect(restored.toJson()['catalog_ref'], item.toJson()['catalog_ref']);
  });

  test('typed Comic collection item rejects another kind', () {
    expect(
      () => ComicLibraryEntry.fromJson({
        ...item.toJson(),
        'catalog_ref': const CatalogEntityRef(
          kind: CatalogMediaKind.book,
          entityType: CatalogEntityTypeId.catalogItem,
          id: 'book-1',
        ).toJson(),
      }),
      throwsFormatException,
    );
  });
}
