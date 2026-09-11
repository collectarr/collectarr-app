import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_owned_item.dart';

/// Structural dispatch boundary for a fully loaded kind-owned aggregate.
///
/// Mixed Library hosts may transport this value, but they cannot inspect its
/// semantic fields. The owning kind selects only its own callback after the
/// kind has already been dispatched. Persistence and API code remain the only
/// places that need an opaque serialized value.
abstract interface class LibraryOwnedItemDispatch {
  OwnedItemRef get ref;

  R? map<R>({
    R? Function(AnimeOwnedItem value)? anime,
    R? Function(BoardGameOwnedItem value)? boardgame,
    R? Function(BookOwnedItem value)? book,
    R? Function(ComicOwnedItem value)? comic,
    R? Function(GameOwnedItem value)? game,
    R? Function(MangaOwnedItem value)? manga,
    R? Function(MovieOwnedItem value)? movie,
    R? Function(MusicOwnedItem value)? music,
    R? Function(TvOwnedItem value)? tv,
  });
}

final class AnimeOwnedItemDispatch implements LibraryOwnedItemDispatch {
  const AnimeOwnedItemDispatch({required this.ref, required this.value});

  @override
  final OwnedItemRef ref;
  final AnimeOwnedItem value;

  @override
  R? map<R>({
    R? Function(AnimeOwnedItem value)? anime,
    R? Function(BoardGameOwnedItem value)? boardgame,
    R? Function(BookOwnedItem value)? book,
    R? Function(ComicOwnedItem value)? comic,
    R? Function(GameOwnedItem value)? game,
    R? Function(MangaOwnedItem value)? manga,
    R? Function(MovieOwnedItem value)? movie,
    R? Function(MusicOwnedItem value)? music,
    R? Function(TvOwnedItem value)? tv,
  }) =>
      anime?.call(value);
}

final class BoardGameOwnedItemDispatch implements LibraryOwnedItemDispatch {
  const BoardGameOwnedItemDispatch({required this.ref, required this.value});

  @override
  final OwnedItemRef ref;
  final BoardGameOwnedItem value;

  @override
  R? map<R>({
    R? Function(AnimeOwnedItem value)? anime,
    R? Function(BoardGameOwnedItem value)? boardgame,
    R? Function(BookOwnedItem value)? book,
    R? Function(ComicOwnedItem value)? comic,
    R? Function(GameOwnedItem value)? game,
    R? Function(MangaOwnedItem value)? manga,
    R? Function(MovieOwnedItem value)? movie,
    R? Function(MusicOwnedItem value)? music,
    R? Function(TvOwnedItem value)? tv,
  }) =>
      boardgame?.call(value);
}

final class BookOwnedItemDispatch implements LibraryOwnedItemDispatch {
  const BookOwnedItemDispatch({required this.ref, required this.value});

  @override
  final OwnedItemRef ref;
  final BookOwnedItem value;

  @override
  R? map<R>({
    R? Function(AnimeOwnedItem value)? anime,
    R? Function(BoardGameOwnedItem value)? boardgame,
    R? Function(BookOwnedItem value)? book,
    R? Function(ComicOwnedItem value)? comic,
    R? Function(GameOwnedItem value)? game,
    R? Function(MangaOwnedItem value)? manga,
    R? Function(MovieOwnedItem value)? movie,
    R? Function(MusicOwnedItem value)? music,
    R? Function(TvOwnedItem value)? tv,
  }) =>
      book?.call(value);
}

final class ComicOwnedItemDispatch implements LibraryOwnedItemDispatch {
  const ComicOwnedItemDispatch({required this.ref, required this.value});

  @override
  final OwnedItemRef ref;
  final ComicOwnedItem value;

  @override
  R? map<R>({
    R? Function(AnimeOwnedItem value)? anime,
    R? Function(BoardGameOwnedItem value)? boardgame,
    R? Function(BookOwnedItem value)? book,
    R? Function(ComicOwnedItem value)? comic,
    R? Function(GameOwnedItem value)? game,
    R? Function(MangaOwnedItem value)? manga,
    R? Function(MovieOwnedItem value)? movie,
    R? Function(MusicOwnedItem value)? music,
    R? Function(TvOwnedItem value)? tv,
  }) =>
      comic?.call(value);
}

final class GameOwnedItemDispatch implements LibraryOwnedItemDispatch {
  const GameOwnedItemDispatch({required this.ref, required this.value});

  @override
  final OwnedItemRef ref;
  final GameOwnedItem value;

  @override
  R? map<R>({
    R? Function(AnimeOwnedItem value)? anime,
    R? Function(BoardGameOwnedItem value)? boardgame,
    R? Function(BookOwnedItem value)? book,
    R? Function(ComicOwnedItem value)? comic,
    R? Function(GameOwnedItem value)? game,
    R? Function(MangaOwnedItem value)? manga,
    R? Function(MovieOwnedItem value)? movie,
    R? Function(MusicOwnedItem value)? music,
    R? Function(TvOwnedItem value)? tv,
  }) =>
      game?.call(value);
}

final class MangaOwnedItemDispatch implements LibraryOwnedItemDispatch {
  const MangaOwnedItemDispatch({required this.ref, required this.value});

  @override
  final OwnedItemRef ref;
  final MangaOwnedItem value;

  @override
  R? map<R>({
    R? Function(AnimeOwnedItem value)? anime,
    R? Function(BoardGameOwnedItem value)? boardgame,
    R? Function(BookOwnedItem value)? book,
    R? Function(ComicOwnedItem value)? comic,
    R? Function(GameOwnedItem value)? game,
    R? Function(MangaOwnedItem value)? manga,
    R? Function(MovieOwnedItem value)? movie,
    R? Function(MusicOwnedItem value)? music,
    R? Function(TvOwnedItem value)? tv,
  }) =>
      manga?.call(value);
}

final class MovieOwnedItemDispatch implements LibraryOwnedItemDispatch {
  const MovieOwnedItemDispatch({required this.ref, required this.value});

  @override
  final OwnedItemRef ref;
  final MovieOwnedItem value;

  @override
  R? map<R>({
    R? Function(AnimeOwnedItem value)? anime,
    R? Function(BoardGameOwnedItem value)? boardgame,
    R? Function(BookOwnedItem value)? book,
    R? Function(ComicOwnedItem value)? comic,
    R? Function(GameOwnedItem value)? game,
    R? Function(MangaOwnedItem value)? manga,
    R? Function(MovieOwnedItem value)? movie,
    R? Function(MusicOwnedItem value)? music,
    R? Function(TvOwnedItem value)? tv,
  }) =>
      movie?.call(value);
}

final class MusicOwnedItemDispatch implements LibraryOwnedItemDispatch {
  const MusicOwnedItemDispatch({required this.ref, required this.value});

  @override
  final OwnedItemRef ref;
  final MusicOwnedItem value;

  @override
  R? map<R>({
    R? Function(AnimeOwnedItem value)? anime,
    R? Function(BoardGameOwnedItem value)? boardgame,
    R? Function(BookOwnedItem value)? book,
    R? Function(ComicOwnedItem value)? comic,
    R? Function(GameOwnedItem value)? game,
    R? Function(MangaOwnedItem value)? manga,
    R? Function(MovieOwnedItem value)? movie,
    R? Function(MusicOwnedItem value)? music,
    R? Function(TvOwnedItem value)? tv,
  }) =>
      music?.call(value);
}

final class TvOwnedItemDispatch implements LibraryOwnedItemDispatch {
  const TvOwnedItemDispatch({required this.ref, required this.value});

  @override
  final OwnedItemRef ref;
  final TvOwnedItem value;

  @override
  R? map<R>({
    R? Function(AnimeOwnedItem value)? anime,
    R? Function(BoardGameOwnedItem value)? boardgame,
    R? Function(BookOwnedItem value)? book,
    R? Function(ComicOwnedItem value)? comic,
    R? Function(GameOwnedItem value)? game,
    R? Function(MangaOwnedItem value)? manga,
    R? Function(MovieOwnedItem value)? movie,
    R? Function(MusicOwnedItem value)? music,
    R? Function(TvOwnedItem value)? tv,
  }) =>
      tv?.call(value);
}
