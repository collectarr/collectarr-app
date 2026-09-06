import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/features/library/kinds/game/data/local/game_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_ids.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_media.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_release.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round trips a fully populated Game media and release', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final media = GameMedia(
      id: const GameMediaId('game-1'),
      title: 'The Legend of Zelda: Breath of the Wild',
      sortTitle: 'Legend of Zelda: Breath of the Wild, The',
      description: 'An adventure across Hyrule.',
      releaseDate: DateTime.utc(2017, 3, 3),
      originalLanguage: 'en',
      publisher: 'Nintendo',
      subtitle: 'Breath of the Wild',
      platforms: const ['Nintendo Switch', 'Wii U'],
      identifiers: const ['igdb:7346', 'upc:045496590420'],
      companyRoles: const ['Nintendo EPD:developer', 'Nintendo:publisher'],
      ageRatings: const ['ESRB:E10+', 'PEGI:12'],
      genres: const ['Action-adventure'],
      searchAliases: const ['BOTW', 'Zelda BOTW'],
      rawPayload: const {
        'cover_image_url': 'https://example.com/zelda.jpg',
        'source': 'core',
      },
    );
    final release = GameRelease(
      id: 'release-1',
      title: 'Nintendo Switch Edition',
      workId: 'game-1',
      platform: 'Nintendo Switch',
      releaseDate: DateTime.utc(2017, 3, 3),
      regionCode: 'US',
      format: 'cartridge',
      publisher: 'Nintendo',
      catalogNumber: 'LA-H-AAAAA-USA',
      releaseStatus: 'released',
      language: 'en',
      barcode: '045496590420',
      coverImageUrl: 'https://example.com/release.jpg',
      rawPayload: const {'source': 'core', 'edition': 'standard'},
    );

    await db.into(db.gameMediaRows).insert(GameLocalMapper.toMediaRow(media));
    await db.into(db.gameReleaseRows).insert(
          GameLocalMapper.toReleaseRow(media.id, release),
        );
    final restored = GameLocalMapper.fromMediaRow(
      await db.select(db.gameMediaRows).getSingle(),
      releases: [
        GameLocalMapper.fromReleaseRow(
          await db.select(db.gameReleaseRows).getSingle(),
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
    expect(restored.companyRoles, media.companyRoles);
    expect(restored.ageRatings, media.ageRatings);
    expect(restored.genres, media.genres);
    expect(restored.searchAliases, media.searchAliases);
    expect(restored.rawPayload, media.rawPayload);
    expect(restored.releases, hasLength(1));
    final restoredRelease = restored.releases.single;
    expect(restoredRelease.typedId, release.typedId);
    expect(restoredRelease.title, release.title);
    expect(restoredRelease.workId, release.workId);
    expect(restoredRelease.platform, release.platform);
    expect(restoredRelease.releaseDate?.toUtc(), release.releaseDate);
    expect(restoredRelease.regionCode, release.regionCode);
    expect(restoredRelease.format, release.format);
    expect(restoredRelease.publisher, release.publisher);
    expect(restoredRelease.catalogNumber, release.catalogNumber);
    expect(restoredRelease.releaseStatus, release.releaseStatus);
    expect(restoredRelease.language, release.language);
    expect(restoredRelease.barcode, release.barcode);
    expect(restoredRelease.coverImageUrl, release.coverImageUrl);
    expect(restoredRelease.rawPayload, release.rawPayload);
  });

  test('round trips all Game owned details', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    const details = GameOwnedDetails(
      completeness: 'Complete in box',
      hasBox: true,
      hasManual: false,
      priceChartingId: 'pc-123',
      coreRegion: 'NTSC-U',
      valueIsLocked: true,
    );

    await db.into(db.gameOwnedDetailsRows).insert(
          GameLocalMapper.toOwnedDetailsRow('owned-1', details),
        );
    final restored = GameLocalMapper.fromOwnedDetailsRow(
      await db.select(db.gameOwnedDetailsRows).getSingle(),
    );

    expect(restored, details);
    expect(restored.completeness, details.completeness);
    expect(restored.hasBox, details.hasBox);
    expect(restored.hasManual, details.hasManual);
    expect(restored.priceChartingId, details.priceChartingId);
    expect(restored.coreRegion, details.coreRegion);
    expect(restored.valueIsLocked, details.valueIsLocked);
  });

  test('round trips the complete Game owned copy', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final item = GameOwnedItem(
      id: const GameOwnedItemId('owned-game-1'),
      catalogRef: const CatalogEntityRef(
        kind: 'game',
        entityType: CatalogEntityType.work,
        id: 'game-1',
      ),
      createdAt: DateTime.utc(2026, 4, 1),
      isDigital: false,
      anchor: PersonalItemAnchor.fromRaw(
        anchorType: 'edition',
        editionId: 'release-1',
      ),
      condition: 'Near Mint',
      grade: '9.5',
      purchaseDate: DateTime.utc(2026, 4, 2),
      pricePaidCents: 5999,
      currency: 'EUR',
      personalNotes: 'Complete launch edition',
      quantity: 2,
      indexNumber: 3,
      tags: 'favorite,complete',
      updatedAt: DateTime.utc(2026, 4, 3),
      ownerUserId: 'user-1',
      ownerLabel: 'Game collector',
      locationId: 'shelf-game',
      purchaseStore: 'Specialist shop',
      collectionStatus: 'owned',
      marketValueCents: 7500,
      details: const GameOwnedDetails(
        completeness: 'Complete in box',
        hasBox: true,
        hasManual: true,
        priceChartingId: 'pc-123',
        coreRegion: 'NTSC-U',
        valueIsLocked: false,
      ),
    );

    await db.into(db.gameOwnedItemsRows).insert(
          GameLocalMapper.toOwnedItemRow(item),
        );
    final restored = GameLocalMapper.fromOwnedItemRow(
      await db.select(db.gameOwnedItemsRows).getSingle(),
    );

    expect(restored.id, item.id);
    expect(restored.itemId, item.itemId);
    expect(restored.createdAt?.toUtc(), item.createdAt);
    expect(restored.isDigital, false);
    expect(restored.anchor?.apiValue, 'edition');
    expect(restored.anchor?.editionId, 'release-1');
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

  test('requires persisted Game identities', () {
    expect(
      () => GameLocalMapper.toMediaRow(
        const GameMedia(id: GameMediaId(''), title: 'Draft'),
      ),
      throwsStateError,
    );
    expect(
      () => GameLocalMapper.toReleaseRow(
        const GameMediaId('game-1'),
        const GameRelease(id: '', title: 'Draft'),
      ),
      throwsStateError,
    );
    expect(
      () => GameLocalMapper.toOwnedDetailsRow('', const GameOwnedDetails()),
      throwsStateError,
    );
    expect(
      () => GameLocalMapper.toOwnedItemRow(
        GameOwnedItem(
          id: GameOwnedItemId(''),
          catalogRef: CatalogEntityRef(
            kind: 'game',
            entityType: CatalogEntityType.work,
            id: 'game-1',
          ),
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      ),
      throwsStateError,
    );
  });
}
