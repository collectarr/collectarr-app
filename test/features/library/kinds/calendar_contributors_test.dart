import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_item_cache_repository.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/anime/calendar/anime_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/calendar/boardgame_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_media.dart';
import 'package:collectarr_app/features/library/kinds/book/calendar/book_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/comic/calendar/comic_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/remote/comic_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/game/calendar/game_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/manga/calendar/manga_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/movie/calendar/movie_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/music/calendar/music_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/tv/calendar/tv_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_tracking.dart';
import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_watch_session.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
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
    final movieDatabase = LocalDatabase(NativeDatabase.memory());
    addTearDown(movieDatabase.close);
    final bookDatabase = LocalDatabase(NativeDatabase.memory());
    addTearDown(bookDatabase.close);
    final mangaDatabase = LocalDatabase(NativeDatabase.memory());
    addTearDown(mangaDatabase.close);
    await CatalogItemCacheRepository(movieDatabase).upsert(
      testCatalogItem(
        id: 'movie-item',
        kind: 'movie',
        releaseDate: date,
      ),
    );
    await CatalogItemCacheRepository(bookDatabase).upsert(
      testCatalogItem(
        id: 'book-item',
        kind: 'book',
        title: 'The Hobbit',
        releaseDate: date,
      ),
    );
    await CatalogItemCacheRepository(mangaDatabase).upsert(
      testCatalogItem(
        id: 'manga-item',
        kind: 'manga',
        releaseDate: date,
        payload: {
          'first_publication_date': date.toIso8601String(),
        },
      ),
    );
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
            loadItem: (_) async => testCatalogItem(
              id: 'game-item',
              kind: 'game',
              releaseDate: date,
            ),
          ).contribute(_context(ids: const ['game-item'])),
      () => const MangaCalendarContributor().contribute(
            _context(
              ids: const ['manga-item'],
              database: mangaDatabase,
            ),
          ),
      () => MovieCalendarContributor().contribute(
            _context(
              ids: const ['movie-item'],
              database: movieDatabase,
            ),
          ),
      () => MusicCalendarContributor(
            loadAlbum: (_) async => MusicAlbum.fromJson(
              testCatalogItem(
                id: 'music-item',
                kind: 'music',
                releaseDate: date,
              ).toSyncPayload(),
            ),
          ).contribute(_context(ids: const ['music-item'])),
      () => const BookCalendarContributor().contribute(
            _context(
              ids: const ['book-item'],
              database: bookDatabase,
            ),
          ),
      () => ComicCalendarContributor(
            loadMedia: (_) async => ComicCoreMapper.fromCatalogItem(item),
          ).contribute(_context(ids: const ['comic-item'])),
    ];

    for (final loadCase in cases) {
      final events = (await loadCase()).toList(growable: false);
      expect(events, hasLength(1));
      expect(events.single.kind, CalendarEventKind.releaseDate);
      expect(events.single.date, date);
      expect(
        events.single.eventId ?? events.single.catalogRef?.id,
        isNotEmpty,
      );
    }
  });

  test('Book calendar contributor uses the Catalog Item cache', () async {
    final database = LocalDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await CatalogItemCacheRepository(database).upsert(
      testCatalogItem(
        id: 'book-item',
        kind: 'book',
        title: 'The Hobbit',
        releaseDate: DateTime.utc(1937, 9, 21),
      ),
    );
    final events = await const BookCalendarContributor().contribute(
      _context(ids: const ['book-item'], database: database),
    );

    expect(events, hasLength(1));
    expect(events.single.eventId, 'book-catalog-item:book-item');
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
  LocalDatabase? database,
  Iterable<String> ids = const <String>[],
  Iterable<WatchSession> watchSessions = const <WatchSession>[],
}) {
  return LibraryCalendarContext(
    database: database,
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
  final targetRef = CatalogEntityRef(
    kind: kind,
    entityType: const CatalogEntityTypeId('episode'),
    id: '${kind.apiValue}-item',
  );
  if (kind == CatalogMediaKind.tv) {
    return TvWatchSession(
      id: '${kind.apiValue}-session',
      seriesId: TvSeriesId('${kind.apiValue}-item'),
      targetRef: targetRef,
      watchedAt: DateTime.utc(2026, 9, 5),
      updatedAt: DateTime.utc(2026, 9, 5),
      seasonNumber: season,
      episodeNumber: episode,
    );
  }
  if (kind == CatalogMediaKind.anime) {
    return AnimeWatchSession(
      id: '${kind.apiValue}-session',
      targetRef: targetRef,
      watchedAt: DateTime.utc(2026, 9, 5),
      updatedAt: DateTime.utc(2026, 9, 5),
      seasonNumber: season,
      episodeNumber: episode,
    );
  }
  return WatchSession(
    id: '${kind.apiValue}-session',
    targetRef: targetRef,
    watchedAt: DateTime.utc(2026, 9, 5),
    updatedAt: DateTime.utc(2026, 9, 5),
  );
}
