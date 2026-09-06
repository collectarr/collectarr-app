import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/local/boardgame_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_edition.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_ids.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_media.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round trips a fully populated BoardGame media and edition', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final media = BoardGameMedia(
      id: const BoardGameMediaId('boardgame-1'),
      title: 'Brass: Birmingham',
      sortTitle: 'Brass Birmingham',
      description: 'An economic strategy game.',
      releaseDate: DateTime.utc(2018, 10, 1),
      originalLanguage: 'en',
      publisher: 'Roxley',
      subtitle: 'Industrial Revolution',
      platforms: const ['Tabletop'],
      identifiers: const ['bgg:224517'],
      contributors: const ['Martin Wallace'],
      mechanics: const ['Hand Management', 'Network Building'],
      categories: const ['Economic'],
      families: const ['Brass'],
      expansions: const ['Brass: Birmingham - Deluxe'],
      rankings: const ['1'],
      searchAliases: const ['Brass Birmingham'],
      rawPayload: const {
        'cover_image_url': 'https://example.com/brass.jpg',
        'source': 'core',
      },
    );
    final edition = BoardGameEdition(
      id: 'edition-1',
      title: 'Deluxe Edition',
      titleValue: 'Brass: Birmingham',
      workId: 'boardgame-1',
      editionTitle: 'Deluxe Edition',
      ageRating: '12+',
      audienceRating: 'Family',
      barcode: '123456789',
      catalogNumber: 'ROX-001',
      country: 'US',
      coverImageUrl: 'https://example.com/brass-deluxe.jpg',
      description: 'Deluxe components.',
      format: 'boxed',
      language: 'en',
      maxPlayers: 4,
      minAge: 14,
      minPlayers: 2,
      playingTimeMinutes: 120,
      publisher: 'Roxley',
      releaseDate: DateTime.utc(2018, 10, 1),
      releaseStatus: 'published',
      rawPayload: const {'source': 'core'},
    );

    await db.into(db.boardGameMediaRows).insert(
          BoardGameLocalMapper.toMediaRow(media),
        );
    await db.into(db.boardGameEditionRows).insert(
          BoardGameLocalMapper.toEditionRow(media.id, edition),
        );

    final restored = BoardGameLocalMapper.fromMediaRow(
      await db.select(db.boardGameMediaRows).getSingle(),
      editions: [
        BoardGameLocalMapper.fromEditionRow(
          await db.select(db.boardGameEditionRows).getSingle(),
        ),
      ],
    );

    expect(restored.id, media.id);
    expect(restored.title, media.title);
    expect(restored.sortTitle, media.sortTitle);
    expect(restored.description, media.description);
    expect(restored.releaseDate?.toUtc(), media.releaseDate);
    expect(restored.originalLanguage, media.originalLanguage);
    expect(restored.publisher, media.publisher);
    expect(restored.subtitle, media.subtitle);
    expect(restored.platforms, media.platforms);
    expect(restored.identifiers, media.identifiers);
    expect(restored.contributors, media.contributors);
    expect(restored.mechanics, media.mechanics);
    expect(restored.categories, media.categories);
    expect(restored.families, media.families);
    expect(restored.expansions, media.expansions);
    expect(restored.rankings, media.rankings);
    expect(restored.searchAliases, media.searchAliases);
    expect(restored.rawPayload, media.rawPayload);
    expect(restored.editions, hasLength(1));

    final restoredEdition = restored.editions.single;
    expect(restoredEdition.typedId, edition.typedId);
    expect(restoredEdition.title, edition.title);
    expect(restoredEdition.titleValue, edition.titleValue);
    expect(restoredEdition.workId, edition.workId);
    expect(restoredEdition.editionTitle, edition.editionTitle);
    expect(restoredEdition.ageRating, edition.ageRating);
    expect(restoredEdition.audienceRating, edition.audienceRating);
    expect(restoredEdition.barcode, edition.barcode);
    expect(restoredEdition.catalogNumber, edition.catalogNumber);
    expect(restoredEdition.country, edition.country);
    expect(restoredEdition.coverImageUrl, edition.coverImageUrl);
    expect(restoredEdition.description, edition.description);
    expect(restoredEdition.format, edition.format);
    expect(restoredEdition.language, edition.language);
    expect(restoredEdition.maxPlayers, edition.maxPlayers);
    expect(restoredEdition.minAge, edition.minAge);
    expect(restoredEdition.minPlayers, edition.minPlayers);
    expect(restoredEdition.playingTimeMinutes, edition.playingTimeMinutes);
    expect(restoredEdition.publisher, edition.publisher);
    expect(restoredEdition.releaseDate?.toUtc(), edition.releaseDate);
    expect(restoredEdition.releaseStatus, edition.releaseStatus);
    expect(restoredEdition.rawPayload, edition.rawPayload);
  });

  test('round trips all BoardGame owned details', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    const details = BoardgameOwnedDetails(
      editionLanguage: 'English',
      editionRegion: 'US',
      componentCondition: 'Like New',
      componentCompleteness: 'Complete',
      missingPiecesNotes: 'None',
      isSleeved: true,
      hasCustomInsert: true,
      hasPaintedMiniatures: true,
      storageNotes: 'Shelf 3',
    );

    await db.into(db.boardGameOwnedDetailsRows).insert(
          BoardGameLocalMapper.toOwnedDetailsRow('owned-1', details),
        );
    final restored = BoardGameLocalMapper.fromOwnedDetailsRow(
      await db.select(db.boardGameOwnedDetailsRows).getSingle(),
    );

    expect(restored, details);
  });

  test('round trips the complete BoardGame owned copy', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final item = BoardGameOwnedItem(
      id: const BoardGameOwnedItemId('owned-boardgame-1'),
      catalogRef: const CatalogEntityRef(
        kind: 'boardgame',
        entityType: CatalogEntityType.work,
        id: 'boardgame-1',
      ),
      createdAt: DateTime.utc(2026, 4, 1),
      isDigital: false,
      anchor: PersonalItemAnchor.fromRaw(
        anchorType: 'edition',
        editionId: 'edition-1',
      ),
      condition: 'Near Mint',
      grade: '9.5',
      purchaseDate: DateTime.utc(2026, 4, 2),
      pricePaidCents: 7999,
      currency: 'EUR',
      personalNotes: 'Deluxe components intact',
      quantity: 2,
      indexNumber: 3,
      tags: 'favorite,complete',
      updatedAt: DateTime.utc(2026, 4, 3),
      ownerUserId: 'user-1',
      ownerLabel: 'Board game collector',
      locationId: 'shelf-boardgame',
      purchaseStore: 'Specialist shop',
      collectionStatus: 'owned',
      marketValueCents: 9000,
      details: const BoardgameOwnedDetails(
        editionLanguage: 'English',
        editionRegion: 'US',
        componentCondition: 'Like New',
        componentCompleteness: 'Complete',
        missingPiecesNotes: 'None',
        isSleeved: true,
        hasCustomInsert: true,
        hasPaintedMiniatures: true,
        storageNotes: 'Shelf 3',
      ),
    );

    await db.into(db.boardGameOwnedItemsRows).insert(
          BoardGameLocalMapper.toOwnedItemRow(item),
        );
    final restored = BoardGameLocalMapper.fromOwnedItemRow(
      await db.select(db.boardGameOwnedItemsRows).getSingle(),
    );

    expect(restored.id, item.id);
    expect(restored.itemId, item.itemId);
    expect(restored.createdAt?.toUtc(), item.createdAt);
    expect(restored.isDigital, false);
    expect(restored.anchor?.apiValue, 'edition');
    expect(restored.anchor?.editionId, 'edition-1');
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

  test('requires persisted BoardGame identities', () {
    expect(
      () => BoardGameLocalMapper.toMediaRow(
        const BoardGameMedia(id: BoardGameMediaId(''), title: 'Draft'),
      ),
      throwsStateError,
    );
    expect(
      () => BoardGameLocalMapper.toEditionRow(
        const BoardGameMediaId('boardgame-1'),
        const BoardGameEdition(id: '', title: 'Draft'),
      ),
      throwsStateError,
    );
    expect(
      () => BoardGameLocalMapper.toOwnedDetailsRow(
        '',
        const BoardgameOwnedDetails(),
      ),
      throwsStateError,
    );
    expect(
      () => BoardGameLocalMapper.toOwnedItemRow(
        BoardGameOwnedItem(
          id: const BoardGameOwnedItemId(''),
          catalogRef: const CatalogEntityRef(
            kind: 'boardgame',
            entityType: CatalogEntityType.work,
            id: 'boardgame-1',
          ),
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      ),
      throwsStateError,
    );
  });
}
