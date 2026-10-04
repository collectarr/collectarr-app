import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/local/manga_library_entry_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/manga/entries/manga_grading_details.dart';
import 'package:collectarr_app/features/library/kinds/manga/entries/manga_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/manga/entries/manga_signature_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round trips the complete Manga collection item', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final item = MangaLibraryEntry(
      id: const LibraryEntryId('entry-manga-1'),
      catalogRef: const CatalogEntityRef(
        kind: CatalogMediaKind.manga,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'manga-1',
      ),
      createdAt: DateTime.utc(2026, 4, 1),
      isDigital: false,
      condition: 'Mint',
      grade: '9.8',
      purchaseDate: DateTime.utc(2026, 4, 2),
      pricePaidCents: 1999,
      currency: 'USD',
      personalNotes: 'Deluxe signed volume',
      indexNumber: 3,
      tags: 'favorite,complete',
      updatedAt: DateTime.utc(2026, 4, 3),
      ownerUserId: 'user-1',
      ownerLabel: 'Manga collector',
      locationId: 'shelf-manga',
      purchaseStore: 'Specialist shop',
      collectionStatus: 'entry',
      marketValueCents: 3000,
      details: const MangaEntryDetails(
        grading: MangaGradingDetails(
          rawOrSlabbed: 'Slabbed',
          gradingCompany: 'CGC',
          graderNotes: 'White pages',
          labelType: 'Modern',
          customLabel: 'Signed creator copy',
          pageQuality: 'White pages',
          certificationNumber: 'CGC-12345',
        ),
        signature: MangaSignatureDetails(signedBy: 'Takehiko Inoue'),
        obiStripPresent: true,
        slipcoverPresent: true,
        dustJacketPresent: true,
        dustJacketCondition: 'Like new',
        boxSetOuterCondition: 'Very good',
        insertsPresent: true,
        printing: '1st Print',
        localizedEdition: 'VIZ Media',
      ),
    );

    await db.into(db.mangaLibraryEntriesRows).insert(
          MangaLibraryEntryLocalMapper.toRow(item),
        );
    final row = await db.select(db.mangaLibraryEntriesRows).getSingle();
    final restored = MangaLibraryEntryLocalMapper.fromRow(row);

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
}
