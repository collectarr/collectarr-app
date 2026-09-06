import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_grading_details.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_signature_details.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/local/manga_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_ids.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_media.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round trips a fully populated Manga media row', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final media = MangaMedia(
      id: 'manga-1',
      title: 'Vagabond',
      sortTitle: 'Vagabond',
      description: 'A wandering swordsman searches for meaning.',
      firstPublicationDate: DateTime.utc(1998, 9, 3),
      originalLanguage: 'ja',
      originalPublicationDate: DateTime.utc(1998, 9, 3),
      status: 'hiatus',
      subtitle: 'The Definitive Edition',
      chapters: const [
        {'id': 'chapter-1', 'number': 1},
      ],
      characterAppearances: const [
        {'name': 'Miyamoto Musashi'},
      ],
      contributions: const [
        {'name': 'Takehiko Inoue', 'role': 'author'},
      ],
      identifiers: const [
        {'type': 'isbn', 'value': '978-1569317075'},
      ],
      series: const [
        {'id': 'series-1', 'title': 'Vagabond'},
      ],
      rawPayload: const {'source': 'core'},
    );

    await db.into(db.mangaMediaRows).insert(MangaLocalMapper.toMediaRow(media));
    final restored = MangaLocalMapper.fromMediaRow(
      await db.select(db.mangaMediaRows).getSingle(),
    );

    expect(restored.id, media.id);
    expect(restored.title, media.title);
    expect(restored.sortTitle, media.sortTitle);
    expect(restored.description, media.description);
    expect(restored.firstPublicationDate?.toUtc(), media.firstPublicationDate);
    expect(restored.originalLanguage, media.originalLanguage);
    expect(
      restored.originalPublicationDate?.toUtc(),
      media.originalPublicationDate,
    );
    expect(restored.status, media.status);
    expect(restored.subtitle, media.subtitle);
    expect(restored.chapters, media.chapters);
    expect(restored.characterAppearances, media.characterAppearances);
    expect(restored.contributions, media.contributions);
    expect(restored.identifiers, media.identifiers);
    expect(restored.series, media.series);
    expect(restored.rawPayload, media.rawPayload);
  });

  test('round trips the complete Manga owned copy', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final item = MangaOwnedItem(
      id: const MangaOwnedItemId('owned-manga-1'),
      catalogRef: const CatalogEntityRef(
        kind: 'manga',
        entityType: CatalogEntityType.work,
        id: 'manga-1',
      ),
      createdAt: DateTime.utc(2026, 4, 1),
      isDigital: false,
      anchor: PersonalItemAnchor.fromRaw(
        anchorType: 'edition',
        editionId: 'volume-1',
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
          MangaLocalMapper.toOwnedItemRow(item),
        );
    final restored = MangaLocalMapper.fromOwnedItemRow(
      await db.select(db.mangaOwnedItemsRows).getSingle(),
    );

    expect(restored.id, item.id);
    expect(restored.itemId, item.itemId);
    expect(restored.createdAt?.toUtc(), item.createdAt);
    expect(restored.anchor?.apiValue, 'edition');
    expect(restored.anchor?.editionId, 'volume-1');
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
