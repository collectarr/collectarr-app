import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_repository.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/local/anime_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/remote/anime_remote_source.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_episode.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_ids.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_media.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_release.dart';
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

  test('AnimeLocalMapper round-trips the complete owned copy', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final item = AnimeOwnedItem(
      id: const AnimeOwnedItemId('owned-anime-1'),
      catalogRef: const CatalogEntityRef(
        kind: 'anime',
        entityType: CatalogEntityType.work,
        id: 'anime-1',
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
      pricePaidCents: 3999,
      currency: 'EUR',
      personalNotes: 'Limited pressing',
      quantity: 2,
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

    await db.into(db.animeOwnedItemsRows).insert(
          AnimeLocalMapper.toOwnedItemRow(item),
        );
    final restored = AnimeLocalMapper.fromOwnedItemRow(
      await db.select(db.animeOwnedItemsRows).getSingle(),
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

  test('AnimeRepository populates and then reads a remote media through cache',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final expected = _media();
    final repository = AnimeRepository(
      db,
      remote: _FakeAnimeRemote(expected),
    );

    final first = await repository.getMedia(expected.id);
    final second = await repository.getMedia(expected.id);

    expect(first?.id, expected.id);
    expect(second?.episodes.single.id, expected.episodes.single.id);
  });

  test('Anime local mapper requires persisted identities', () {
    expect(
      () => AnimeLocalMapper.toMediaRow(
        const AnimeMedia(id: AnimeMediaId(''), title: 'Draft'),
      ),
      throwsStateError,
    );
    expect(
      () => AnimeLocalMapper.toEpisodeRow(
        const AnimeEpisode(
          id: AnimeEpisodeId('episode-1'),
          seriesId: AnimeMediaId(''),
        ),
      ),
      throwsStateError,
    );
    expect(
      () => AnimeLocalMapper.toOwnedItemRow(
        AnimeOwnedItem(
          id: const AnimeOwnedItemId(''),
          catalogRef: const CatalogEntityRef(
            kind: 'anime',
            entityType: CatalogEntityType.work,
            id: 'anime-1',
          ),
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      ),
      throwsStateError,
    );
  });

  test('Anime schema exposes dedicated tables at schema version 1', () {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    expect(db.schemaVersion, 1);
  });
}

AnimeMedia _media() {
  return const AnimeMedia(
    id: AnimeMediaId('anime-1'),
    title: 'Cowboy Bebop',
    animeType: 'TV',
    episodeCount: 26,
    episodes: [
      AnimeEpisode(
        id: AnimeEpisodeId('episode-1'),
        seriesId: AnimeMediaId('anime-1'),
        episodeNumber: 1,
        title: 'Asteroid Blues',
        runtimeMinutes: 24,
      ),
    ],
    releases: [
      AnimeRelease(
        id: AnimeReleaseId('release-1'),
        title: 'Complete Collection',
        seriesId: AnimeMediaId('anime-1'),
        format: 'Blu-ray',
        barcode: '123456789',
      ),
    ],
    contributions: [
      AnimeContributor(name: 'Shinichiro Watanabe', role: 'director'),
    ],
    rawPayload: {'provider': 'core'},
  );
}

final class _FakeAnimeRemote implements AnimeRemoteSource {
  const _FakeAnimeRemote(this.media);

  final AnimeMedia media;

  @override
  Future<AnimeMedia> fetchMedia(AnimeMediaId id) async => media;
}
