import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/generic/ownership/generic_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details_codec.dart';

/// Composition-root map for the common JSON owned-details boundary.
///
/// Generic persistence and sync code may use this map to decode a payload,
/// but it must not inspect the returned concrete details. Kind semantics stay
/// in the codec implementations under their owning kind.
final collectarrOwnedDetailsCodecs =
    <CatalogMediaKind, OwnedDetailsPersistenceCodec>{
  CatalogMediaKind.comic: const ComicOwnedDetailsCodec(),
  CatalogMediaKind.manga: const MangaOwnedDetailsCodec(),
  CatalogMediaKind.book: const BookOwnedDetailsCodec(),
  CatalogMediaKind.game: const GameOwnedDetailsCodec(),
  CatalogMediaKind.boardgame: const BoardgameOwnedDetailsCodec(),
  CatalogMediaKind.movie: const MovieOwnedDetailsCodec(),
  CatalogMediaKind.tv: const TvOwnedDetailsCodec(),
  CatalogMediaKind.anime: const AnimeOwnedDetailsCodec(),
  CatalogMediaKind.music: const MusicOwnedDetailsCodec(),
  CatalogMediaKind.unknown: const GenericOwnedDetailsCodec(),
};

OwnedDetailsPersistenceCodec collectarrOwnedDetailsCodecForKind(
  CatalogMediaKind kind,
) {
  return collectarrOwnedDetailsCodecs[kind] ??
      collectarrOwnedDetailsCodecs[CatalogMediaKind.unknown]!;
}
