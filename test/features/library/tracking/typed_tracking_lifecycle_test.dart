import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle.dart';
import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_tracking_lifecycle.dart';
import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_tracking_lifecycle_codec.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/tracking/boardgame_tracking_lifecycle.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/tracking/boardgame_tracking_lifecycle_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/tracking/book_tracking_lifecycle.dart';
import 'package:collectarr_app/features/library/kinds/book/tracking/book_tracking_lifecycle_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/tracking/comic_tracking_lifecycle.dart';
import 'package:collectarr_app/features/library/kinds/comic/tracking/comic_tracking_lifecycle_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/tracking/game_tracking_lifecycle.dart';
import 'package:collectarr_app/features/library/kinds/game/tracking/game_tracking_lifecycle_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/tracking/manga_tracking_lifecycle.dart';
import 'package:collectarr_app/features/library/kinds/manga/tracking/manga_tracking_lifecycle_codec.dart';
import 'package:collectarr_app/features/library/kinds/movie/tracking/movie_tracking_lifecycle.dart';
import 'package:collectarr_app/features/library/kinds/movie/tracking/movie_tracking_lifecycle_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/tracking/music_tracking_lifecycle.dart';
import 'package:collectarr_app/features/library/kinds/music/tracking/music_tracking_lifecycle_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_lifecycle.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_lifecycle_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final updatedAt = DateTime.utc(2026, 9, 8);

  TrackingLifecycle baseEntry(String kind) {
    return TrackingLifecycle(
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
    final entry = TvTrackingLifecycle.fromLifecycle(
      baseEntry('tv'),
      coordinates: TvTrackingCoordinates(
        seasonNumber: 2,
        episodeNumber: 7,
        episodeRatings: const {'2:7': 9},
      ),
    );

    final copied = entry.copyWith(status: 'completed');

    expect(copied, isA<TvTrackingLifecycle>());
    expect(copied.coordinates.seasonNumber, 2);
    expect(copied.coordinates.episodeNumber, 7);
    expect(copied.coordinates.episodeRatings, const {'2:7': 9});
    expect(copied.statusStorageValue, 'Completed');
  });

  test('Anime typed entry preserves fractional episode coordinates', () {
    final entry = AnimeTrackingLifecycle.fromLifecycle(
      baseEntry('anime'),
      coordinates: AnimeTrackingCoordinates(
        seasonNumber: 1,
        episodeNumber: 12.5,
        episodeRatings: const {'12.5': 10},
      ),
    );

    final copied =
        entry.copyWith(updatedAt: updatedAt.add(const Duration(days: 1)));

    expect(copied, isA<AnimeTrackingLifecycle>());
    expect(copied.coordinates.seasonNumber, 1);
    expect(copied.coordinates.episodeNumber, 12.5);
    expect(copied.coordinates.episodeRatings, const {'12.5': 10});
  });

  test('TV codec reconstructs a typed entry at the sync boundary', () {
    final entry = const TvTrackingLifecycleCodec().fromSyncPayload(
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

    expect(entry, isA<TvTrackingLifecycle>());
    final typed = entry as TvTrackingLifecycle;
    expect(typed.coordinates.seasonNumber, 2);
    expect(typed.coordinates.episodeNumber, 7);
    expect(typed.coordinates.episodeRatings, const {'2:7': 9});
  });

  test('Anime codec keeps fractional episode numbers typed', () {
    final entry = const AnimeTrackingLifecycleCodec().fromSyncPayload(
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

    expect(entry, isA<AnimeTrackingLifecycle>());
    final typed = entry as AnimeTrackingLifecycle;
    expect(typed.coordinates.seasonNumber, 1);
    expect(typed.coordinates.episodeNumber, 12.5);
    expect(typed.coordinates.episodeRatings, const {'12.5': 10});
  });

  test('every kind codec creates its concrete tracking aggregate', () {
    final comic = const ComicTrackingLifecycleCodec().create(
      id: 'comic-entry',
      catalogRef: baseEntry('comic').catalogRef,
      updatedAt: updatedAt,
    );
    final manga = const MangaTrackingLifecycleCodec().create(
      id: 'manga-entry',
      catalogRef: baseEntry('manga').catalogRef,
      updatedAt: updatedAt,
    );
    final book = const BookTrackingLifecycleCodec().create(
      id: 'book-entry',
      catalogRef: baseEntry('book').catalogRef,
      updatedAt: updatedAt,
    );
    final game = const GameTrackingLifecycleCodec().create(
      id: 'game-entry',
      catalogRef: baseEntry('game').catalogRef,
      updatedAt: updatedAt,
    );
    final boardGame = const BoardGameTrackingLifecycleCodec().create(
      id: 'boardgame-entry',
      catalogRef: baseEntry('boardgame').catalogRef,
      updatedAt: updatedAt,
    );
    final movie = const MovieTrackingLifecycleCodec().create(
      id: 'movie-entry',
      catalogRef: baseEntry('movie').catalogRef,
      updatedAt: updatedAt,
    );
    final tv = const TvTrackingLifecycleCodec().create(
      id: 'tv-entry',
      catalogRef: baseEntry('tv').catalogRef,
      updatedAt: updatedAt,
    );
    final anime = const AnimeTrackingLifecycleCodec().create(
      id: 'anime-entry',
      catalogRef: baseEntry('anime').catalogRef,
      updatedAt: updatedAt,
    );
    final music = const MusicTrackingLifecycleCodec().create(
      id: 'music-entry',
      catalogRef: baseEntry('music').catalogRef,
      updatedAt: updatedAt,
    );

    expect(comic, isA<ComicTrackingLifecycle>());
    expect(manga, isA<MangaTrackingLifecycle>());
    expect(book, isA<BookTrackingLifecycle>());
    expect(game, isA<GameTrackingLifecycle>());
    expect(boardGame, isA<BoardGameTrackingLifecycle>());
    expect(movie, isA<MovieTrackingLifecycle>());
    expect(tv, isA<TvTrackingLifecycle>());
    expect(anime, isA<AnimeTrackingLifecycle>());
    expect(music, isA<MusicTrackingLifecycle>());
  });
}
