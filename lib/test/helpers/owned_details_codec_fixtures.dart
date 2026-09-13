import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details_codec.dart';

/// Test-only adapter for executing the same serialization contract against
/// concrete kind codecs. Production code does not use a common details codec.
abstract interface class OwnedDetailsTestFixture {
  JsonEncodable fromJson(JsonMap json);

  JsonEncodable defaultDetails();

  void validate(JsonEncodable details);
}

final class _TypedOwnedDetailsTestFixture<TDetails extends JsonEncodable>
    implements OwnedDetailsTestFixture {
  const _TypedOwnedDetailsTestFixture({
    required this.decode,
    required this.defaults,
  });

  final TDetails Function(JsonMap json) decode;
  final TDetails Function() defaults;

  @override
  TDetails fromJson(JsonMap json) => decode(json);

  @override
  TDetails defaultDetails() => defaults();

  @override
  void validate(JsonEncodable details) {
    if (details is! TDetails) {
      throw ArgumentError(
        'Invalid owned details type "${details.runtimeType}". '
        'Expected "$TDetails".',
      );
    }
  }
}

OwnedDetailsTestFixture ownedDetailsFixtureForTest(CatalogMediaKind kind) {
  return switch (kind) {
    CatalogMediaKind.anime => _TypedOwnedDetailsTestFixture<AnimeOwnedDetails>(
        decode: const AnimeOwnedDetailsCodec().fromJson,
        defaults: const AnimeOwnedDetailsCodec().defaultDetails,
      ),
    CatalogMediaKind.boardgame =>
      _TypedOwnedDetailsTestFixture<BoardgameOwnedDetails>(
        decode: const BoardgameOwnedDetailsCodec().fromJson,
        defaults: const BoardgameOwnedDetailsCodec().defaultDetails,
      ),
    CatalogMediaKind.book => _TypedOwnedDetailsTestFixture<BookOwnedDetails>(
        decode: const BookOwnedDetailsCodec().fromJson,
        defaults: const BookOwnedDetailsCodec().defaultDetails,
      ),
    CatalogMediaKind.comic => _TypedOwnedDetailsTestFixture<ComicOwnedDetails>(
        decode: const ComicOwnedDetailsCodec().fromJson,
        defaults: const ComicOwnedDetailsCodec().defaultDetails,
      ),
    CatalogMediaKind.game => _TypedOwnedDetailsTestFixture<GameOwnedDetails>(
        decode: const GameOwnedDetailsCodec().fromJson,
        defaults: const GameOwnedDetailsCodec().defaultDetails,
      ),
    CatalogMediaKind.manga => _TypedOwnedDetailsTestFixture<MangaOwnedDetails>(
        decode: const MangaOwnedDetailsCodec().fromJson,
        defaults: const MangaOwnedDetailsCodec().defaultDetails,
      ),
    CatalogMediaKind.movie => _TypedOwnedDetailsTestFixture<MovieOwnedDetails>(
        decode: const MovieOwnedDetailsCodec().fromJson,
        defaults: const MovieOwnedDetailsCodec().defaultDetails,
      ),
    CatalogMediaKind.music => _TypedOwnedDetailsTestFixture<MusicOwnedDetails>(
        decode: const MusicOwnedDetailsCodec().fromJson,
        defaults: const MusicOwnedDetailsCodec().defaultDetails,
      ),
    CatalogMediaKind.tv => _TypedOwnedDetailsTestFixture<TvOwnedDetails>(
        decode: const TvOwnedDetailsCodec().fromJson,
        defaults: const TvOwnedDetailsCodec().defaultDetails,
      ),
    CatalogMediaKind.unknown =>
      throw ArgumentError('No concrete Owned details fixture for kind: $kind'),
  };
}
