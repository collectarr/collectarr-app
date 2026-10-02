import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/collection_item_ref.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_repository.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/local/anime_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_ids.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_collection_item.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_tracking.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AnimeRepository persists and soft-deletes typed tracking', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = AnimeRepository(db);
    final tracking = AnimeTracking(
      id: 'tracking-anime-1',
      mediaId: const AnimeMediaId('anime-1'),
      episodeId: const AnimeEpisodeId('episode-1'),
      status: 'watching',
      progressCurrent: 5,
      progressTotal: 26,
      episodeRatings: const {'episode-1': 9},
      updatedAt: DateTime.utc(2026, 9, 5),
    );

    await repository.updateTracking(tracking);
    expect(
      (await repository.getTracking(tracking.id!))?.episodeId,
      tracking.episodeId,
    );
    expect(
      (await repository.getTracking(tracking.id!))?.episodeRatings,
      const {'episode-1': 9},
    );

    await repository.markTrackingDeleted(
      tracking.id!,
      DateTime.utc(2026, 9, 6),
    );
    expect(await repository.getTracking(tracking.id!), isNull);
    expect(await repository.getTracking(tracking.id!), isNull);
  });

  test('AnimeLocalMapper round-trips the complete collection item', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final item = AnimeCollectionItem(
      id: const CollectionItemId('owned-anime-1'),
      catalogRef: const CatalogEntityRef(
        kind: CatalogMediaKind.anime,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'anime-1',
      ),
      createdAt: DateTime.utc(2026, 4, 1),
      isDigital: false,
      condition: 'Near Mint',
      grade: '9.5',
      purchaseDate: DateTime.utc(2026, 4, 2),
      pricePaidCents: 3999,
      currency: 'EUR',
      personalNotes: 'Limited pressing',
      indexNumber: 3,
      tags: 'favorite,limited',
      updatedAt: DateTime.utc(2026, 4, 3),
      ownerUserId: 'user-1',
      ownerLabel: 'Anime collector',
      locationId: 'shelf-anime',
      purchaseStore: 'Specialist shop',
      collectionStatus: 'owned',
      marketValueCents: 4500,
      details: const AnimeOwnedDetails(
        features: 'Commentary',
        hdrFormats: ['HDR10'],
        boxSetId: 'box-1',
        boxSetName: 'Complete Collection',
        region: 'B',
        packaging: 'Digipak',
        distributor: 'Anime Ltd',
      ),
    );

    await db.into(db.animeCollectionItemsRows).insert(
          AnimeLocalMapper.toCollectionItemRow(item),
        );
    final row = await db.select(db.animeCollectionItemsRows).getSingle();
    final restored = AnimeLocalMapper.fromCollectionItemRow(row);

    expect(restored.id, item.id);
    expect(restored.itemId, item.itemId);
    expect(restored.createdAt?.toUtc(), item.createdAt);
    expect(restored.isDigital, false);
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

  test('Anime local mapper requires persisted identities', () {
    expect(
      () => AnimeLocalMapper.toCollectionItemRow(
        AnimeCollectionItem(
          id: const CollectionItemId(''),
          catalogRef: const CatalogEntityRef(
            kind: CatalogMediaKind.anime,
            entityType: CatalogEntityTypeId.catalogItem,
            id: 'anime-1',
          ),
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      ),
      throwsStateError,
    );
  });

  test('Anime personal tables use the v1 database baseline', () {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    expect(db.schemaVersion, 1);
  });
}
