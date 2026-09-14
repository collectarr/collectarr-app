import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/anime/provider/anime_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/provider/boardgame_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/book/provider/book_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/comic/provider/comic_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/game/provider/game_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/manga/provider/manga_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/movie/provider/movie_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';
import 'package:collectarr_app/features/library/kinds/tv/provider/tv_provider_mapper.dart';

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
  CatalogMediaKind.music:
      const MusicLibraryKindProviderMapper().catalogCandidateFromEnvelope,
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
  CatalogMediaKind.music:
      const MusicLibraryKindProviderMapper().buildCorrections,
  CatalogMediaKind.tv: const TvLibraryKindProviderMapper().buildCorrections,
};
