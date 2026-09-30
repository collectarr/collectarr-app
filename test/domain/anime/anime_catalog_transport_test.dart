import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_item_cache_repository.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_repository.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_episode.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_ids.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_media.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_release.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stores Anime Catalog Items and contained data in the shared cache',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = AnimeRepository(db);
    const expected = AnimeMedia(
      id: AnimeMediaId('anime-1'),
      title: 'Cowboy Bebop',
      animeType: 'TV',
      description: 'A bounty hunting crew travels through space.',
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
      rawPayload: {'cover_image_url': 'https://example.com/cowboy-bebop.jpg'},
    );

    await repository.updateMedia(expected);

    final cached = await CatalogItemCacheRepository(db).find(
      const CatalogItemRef(kind: CatalogMediaKind.anime, id: 'anime-1'),
    );
    final restored = await repository.getMedia(expected.id);

    expect(cached, isNotNull);
    expect(cached!.title, expected.title);
    expect(cached.payload['episodes'], hasLength(1));
    expect(cached.payload['releases'], hasLength(1));
    expect(restored?.id, expected.id);
    expect(restored?.description, contains('bounty hunting'));
    expect(restored?.coverImageUrl, 'https://example.com/cowboy-bebop.jpg');
    expect(restored?.episodes.single.id, const AnimeEpisodeId('episode-1'));
    expect(restored?.episodes.single.title, 'Asteroid Blues');
    expect(restored?.releases.single.id, const AnimeReleaseId('release-1'));
    expect(restored?.releases.single.barcode, '123456789');
    expect(await repository.episodesFor(expected.id), hasLength(1));
    expect(await repository.releasesFor(expected.id), hasLength(1));
  });

  test('updates contained episode and release details in the catalog item',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = AnimeRepository(db);
    await repository.updateMedia(const AnimeMedia(
      id: AnimeMediaId('anime-2'),
      title: 'Samurai Champloo',
    ));

    await repository.updateEpisode(
      const AnimeMediaId('anime-2'),
      const AnimeEpisode(
        id: AnimeEpisodeId('episode-2'),
        seriesId: AnimeMediaId('anime-2'),
        episodeNumber: 1,
        title: 'Tempestuous Temperaments',
      ),
    );
    await repository.updateRelease(
      const AnimeMediaId('anime-2'),
      const AnimeRelease(
        id: AnimeReleaseId('release-2'),
        title: 'Blu-ray Collection',
        format: 'Blu-ray',
      ),
    );

    final restored = await repository.getMedia(const AnimeMediaId('anime-2'));
    expect(restored?.episodes.single.title, 'Tempestuous Temperaments');
    expect(restored?.releases.single.seriesId, const AnimeMediaId('anime-2'));
    expect(restored?.releases.single.title, 'Blu-ray Collection');
  });
}
