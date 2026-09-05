import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_unit.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_progress_presenter.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_unit.dart';
import 'package:flutter_test/flutter_test.dart';

CatalogEntityRef _ref() {
  return const CatalogEntityRef(
    kind: 'tv',
    entityType: CatalogEntityType.work,
    id: 'series-1',
  );
}

TvSeason _season({
  required int seasonNumber,
  required List<TvEpisode> episodes,
}) {
  return TvSeason(
    id: 'season-$seasonNumber',
    seriesId: 'series-1',
    seasonNumber: seasonNumber,
    title: 'Season $seasonNumber',
    episodes: episodes,
  );
}

TvEpisode _episode({
  required int number,
  String? airDate,
}) {
  return TvEpisode(
    id: 'episode-$number',
    seriesId: 'series-1',
    seasonId: 'season-1',
    seasonNumber: 1,
    episodeNumber: number.toDouble(),
    title: 'Episode $number',
    airDate: airDate == null ? null : DateTime.tryParse(airDate),
  );
}

TrackingUnit _trackedEpisode(int seasonNumber, int episodeNumber, DateTime at) {
  return TvTrackingUnit(
    id: '$seasonNumber-$episodeNumber',
    targetRef: _ref(),
    seasonNumber: seasonNumber,
    episodeNumber: episodeNumber,
    completedAt: at,
    updatedAt: at,
  );
}

WatchSession _watchSession(int seasonNumber, int episodeNumber, DateTime at) {
  return WatchSession(
    id: '$seasonNumber-$episodeNumber',
    targetRef: _ref(),
    watchedAt: at,
    updatedAt: at,
    seasonNumber: seasonNumber,
    episodeNumber: episodeNumber,
  );
}

void main() {
  const presenter = VideoProgressPresenter();

  test('empty seasons produce an empty summary', () {
    final summary = presenter.build(
      seasons: const [],
      trackedUnits: const [],
      watchSessions: const [],
      now: DateTime.utc(2026, 7, 6),
    );

    expect(summary.totalEpisodes, 0);
    expect(summary.watchedEpisodes, 0);
    expect(summary.completionPercent, 0);
  });

  test('partial season watched uses released episode count', () {
    final summary = presenter.build(
      seasons: [
        _season(
          seasonNumber: 1,
          episodes: [
            _episode(number: 1, airDate: '2026-07-01'),
            _episode(number: 2, airDate: '2026-07-08'),
            _episode(number: 3, airDate: '2026-07-15'),
          ],
        ),
      ],
      trackedUnits: [
        _trackedEpisode(1, 1, DateTime.utc(2026, 7, 6)),
      ],
      watchSessions: const [],
      now: DateTime.utc(2026, 7, 6),
    );

    expect(summary.releasedEpisodes, 1);
    expect(summary.watchedEpisodes, 1);
    expect(summary.episodesLeft, 0);
    expect(summary.nextEpisode?.code, isNull);
    expect(summary.lastWatched?.code, 'S01E01');
  });

  test('watch sessions determine last watched and next episode', () {
    final summary = presenter.build(
      seasons: [
        _season(
          seasonNumber: 1,
          episodes: [
            _episode(number: 1, airDate: '2026-07-01'),
            _episode(number: 2, airDate: '2026-07-02'),
          ],
        ),
        _season(
          seasonNumber: 2,
          episodes: [
            _episode(number: 1, airDate: '2026-07-03'),
          ],
        ),
      ],
      trackedUnits: const [],
      watchSessions: [
        _watchSession(1, 1, DateTime.utc(2026, 7, 4)),
        _watchSession(1, 2, DateTime.utc(2026, 7, 5)),
      ],
      now: DateTime.utc(2026, 7, 6),
    );

    expect(summary.lastWatched?.code, 'S01E02');
    expect(summary.nextEpisode?.code, 'S02E01');
    expect(summary.currentSeasonNumber, 2);
  });

  test('unaired episodes do not count as left', () {
    final summary = presenter.build(
      seasons: [
        _season(
          seasonNumber: 1,
          episodes: [
            _episode(number: 1, airDate: '2026-07-01'),
            _episode(number: 2, airDate: '2026-07-08'),
          ],
        ),
      ],
      trackedUnits: [
        _trackedEpisode(1, 1, DateTime.utc(2026, 7, 6)),
      ],
      watchSessions: const [],
      now: DateTime.utc(2026, 7, 6),
    );

    expect(summary.releasedEpisodes, 1);
    expect(summary.episodesLeft, 0);
    expect(summary.hasUnairedEpisodes, isTrue);
  });
}
