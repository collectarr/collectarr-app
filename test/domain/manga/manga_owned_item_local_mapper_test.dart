import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/local/manga_owned_item_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_ids.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_grading_details.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_signature_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round trips the complete Manga owned copy', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final item = MangaOwnedItem(
      id: const MangaOwnedCopyId('owned-manga-1'),
      catalogRef: const CatalogEntityRef(
        kind: CatalogMediaKind.manga,
        entityType: CatalogEntityTypeId('work'),
        id: 'manga-1',
      ),
      createdAt: DateTime.utc(2026, 4, 1),
      isDigital: false,
      targetRef: const CatalogEntityRef(
        kind: CatalogMediaKind.manga,
        entityType: CatalogEntityTypeId('edition'),
        id: 'volume-1',
      ),
      condition: 'Mint',
      grade: '9.8',
      purchaseDate: DateTime.utc(2026, 4, 2),
      pricePaidCents: 1999,
      currency: 'USD',
      personalNotes: 'Deluxe signed volume',
      quantity: 2,
      indexNumber: 3,
      tags: 'favorite,complete',
      updatedAt: DateTime.utc(2026, 4, 3),
      ownerUserId: 'user-1',
      ownerLabel: 'Manga collector',
      locationId: 'shelf-manga',
      purchaseStore: 'Specialist shop',
      collectionStatus: 'owned',
      marketValueCents: 3000,
      details: const MangaOwnedDetails(
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

    await db.into(db.mangaOwnedItemsRows).insert(
          MangaOwnedItemLocalMapper.toRow(item),
        );
    final row = await db.select(db.mangaOwnedItemsRows).getSingle();
    final restored = MangaOwnedItemLocalMapper.fromRow(row);

    expect(row.targetRefJson, isNotNull);
    expect(restored.id, item.id);
    expect(restored.itemId, item.itemId);
    expect(restored.createdAt?.toUtc(), item.createdAt);
    expect(restored.targetRef?.entityType.apiValue, 'edition');
    expect(restored.targetRef?.id, 'volume-1');
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
}
