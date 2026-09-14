import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_repository.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_ids.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_tracking.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_tracking_repository.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_tracking.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TV and Anime custom episodes persist through their own repositories',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final now = DateTime.utc(2026, 9, 5);

    await TvTrackingRepository(db).upsertCustomEpisode(
      TvCustomEpisode(
        id: const TvEpisodeId('tv-custom-1'),
        seriesId: const TvSeriesId('tv-1'),
        seasonNumber: 1,
        episodeNumber: 9,
        title: 'TV special',
        updatedAt: now,
      ),
    );
    await AnimeRepository(db).upsertCustomEpisode(
      AnimeCustomEpisode(
        id: const AnimeEpisodeId('anime-custom-1'),
        seriesId: const AnimeMediaId('anime-1'),
        seasonNumber: 2,
        episodeNumber: 5,
        title: 'Anime special',
        updatedAt: now,
      ),
    );

    expect(await db.select(db.tvCustomEpisodeRows).get(), hasLength(1));
    expect(await db.select(db.animeCustomEpisodeRows).get(), hasLength(1));
    expect(
      (await AnimeRepository(db).findCustomEpisodeById(
        const AnimeEpisodeId('anime-custom-1'),
      ))
          ?.seriesId
          .value,
      'anime-1',
    );
  });
}
