import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/providers/adapters/musicbrainz/musicbrainz_provider.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_connector.dart';
import 'package:collectarr_app/features/providers/runtime/provider_http_client.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_module.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_module.dart';
import 'package:collectarr_app/features/library/kinds/book/book_module.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_module.dart';
import 'package:collectarr_app/features/library/kinds/game/game_module.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_module.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_module.dart';
import 'package:collectarr_app/features/library/kinds/music/music_module.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_module.dart';

/// Builds the MusicBrainz connector at the provider composition boundary.
///
/// The runtime provider registry only asks for a connector. The protocol
/// adapter and the Music-owned candidate mapping stay composed here, without
/// leaking a kind import into the generic provider runtime.
ProviderConnector buildMusicBrainzProviderConnector({
  ProviderHttpClient? httpClient,
}) {
  return MusicMusicBrainzProviderAdapter(
    provider: MusicBrainzProvider(httpClient: httpClient),
  ).toConnector();
}

final Map<CatalogMediaKind, ProviderCorrectionBuilder>
    libraryProviderCorrectionBuildersByKind = {
  CatalogMediaKind.anime:
      const AnimeLibraryKindProviderMapper().buildCorrections,
  CatalogMediaKind.boardgame:
      const BoardGameLibraryKindProviderMapper().buildCorrections,
  CatalogMediaKind.book: const BookLibraryKindProviderMapper().buildCorrections,
  CatalogMediaKind.comic:
      const ComicLibraryKindProviderMapper().buildCorrections,
  CatalogMediaKind.game: const GameLibraryKindProviderMapper().buildCorrections,
  CatalogMediaKind.manga:
      const MangaLibraryKindProviderMapper().buildCorrections,
  CatalogMediaKind.movie:
      const MovieLibraryKindProviderMapper().buildCorrections,
  CatalogMediaKind.music: buildMusicProviderCorrections,
  CatalogMediaKind.tv: const TvLibraryKindProviderMapper().buildCorrections,
};

final Map<CatalogMediaKind, ProviderCorrectionWireEncoder>
    libraryProviderCorrectionWireEncodersByKind =
    Map.unmodifiable(<CatalogMediaKind, ProviderCorrectionWireEncoder>{
  CatalogMediaKind.anime: encodeAnimeProviderCorrectionsForWire,
  CatalogMediaKind.boardgame: encodeBoardGameProviderCorrectionsForWire,
  CatalogMediaKind.book: encodeBookProviderCorrectionsForWire,
  CatalogMediaKind.comic: encodeComicProviderCorrectionsForWire,
  CatalogMediaKind.game: encodeGameProviderCorrectionsForWire,
  CatalogMediaKind.manga: encodeMangaProviderCorrectionsForWire,
  CatalogMediaKind.movie: encodeMovieProviderCorrectionsForWire,
  CatalogMediaKind.music: encodeMusicProviderCorrectionsForWire,
  CatalogMediaKind.tv: encodeTvProviderCorrectionsForWire,
});

ProviderCorrectionWireEncoder providerCorrectionWireEncoderForKind(
  CatalogMediaKind kind,
) {
  final encoder = libraryProviderCorrectionWireEncodersByKind[kind];
  if (encoder == null) {
    throw ArgumentError.value(kind, 'kind', 'Unsupported correction kind');
  }
  return encoder;
}
