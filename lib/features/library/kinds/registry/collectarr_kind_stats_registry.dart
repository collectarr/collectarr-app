import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_linked_metadata_capability.dart';
import 'package:collectarr_app/features/library/config/library_relation_capability.dart';
import 'package:collectarr_app/features/library/config/library_stats_capability.dart';
import 'package:collectarr_app/features/library/config/library_ui_policy.dart';
import 'package:collectarr_app/features/library/config/library_value_capability.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_module.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_module.dart';
import 'package:collectarr_app/features/library/kinds/book/book_module.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_module.dart';
import 'package:collectarr_app/features/library/kinds/game/game_module.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_module.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_module.dart';
import 'package:collectarr_app/features/library/kinds/music/music_module.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_module.dart';

final Map<CatalogMediaKind, LibraryStatsCapability> collectarrKindStats =
    Map.unmodifiable(<CatalogMediaKind, LibraryStatsCapability>{
  CatalogMediaKind.anime: animeKindStats,
  CatalogMediaKind.boardgame: boardGameKindStats,
  CatalogMediaKind.book: bookKindStats,
  CatalogMediaKind.comic: comicKindStats,
  CatalogMediaKind.game: gameKindStats,
  CatalogMediaKind.manga: mangaKindStats,
  CatalogMediaKind.movie: movieKindStats,
  CatalogMediaKind.music: musicKindStats,
  CatalogMediaKind.tv: tvKindStats,
});

final Map<CatalogMediaKind, LibraryValueCapability?> collectarrKindValues =
    Map.unmodifiable(<CatalogMediaKind, LibraryValueCapability?>{
  CatalogMediaKind.anime: animeKindValue,
  CatalogMediaKind.boardgame: boardGameKindValue,
  CatalogMediaKind.book: bookKindValue,
  CatalogMediaKind.comic: comicKindValue,
  CatalogMediaKind.game: gameKindValue,
  CatalogMediaKind.manga: mangaKindValue,
  CatalogMediaKind.movie: movieKindValue,
  CatalogMediaKind.music: musicKindValue,
  CatalogMediaKind.tv: tvKindValue,
});

final Map<CatalogMediaKind, LibraryRelationCapability?>
    collectarrKindRelations =
    Map.unmodifiable(<CatalogMediaKind, LibraryRelationCapability?>{
  CatalogMediaKind.anime: animeKindRelations,
  CatalogMediaKind.boardgame: boardGameKindRelations,
  CatalogMediaKind.book: bookKindRelations,
  CatalogMediaKind.comic: comicKindRelations,
  CatalogMediaKind.game: gameKindRelations,
  CatalogMediaKind.manga: mangaKindRelations,
  CatalogMediaKind.movie: movieKindRelations,
  CatalogMediaKind.music: musicKindRelations,
  CatalogMediaKind.tv: tvKindRelations,
});

final Map<CatalogMediaKind, LibraryUiPolicy> collectarrKindUiPolicies =
    Map.unmodifiable(<CatalogMediaKind, LibraryUiPolicy>{
  CatalogMediaKind.anime: animeKindUiPolicy,
  CatalogMediaKind.boardgame: boardGameKindUiPolicy,
  CatalogMediaKind.book: bookKindUiPolicy,
  CatalogMediaKind.comic: comicKindUiPolicy,
  CatalogMediaKind.game: gameKindUiPolicy,
  CatalogMediaKind.manga: mangaKindUiPolicy,
  CatalogMediaKind.movie: movieKindUiPolicy,
  CatalogMediaKind.music: musicKindUiPolicy,
  CatalogMediaKind.tv: tvKindUiPolicy,
});

final Map<CatalogMediaKind, LibraryLinkedMetadataCapability>
    collectarrKindLinkedMetadata =
    Map.unmodifiable(<CatalogMediaKind, LibraryLinkedMetadataCapability>{
  CatalogMediaKind.anime: animeKindLinkedMetadata,
  CatalogMediaKind.boardgame: boardGameKindLinkedMetadata,
  CatalogMediaKind.book: bookKindLinkedMetadata,
  CatalogMediaKind.comic: comicKindLinkedMetadata,
  CatalogMediaKind.game: gameKindLinkedMetadata,
  CatalogMediaKind.manga: mangaKindLinkedMetadata,
  CatalogMediaKind.movie: movieKindLinkedMetadata,
  CatalogMediaKind.music: musicKindLinkedMetadata,
  CatalogMediaKind.tv: tvKindLinkedMetadata,
});
