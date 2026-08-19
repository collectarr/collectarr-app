import 'package:flutter/foundation.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/generic/ownership/generic_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';

export 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
export 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details.dart';
export 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_details.dart';
export 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details.dart';
export 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details.dart';
export 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details.dart';
export 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details.dart';
export 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details.dart';
export 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
export 'package:collectarr_app/features/library/kinds/generic/ownership/generic_owned_details.dart';

typedef VideoOwnedDetails = MovieOwnedDetails;

/// Shared abstract base class of kind-specific details for an [OwnedItem].
@immutable
abstract class OwnedItemDetails {
  const OwnedItemDetails();

  Map<String, dynamic> toJson();

  static OwnedItemDetails parseForKind(
    CatalogMediaKind kind,
    Map<String, dynamic> json,
  ) {
    if (kind == CatalogMediaKind.unknown) {
      return const GenericOwnedDetails();
    }
    return libraryKindRuntimeForKind(kind).decodeOwnedDetails(json);
  }

  static OwnedItemDetails defaultForKind(CatalogMediaKind kind) {
    if (kind == CatalogMediaKind.unknown) {
      return const GenericOwnedDetails();
    }
    return libraryKindRuntimeForKind(kind).defaultOwnedDetails();
  }

  ComicOwnedDetails? get comic =>
      this is ComicOwnedDetails ? this as ComicOwnedDetails : null;
  MangaOwnedDetails? get manga =>
      this is MangaOwnedDetails ? this as MangaOwnedDetails : null;
  AnimeOwnedDetails? get anime =>
      this is AnimeOwnedDetails ? this as AnimeOwnedDetails : null;
  MovieOwnedDetails? get movie =>
      this is MovieOwnedDetails ? this as MovieOwnedDetails : null;
  TvOwnedDetails? get tv =>
      this is TvOwnedDetails ? this as TvOwnedDetails : null;
  MovieOwnedDetails? get video =>
      this is MovieOwnedDetails ? this as MovieOwnedDetails : null;
  GameOwnedDetails? get game =>
      this is GameOwnedDetails ? this as GameOwnedDetails : null;
  MusicOwnedDetails? get music =>
      this is MusicOwnedDetails ? this as MusicOwnedDetails : null;
  BookOwnedDetails? get book =>
      this is BookOwnedDetails ? this as BookOwnedDetails : null;
  BoardgameOwnedDetails? get boardgame =>
      this is BoardgameOwnedDetails ? this as BoardgameOwnedDetails : null;
}
