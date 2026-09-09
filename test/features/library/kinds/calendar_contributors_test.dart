import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/anime/calendar/anime_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/calendar/boardgame_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_media.dart';
import 'package:collectarr_app/features/library/kinds/book/calendar/book_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_domain.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_ids.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_media.dart';
import 'package:collectarr_app/features/library/kinds/comic/calendar/comic_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/remote/comic_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/game/calendar/game_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_media.dart';
import 'package:collectarr_app/features/library/kinds/manga/calendar/manga_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_media.dart';
import 'package:collectarr_app/features/library/kinds/movie/calendar/movie_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_media.dart';
import 'package:collectarr_app/features/library/kinds/music/calendar/music_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/tv/calendar/tv_calendar_contributor.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('calendar registry has a release contributor for every catalog kind',
      () {
    final registeredKinds = libraryCalendarContributors
        .map((contributor) => contributor.kind)
        .toSet();

    expect(
      registeredKinds,
      containsAll(
        CatalogMediaKind.values.where(
          (kind) => kind != CatalogMediaKind.unknown,
        ),
      ),
    );
  });

  test('typed release contributors load concrete kind domains', () async {
    final date = DateTime.utc(2020, 1, 2);
    final item = testCatalogItem(
      id: 'comic-item',
      kind: 'comic',
      title: 'Comic title',
      releaseDate: date,
    );
    final cases = <Future<Iterable<CalendarEvent>> Function()>[
      () => BoardGameCalendarContributor(
            loadMedia: (_) async => BoardGameMedia.fromJson(
              testCatalogItem(
                id: 'boardgame-item',
                kind: 'boardgame',
                releaseDate: date,
              ).toSyncPayload(),
            ),
          ).contribute(_context(ids: const ['boardgame-item'])),
      () => GameCalendarContributor(
            loadMedia: (_) async => GameMedia.fromJson(
              testCatalogItem(
                id: 'game-item',
                kind: 'game',
                releaseDate: date,
              ).toSyncPayload(),
            ),
          ).contribute(_context(ids: const ['game-item'])),
      () => MangaCalendarContributor(
            loadMedia: (_) async => MangaMedia.fromJson(
              testCatalogItem(
                id: 'manga-item',
                kind: 'manga',
                releaseDate: date,
                payload: {
                  'first_publication_date': date.toIso8601String(),
                },
              ).toSyncPayload(),
            ),
          ).contribute(_context(ids: const ['manga-item'])),
      () => MovieCalendarContributor(
            loadMedia: (_) async => MovieMedia.fromJson(
              testCatalogItem(
                id: 'movie-item',
                kind: 'movie',
                releaseDate: date,
              ).toSyncPayload(),
            ),
          ).contribute(_context(ids: const ['movie-item'])),
      () => MusicCalendarContributor(
            loadRelease: (_) async => MusicRelease.fromJson(
              testCatalogItem(
                id: 'music-item',
                kind: 'music',
                releaseDate: date,
              ).toSyncPayload(),
            ),
          ).contribute(_context(ids: const ['music-item'])),
      () => BookCalendarContributor(
            loadMedia: (_) async => BookMedia(
              id: const BookMediaId('book-item'),
              title: 'The Hobbit',
              editions: [
                BookRelease(
                  id: 'book-item-release',
                  title: 'The Hobbit',
                  releaseDate: date,
                ),
              ],
            ),
          ).contribute(_context(ids: const ['book-item'])),
      () => ComicCalendarContributor(
            loadMedia: (_) async => ComicCoreMapper.fromCatalogItem(item),
          ).contribute(_context(ids: const ['comic-item'])),
    ];

    for (final loadCase in cases) {
      final events = (await loadCase()).toList(growable: false);
      expect(events, hasLength(1));
      expect(events.single.kind, CalendarEventKind.releaseDate);
      expect(events.single.date, date);
      expect(events.single.itemId, isNotEmpty);
    }
  });

  test('Book calendar contributor owns edition release mapping', () async {
    final events = await BookCalendarContributor(
      loadMedia: (_) async => BookMedia(
        id: BookMediaId('book-item'),
        title: 'The Hobbit',
        editions: [
          BookRelease(
            id: 'book-item-release',
            title: 'The Hobbit',
            releaseDate: DateTime.utc(1937, 9, 21),
          ),
        ],
      ),
    ).contribute(_context(ids: const ['book-item']));

    expect(events, hasLength(1));
    expect(events.single.eventId, 'book-release:book-item-release');
    expect(events.single.title, 'The Hobbit');
    expect(events.single.date, DateTime.utc(1937, 9, 21));
  });

  test('TV and Anime calendar contributors own watch labels independently',
      () async {
    final tvEvents = await const TvCalendarContributor().contribute(
      _context(
        watchSessions: [
          _session(CatalogMediaKind.tv, season: 2, episode: 3),
          _session(CatalogMediaKind.anime, season: 1, episode: 4),
        ],
      ),
    );
    final animeEvents = await const AnimeCalendarContributor().contribute(
      _context(
        watchSessions: [
          _session(CatalogMediaKind.anime, season: 1, episode: 4),
          _session(CatalogMediaKind.tv, season: 2, episode: 3),
          _session(CatalogMediaKind.anime),
        ],
      ),
    );

    expect(tvEvents, hasLength(1));
    expect(tvEvents.single.title, 'Title for tv-item S2E3');
    expect(animeEvents, hasLength(2));
    expect(animeEvents.first.title, 'Title for anime-item S1E4');
    expect(animeEvents.last.title, 'Title for anime-item');
  });
}

LibraryCalendarContext _context({
  Iterable<String> ids = const <String>[],
  Iterable<WatchSession> watchSessions = const <WatchSession>[],
}) {
  return LibraryCalendarContext(
    catalogRefs: {
      for (final id in ids)
        CatalogEntityRef(
          kind: catalogMediaKindFromApiValue(id.split('-').first),
          entityType: const CatalogEntityTypeId('work'),
          id: id,
        ),
    },
    watchSessions: watchSessions,
    titleForRef: (ref) => 'Title for ${ref.id}',
  );
}

WatchSession _session(
  CatalogMediaKind kind, {
  int? season,
  int? episode,
}) {
  return WatchSession(
    id: '${kind.apiValue}-session',
    targetRef: CatalogEntityRef(
      kind: kind,
      entityType: const CatalogEntityTypeId('episode'),
      id: '${kind.apiValue}-item',
    ),
    watchedAt: DateTime.utc(2026, 9, 5),
    updatedAt: DateTime.utc(2026, 9, 5),
    seasonNumber: season,
    episodeNumber: episode,
  );
}
