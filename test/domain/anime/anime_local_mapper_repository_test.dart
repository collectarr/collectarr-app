import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_repository.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/local/anime_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/remote/anime_remote_source.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_episode.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_ids.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_media.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_release.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_tracking.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AnimeRepository round-trips the typed graph and owned details',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = AnimeRepository(db);
    final media = _media();

    await repository.updateMedia(media);

    final restored = await repository.getMedia(media.id);
    expect(restored?.title, 'Cowboy Bebop');
    expect(restored?.episodes.single.title, 'Asteroid Blues');
    expect(restored?.releases.single.barcode, '123456789');
    expect(restored?.contributions.single.name, 'Shinichiro Watanabe');
    expect(restored?.rawPayload['provider'], 'core');
    expect((await repository.search('bebop')).single.id, media.id);
    expect(
      (await repository.getEpisode(
        media.id,
        media.episodes.single.id,
      ))
          ?.episodeNumber,
      1,
    );
    expect(
      (await repository.getRelease(
        media.id,
        media.releases.single.id,
      ))
          ?.title,
      'Complete Collection',
    );

    const owned = AnimeOwnedDetails(
      features: 'Commentary',
      hdrFormats: ['HDR10'],
      boxSetName: 'Complete Series',
      region: 'B',
    );
    await repository.updateOwnedDetails('owned-anime-1', owned);
    expect(await repository.getOwnedDetails('owned-anime-1'), owned);
  });

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
      (await repository.trackingFor(tracking.mediaId)).single.episodeId,
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
    expect(await repository.trackingFor(tracking.mediaId), isEmpty);
    expect(await repository.getTracking(tracking.id!), isNull);
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
      () => AnimeLocalMapper.toOwnedDetailsRow('', const AnimeOwnedDetails()),
      throwsStateError,
    );
  });

  test('Anime schema exposes dedicated tables at schema version 21', () {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    expect(db.schemaVersion, 25);
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
