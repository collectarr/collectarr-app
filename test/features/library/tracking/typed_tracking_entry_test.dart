import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_tracking_entry.dart';
import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_tracking_entry_codec.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/tracking/boardgame_tracking_entry.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/tracking/boardgame_tracking_entry_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/tracking/book_tracking_entry.dart';
import 'package:collectarr_app/features/library/kinds/book/tracking/book_tracking_entry_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/tracking/comic_tracking_entry.dart';
import 'package:collectarr_app/features/library/kinds/comic/tracking/comic_tracking_entry_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/tracking/game_tracking_entry.dart';
import 'package:collectarr_app/features/library/kinds/game/tracking/game_tracking_entry_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/tracking/manga_tracking_entry.dart';
import 'package:collectarr_app/features/library/kinds/manga/tracking/manga_tracking_entry_codec.dart';
import 'package:collectarr_app/features/library/kinds/movie/tracking/movie_tracking_entry.dart';
import 'package:collectarr_app/features/library/kinds/movie/tracking/movie_tracking_entry_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/tracking/music_tracking_entry.dart';
import 'package:collectarr_app/features/library/kinds/music/tracking/music_tracking_entry_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_entry.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_entry_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final updatedAt = DateTime.utc(2026, 9, 8);

  TrackingEntry baseEntry(String kind) {
    return TrackingEntry(
      id: '$kind-entry',
      catalogRef: CatalogEntityRef(
        kind: catalogMediaKindFromApiValue(kind),
        entityType: const CatalogEntityTypeId('work'),
        id: '$kind-work',
      ),
      updatedAt: updatedAt,
    );
  }

  test('TV typed entry owns episode coordinates across lifecycle copies', () {
    final entry = TvTrackingEntry.fromEntry(
      baseEntry('tv'),
      coordinates: TvTrackingCoordinates(
        seasonNumber: 2,
        episodeNumber: 7,
        episodeRatings: const {'2:7': 9},
      ),
    );

    final copied = entry.copyWith(status: 'completed');

    expect(copied, isA<TvTrackingEntry>());
    expect(copied.coordinates.seasonNumber, 2);
    expect(copied.coordinates.episodeNumber, 7);
    expect(copied.coordinates.episodeRatings, const {'2:7': 9});
    expect(copied.statusStorageValue, 'Completed');
  });

  test('Anime typed entry preserves fractional episode coordinates', () {
    final entry = AnimeTrackingEntry.fromEntry(
      baseEntry('anime'),
      coordinates: AnimeTrackingCoordinates(
        seasonNumber: 1,
        episodeNumber: 12.5,
        episodeRatings: const {'12.5': 10},
      ),
    );

    final copied =
        entry.copyWith(updatedAt: updatedAt.add(const Duration(days: 1)));

    expect(copied, isA<AnimeTrackingEntry>());
    expect(copied.coordinates.seasonNumber, 1);
    expect(copied.coordinates.episodeNumber, 12.5);
    expect(copied.coordinates.episodeRatings, const {'12.5': 10});
  });

  test('TV codec reconstructs a typed entry at the sync boundary', () {
    final entry = const TvTrackingEntryCodec().fromSyncPayload(
      payload: {
        'catalog_ref': {
          'kind': 'tv',
          'entity_type': 'episode',
          'id': 'episode-1',
          'root_id': 'series-1',
        },
        'season_number': 2,
        'episode_number': 7,
        'episode_ratings': {'2:7': 9},
      },
      id: 'tv-sync-entry',
      updatedAt: updatedAt,
    );

    expect(entry, isA<TvTrackingEntry>());
    final typed = entry as TvTrackingEntry;
    expect(typed.coordinates.seasonNumber, 2);
    expect(typed.coordinates.episodeNumber, 7);
    expect(typed.coordinates.episodeRatings, const {'2:7': 9});
  });

  test('Anime codec keeps fractional episode numbers typed', () {
    final entry = const AnimeTrackingEntryCodec().fromSyncPayload(
      payload: {
        'catalog_ref': {
          'kind': 'anime',
          'entity_type': 'episode',
          'id': 'episode-1',
          'root_id': 'anime-1',
        },
        'season_number': 1,
        'episode_number': 12.5,
        'episode_ratings': {'12.5': 10},
      },
      id: 'anime-sync-entry',
      updatedAt: updatedAt,
    );

    expect(entry, isA<AnimeTrackingEntry>());
    final typed = entry as AnimeTrackingEntry;
    expect(typed.coordinates.seasonNumber, 1);
    expect(typed.coordinates.episodeNumber, 12.5);
    expect(typed.coordinates.episodeRatings, const {'12.5': 10});
  });

  test('every kind codec creates its concrete tracking aggregate', () {
    final comic = const ComicTrackingEntryCodec().create(
      id: 'comic-entry',
      catalogRef: baseEntry('comic').catalogRef,
      updatedAt: updatedAt,
    );
    final manga = const MangaTrackingEntryCodec().create(
      id: 'manga-entry',
      catalogRef: baseEntry('manga').catalogRef,
      updatedAt: updatedAt,
    );
    final book = const BookTrackingEntryCodec().create(
      id: 'book-entry',
      catalogRef: baseEntry('book').catalogRef,
      updatedAt: updatedAt,
    );
    final game = const GameTrackingEntryCodec().create(
      id: 'game-entry',
      catalogRef: baseEntry('game').catalogRef,
      updatedAt: updatedAt,
    );
    final boardGame = const BoardGameTrackingEntryCodec().create(
      id: 'boardgame-entry',
      catalogRef: baseEntry('boardgame').catalogRef,
      updatedAt: updatedAt,
    );
    final movie = const MovieTrackingEntryCodec().create(
      id: 'movie-entry',
      catalogRef: baseEntry('movie').catalogRef,
      updatedAt: updatedAt,
    );
    final tv = const TvTrackingEntryCodec().create(
      id: 'tv-entry',
      catalogRef: baseEntry('tv').catalogRef,
      updatedAt: updatedAt,
    );
    final anime = const AnimeTrackingEntryCodec().create(
      id: 'anime-entry',
      catalogRef: baseEntry('anime').catalogRef,
      updatedAt: updatedAt,
    );
    final music = const MusicTrackingEntryCodec().create(
      id: 'music-entry',
      catalogRef: baseEntry('music').catalogRef,
      updatedAt: updatedAt,
    );

    expect(comic, isA<ComicTrackingEntry>());
    expect(manga, isA<MangaTrackingEntry>());
    expect(book, isA<BookTrackingEntry>());
    expect(game, isA<GameTrackingEntry>());
    expect(boardGame, isA<BoardGameTrackingEntry>());
    expect(movie, isA<MovieTrackingEntry>());
    expect(tv, isA<TvTrackingEntry>());
    expect(anime, isA<AnimeTrackingEntry>());
    expect(music, isA<MusicTrackingEntry>());
  });
}
