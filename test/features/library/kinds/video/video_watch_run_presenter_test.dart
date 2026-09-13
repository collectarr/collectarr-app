import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/features/library/tracking/session_history_presenter.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_tracking.dart';
import 'package:flutter_test/flutter_test.dart';

WatchSession _session(int season, int episode, DateTime at) {
  return TvWatchSession(
    id: '$season-$episode-$at',
    seriesId: TvSeriesId('series-1'),
    targetRef: CatalogEntityRef(
      kind: CatalogMediaKind.tv,
      entityType: const CatalogEntityTypeId('episode'),
      id: 'series-1:season:$season:episode:$episode',
    ),
    watchedAt: at,
    updatedAt: at,
    seasonNumber: season,
    episodeNumber: episode,
  );
}

void main() {
  const presenter = SessionHistoryPresenter();

  test('summarizes watch runs and rewatches', () {
    final summary = presenter.build([
      _session(1, 1, DateTime.utc(2026, 7, 1)),
      _session(1, 1, DateTime.utc(2026, 7, 2)),
      _session(1, 2, DateTime.utc(2026, 7, 3)),
    ]);

    expect(summary.sessionCount, 3);
    expect(summary.uniqueTargetCount, 2);
    expect(summary.rewatchCount, 1);
    expect(summary.label(), contains('rewatches'));
  });
}
