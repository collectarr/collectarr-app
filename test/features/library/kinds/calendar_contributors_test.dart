import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/anime/calendar/anime_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/tv/calendar/tv_calendar_contributor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TV calendar contributor owns episode title projection', () {
    final events = const TvCalendarContributor()
        .contribute(
          LibraryCalendarContext(
            watchSessions: [
              _session(CatalogMediaKind.tv, season: 2, episode: 3),
              _session(CatalogMediaKind.anime, season: 1, episode: 4),
            ],
            titleForItem: (itemId) => 'Title for $itemId',
          ),
        )
        .toList();

    expect(events, hasLength(1));
    expect(events.single.kind, CalendarEventKind.watched);
    expect(events.single.title, 'Title for tv-item S2E3');
  });

  test('Anime calendar contributor stays independent from TV', () {
    final events = const AnimeCalendarContributor()
        .contribute(
          LibraryCalendarContext(
            watchSessions: [
              _session(CatalogMediaKind.anime, season: 1, episode: 4),
              _session(CatalogMediaKind.tv, season: 2, episode: 3),
              _session(CatalogMediaKind.anime),
            ],
            titleForItem: (itemId) => 'Title for $itemId',
          ),
        )
        .toList();

    expect(events, hasLength(2));
    expect(events[0].title, 'Title for anime-item S1E4');
    expect(events[1].title, 'Title for anime-item');
  });
}

WatchSession _session(
  CatalogMediaKind kind, {
  int? season,
  int? episode,
}) {
  return WatchSession(
    id: '$kind-session',
    targetRef: CatalogEntityRef(
      kind: kind.apiValue,
      entityType: CatalogEntityType.episode,
      id: '${kind.apiValue}-item',
    ),
    watchedAt: DateTime.utc(2026, 9, 5),
    updatedAt: DateTime.utc(2026, 9, 5),
    seasonNumber: season,
    episodeNumber: episode,
  );
}
