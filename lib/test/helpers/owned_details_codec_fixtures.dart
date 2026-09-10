import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details_codec.dart';

/// Explicit test registrations for the kind-owned serialization contracts.
///
/// Production code never needs to discover or dispatch these codecs as a
/// universal domain registry. Each kind uses its own codec directly; this map
/// exists only to run the same serialization contract against all kinds.
final Map<CatalogMediaKind, OwnedDetailsPersistenceCodec>
    ownedDetailsCodecsByKind = {
  CatalogMediaKind.anime: const AnimeOwnedDetailsCodec(),
  CatalogMediaKind.boardgame: const BoardgameOwnedDetailsCodec(),
  CatalogMediaKind.book: const BookOwnedDetailsCodec(),
  CatalogMediaKind.comic: const ComicOwnedDetailsCodec(),
  CatalogMediaKind.game: const GameOwnedDetailsCodec(),
  CatalogMediaKind.manga: const MangaOwnedDetailsCodec(),
  CatalogMediaKind.movie: const MovieOwnedDetailsCodec(),
  CatalogMediaKind.music: const MusicOwnedDetailsCodec(),
  CatalogMediaKind.tv: const TvOwnedDetailsCodec(),
};

OwnedDetailsPersistenceCodec ownedDetailsCodecForTest(CatalogMediaKind kind) {
  final codec = ownedDetailsCodecsByKind[kind];
  if (codec == null) {
    throw ArgumentError('No concrete Owned details fixture for kind: $kind');
  }
  return codec;
}
