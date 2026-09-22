import 'package:collectarr_app/core/models/catalog_media_kind.dart';
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

/// Provider's explicit semantic composition root.
///
/// Provider clients own transport. These callbacks are the only place where
/// a normalized provider envelope is handed to a kind-owned mapper.
final Map<CatalogMediaKind, ProviderMetadataCandidateMapper>
    libraryProviderMetadataMappersByKind = {
  CatalogMediaKind.anime:
      const AnimeLibraryKindProviderMapper().catalogCandidateFromEnvelope,
  CatalogMediaKind.boardgame:
      const BoardGameLibraryKindProviderMapper().catalogCandidateFromEnvelope,
  CatalogMediaKind.book:
      const BookLibraryKindProviderMapper().catalogCandidateFromEnvelope,
  CatalogMediaKind.comic:
      const ComicLibraryKindProviderMapper().catalogCandidateFromEnvelope,
  CatalogMediaKind.game:
      const GameLibraryKindProviderMapper().catalogCandidateFromEnvelope,
  CatalogMediaKind.manga:
      const MangaLibraryKindProviderMapper().catalogCandidateFromEnvelope,
  CatalogMediaKind.movie:
      const MovieLibraryKindProviderMapper().catalogCandidateFromEnvelope,
  CatalogMediaKind.tv:
      const TvLibraryKindProviderMapper().catalogCandidateFromEnvelope,
};

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
