import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/features/library/kinds/video/video_watch_run_presenter.dart';
import 'package:flutter_test/flutter_test.dart';

WatchSession _session(int season, int episode, DateTime at) {
  return WatchSession(
    id: '$season-$episode-$at',
    targetRef: const CatalogEntityRef(
      kind: 'tv',
      entityType: CatalogEntityType.work,
      id: 'series-1',
    ),
    watchedAt: at,
    updatedAt: at,
    seasonNumber: season,
    episodeNumber: episode,
  );
}

void main() {
  const presenter = VideoWatchRunPresenter();

  test('summarizes watch runs and rewatches', () {
    final summary = presenter.build([
      _session(1, 1, DateTime.utc(2026, 7, 1)),
      _session(1, 1, DateTime.utc(2026, 7, 2)),
      _session(1, 2, DateTime.utc(2026, 7, 3)),
    ]);

    expect(summary.sessionCount, 3);
    expect(summary.uniqueEpisodeCount, 2);
    expect(summary.rewatchCount, 1);
    expect(summary.label, contains('rewatches'));
  });
}
