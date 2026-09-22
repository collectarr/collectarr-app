import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation.dart';
import 'package:collectarr_app/features/library/config/library_metadata_capability.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_module.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_module.dart';
import 'package:collectarr_app/features/library/kinds/book/book_module.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_module.dart';
import 'package:collectarr_app/features/library/kinds/game/game_module.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_module.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_module.dart';
import 'package:collectarr_app/features/library/kinds/music/music_module.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_module.dart';

final Map<CatalogMediaKind, List<PhysicalMediaFormat>>
    collectarrKindPhysicalMediaFormats =
    Map.unmodifiable(<CatalogMediaKind, List<PhysicalMediaFormat>>{
  CatalogMediaKind.anime: animeKindPhysicalMediaFormats,
  CatalogMediaKind.boardgame: boardGameKindPhysicalMediaFormats,
  CatalogMediaKind.book: bookKindPhysicalMediaFormats,
  CatalogMediaKind.comic: comicKindPhysicalMediaFormats,
  CatalogMediaKind.game: gameKindPhysicalMediaFormats,
  CatalogMediaKind.manga: mangaKindPhysicalMediaFormats,
  CatalogMediaKind.movie: movieKindPhysicalMediaFormats,
  CatalogMediaKind.music: musicKindPhysicalMediaFormats,
  CatalogMediaKind.tv: tvKindPhysicalMediaFormats,
});

final Map<CatalogMediaKind, LibraryMediaPresentation>
    collectarrKindPresentations =
    Map.unmodifiable(<CatalogMediaKind, LibraryMediaPresentation>{
  CatalogMediaKind.anime: animeKindPresentation,
  CatalogMediaKind.boardgame: boardGameKindPresentation,
  CatalogMediaKind.book: bookKindPresentation,
  CatalogMediaKind.comic: comicKindPresentation,
  CatalogMediaKind.game: gameKindPresentation,
  CatalogMediaKind.manga: mangaKindPresentation,
  CatalogMediaKind.movie: movieKindPresentation,
  CatalogMediaKind.music: musicKindPresentation,
  CatalogMediaKind.tv: tvKindPresentation,
});

final Map<CatalogMediaKind, LibraryMetadataCapability> collectarrKindMetadata =
    Map.unmodifiable(<CatalogMediaKind, LibraryMetadataCapability>{
  CatalogMediaKind.anime: animeKindMetadata,
  CatalogMediaKind.boardgame: boardGameKindMetadata,
  CatalogMediaKind.book: bookKindMetadata,
  CatalogMediaKind.comic: comicKindMetadata,
  CatalogMediaKind.game: gameKindMetadata,
  CatalogMediaKind.manga: mangaKindMetadata,
  CatalogMediaKind.movie: movieKindMetadata,
  CatalogMediaKind.music: musicKindMetadata,
  CatalogMediaKind.tv: tvKindMetadata,
});
