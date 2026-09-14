import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_record.dart';
import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_tracking_state.dart';
import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_tracking_state_codec.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/tracking/boardgame_tracking_state.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/tracking/boardgame_tracking_state_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/tracking/book_tracking_state.dart';
import 'package:collectarr_app/features/library/kinds/book/tracking/book_tracking_state_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/tracking/comic_tracking_state.dart';
import 'package:collectarr_app/features/library/kinds/comic/tracking/comic_tracking_state_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/tracking/game_tracking_state.dart';
import 'package:collectarr_app/features/library/kinds/game/tracking/game_tracking_state_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/tracking/manga_tracking_state.dart';
import 'package:collectarr_app/features/library/kinds/manga/tracking/manga_tracking_state_codec.dart';
import 'package:collectarr_app/features/library/kinds/movie/tracking/movie_tracking_state.dart';
import 'package:collectarr_app/features/library/kinds/movie/tracking/movie_tracking_state_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/tracking/music_tracking_state.dart';
import 'package:collectarr_app/features/library/kinds/music/tracking/music_tracking_state_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_state.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_state_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final updatedAt = DateTime.utc(2026, 9, 8);

  TrackingStorageRecord baseEntry(String kind) {
    return ComicTrackingState(
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
    final entry = TvTrackingState(
      id: 'tv-entry',
      catalogRef: baseEntry('tv').catalogRef,
      coordinates: TvTrackingCoordinates(
          seasonNumber: 2, episodeNumber: 7, episodeRatings: const {'2:7': 9}),
      updatedAt: updatedAt,
    );

    final copied = entry.copyWith(status: 'completed');

    expect(copied, isA<TvTrackingState>());
    expect(copied.coordinates.seasonNumber, 2);
    expect(copied.coordinates.episodeNumber, 7);
    expect(copied.coordinates.episodeRatings, const {'2:7': 9});
    expect(copied.statusStorageValue, 'Completed');
  });

  test('Anime typed entry preserves fractional episode coordinates', () {
    final entry = AnimeTrackingState(
      id: 'anime-entry',
      catalogRef: baseEntry('anime').catalogRef,
      coordinates: AnimeTrackingCoordinates(
          seasonNumber: 1,
          episodeNumber: 12.5,
          episodeRatings: const {'12.5': 10}),
      updatedAt: updatedAt,
    );

    final copied =
        entry.copyWith(updatedAt: updatedAt.add(const Duration(days: 1)));

    expect(copied, isA<AnimeTrackingState>());
    expect(copied.coordinates.seasonNumber, 1);
    expect(copied.coordinates.episodeNumber, 12.5);
    expect(copied.coordinates.episodeRatings, const {'12.5': 10});
  });

  test('TV codec reconstructs a typed entry at the sync boundary', () {
    final entry = const TvTrackingStateCodec().fromSyncPayload(
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

    final typed = switch (entry) {
      TvTrackingState value => value,
      _ => fail('TV codec did not return TvTrackingState'),
    };
    expect(typed.coordinates.seasonNumber, 2);
    expect(typed.coordinates.episodeNumber, 7);
    expect(typed.coordinates.episodeRatings, const {'2:7': 9});
  });

  test('Anime codec keeps fractional episode numbers typed', () {
    final entry = const AnimeTrackingStateCodec().fromSyncPayload(
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

    final typed = switch (entry) {
      AnimeTrackingState value => value,
      _ => fail('Anime codec did not return AnimeTrackingState'),
    };
    expect(typed.coordinates.seasonNumber, 1);
    expect(typed.coordinates.episodeNumber, 12.5);
    expect(typed.coordinates.episodeRatings, const {'12.5': 10});
  });

  test('every kind codec creates its concrete tracking aggregate', () {
    final comic = const ComicTrackingStateCodec().create(
      id: 'comic-entry',
      catalogRef: baseEntry('comic').catalogRef,
      updatedAt: updatedAt,
    );
    final manga = const MangaTrackingStateCodec().create(
      id: 'manga-entry',
      catalogRef: baseEntry('manga').catalogRef,
      updatedAt: updatedAt,
    );
    final book = const BookTrackingStateCodec().create(
      id: 'book-entry',
      catalogRef: baseEntry('book').catalogRef,
      updatedAt: updatedAt,
    );
    final game = const GameTrackingStateCodec().create(
      id: 'game-entry',
      catalogRef: baseEntry('game').catalogRef,
      updatedAt: updatedAt,
    );
    final boardGame = const BoardGameTrackingStateCodec().create(
      id: 'boardgame-entry',
      catalogRef: baseEntry('boardgame').catalogRef,
      updatedAt: updatedAt,
    );
    final movie = const MovieTrackingStateCodec().create(
      id: 'movie-entry',
      catalogRef: baseEntry('movie').catalogRef,
      updatedAt: updatedAt,
    );
    final tv = const TvTrackingStateCodec().create(
      id: 'tv-entry',
      catalogRef: baseEntry('tv').catalogRef,
      updatedAt: updatedAt,
    );
    final anime = const AnimeTrackingStateCodec().create(
      id: 'anime-entry',
      catalogRef: baseEntry('anime').catalogRef,
      updatedAt: updatedAt,
    );
    final music = const MusicTrackingStateCodec().create(
      id: 'music-entry',
      catalogRef: baseEntry('music').catalogRef,
      updatedAt: updatedAt,
    );

    expect(comic, isA<ComicTrackingState>());
    expect(manga, isA<MangaTrackingState>());
    expect(book, isA<BookTrackingState>());
    expect(game, isA<GameTrackingState>());
    expect(boardGame, isA<BoardGameTrackingState>());
    expect(movie, isA<MovieTrackingState>());
    expect(tv, isA<TvTrackingState>());
    expect(anime, isA<AnimeTrackingState>());
    expect(music, isA<MusicTrackingState>());
  });
}
