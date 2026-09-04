import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/remote/tv_remote_source.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_repository.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TvRepository round-trips the typed series graph and owned details',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = TvRepository(db);
    final series = _series();

    await repository.updateSeries(series);

    final restored = await repository.getSeries(series.typedId);
    expect(restored?.title, 'The Expanse');
    expect(restored?.seasons.single.episodes.single.title, 'Dulcinea');
    expect(restored?.releases.single.media.single.mediaNumber, 1);
    expect(restored?.releases.single.episodeMappings.single.discNumber, 1);
    expect(restored?.contributions.single.name, 'Mark Fergus');
    expect(restored?.rawPayload['provider'], 'core');

    expect((await repository.search('expanse')).single.id, series.id);
    expect(
      (await repository.getSeason(
        series.typedId,
        series.seasons.single.typedId,
      ))
          ?.episodes,
      hasLength(1),
    );
    expect(
      (await repository.getRelease(
        series.typedId,
        series.releases.single.typedId,
      ))
          ?.media,
      hasLength(1),
    );

    const owned = TvOwnedDetails(
      features: 'Commentary',
      hdrFormats: ['HDR10'],
      boxSetName: 'Season One',
      region: 'Region B',
    );
    await repository.updateOwnedDetails('owned-tv-1', owned);
    final restoredOwned = await repository.getOwnedDetails('owned-tv-1');
    expect(restoredOwned?.features, 'Commentary');
    expect(restoredOwned?.hdrFormats, ['HDR10']);
    expect(restoredOwned?.region, 'Region B');
  });

  test('TvRepository populates and then reads a remote series through cache',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final expected = _series();
    final repository = TvRepository(
      db,
      remote: _FakeTvRemote(expected),
    );

    final first = await repository.getSeries(const TvSeriesId('series-1'));
    final second = await repository.getSeries(const TvSeriesId('series-1'));

    expect(first?.id, expected.id);
    expect(second?.releases.single.id, expected.releases.single.id);
  });

  test('TV schema exposes dedicated graph tables at schema version 18', () {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    expect(db.schemaVersion, 18);
  });
}

TvSeries _series() {
  const episode = TvEpisode(
    id: 'episode-1',
    seriesId: 'series-1',
    seasonId: 'season-1',
    seasonNumber: 1,
    episodeNumber: 1,
    title: 'Dulcinea',
    runtimeMinutes: 43,
  );
  const season = TvSeason(
    id: 'season-1',
    seriesId: 'series-1',
    seasonNumber: 1,
    title: 'Season 1',
    episodes: [episode],
  );
  const media = TvReleaseMedia(
    id: 'media-1',
    releaseId: 'release-1',
    mediaNumber: 1,
    mediaType: 'disc',
    title: 'Disc 1',
  );
  const release = TvRelease(
    id: 'release-1',
    seriesId: 'series-1',
    title: 'Season One Blu-ray',
    format: 'Blu-ray',
    media: [media],
    episodeMappings: [
      TvReleaseEpisodeMap(
        id: 'map-1',
        releaseId: 'release-1',
        mediaId: 'media-1',
        episodeId: 'episode-1',
        discNumber: 1,
        sequenceNumber: 1,
      ),
    ],
  );
  return const TvSeries(
    id: 'series-1',
    title: 'The Expanse',
    network: 'Syfy',
    seasons: [season],
    releases: [release],
    contributions: [TvContributor(name: 'Mark Fergus', role: 'Creator')],
    rawPayload: {'provider': 'core'},
  );
}

final class _FakeTvRemote implements TvRemoteSource {
  const _FakeTvRemote(this.series);

  final TvSeries series;

  @override
  Future<TvSeries> fetchSeries(TvSeriesId id) async => series;
}
