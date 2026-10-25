import 'package:collectarr_app/features/library/kinds/registry/library_release_scope.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_linked_metadata_capability.dart';
import 'package:collectarr_app/features/library/config/library_relation_capability.dart';
import 'package:collectarr_app/features/library/config/library_stats_capability.dart';
import 'package:collectarr_app/features/library/config/library_ui_policy.dart';
import 'package:collectarr_app/features/library/config/library_value_capability.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_module.dart';
import 'package:collectarr_app/features/library/kinds/book/book_module.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_module.dart';
import 'package:collectarr_app/features/library/kinds/game/game_module.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/game_hardware_module.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/game_toy_module.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_module.dart';
import 'package:collectarr_app/features/library/kinds/music/music_module.dart';

final Map<CatalogMediaKind, LibraryStatsCapability> collectarrKindStats =
    releasedKindContributions(<CatalogMediaKind, LibraryStatsCapability>{
  CatalogMediaKind.boardgame: boardGameKindStats,
  CatalogMediaKind.book: bookKindStats,
  CatalogMediaKind.comic: comicKindStats,
  CatalogMediaKind.game: gameKindStats,
  CatalogMediaKind.gameHardware: gameHardwareKindStats,
  CatalogMediaKind.gameToy: gameToyKindStats,
  CatalogMediaKind.movie: movieKindStats,
  CatalogMediaKind.music: musicKindStats,
});

final Map<CatalogMediaKind, LibraryValueCapability?> collectarrKindValues =
    releasedKindContributions(<CatalogMediaKind, LibraryValueCapability?>{
  CatalogMediaKind.boardgame: boardGameKindValue,
  CatalogMediaKind.book: bookKindValue,
  CatalogMediaKind.comic: comicKindValue,
  CatalogMediaKind.game: gameKindValue,
  CatalogMediaKind.gameHardware: null,
  CatalogMediaKind.gameToy: null,
  CatalogMediaKind.movie: movieKindValue,
  CatalogMediaKind.music: musicKindValue,
});

final Map<CatalogMediaKind, LibraryRelationCapability?>
    collectarrKindRelations =
    releasedKindContributions(<CatalogMediaKind, LibraryRelationCapability?>{
  CatalogMediaKind.boardgame: boardGameKindRelations,
  CatalogMediaKind.book: bookKindRelations,
  CatalogMediaKind.comic: comicKindRelations,
  CatalogMediaKind.game: gameKindRelations,
  CatalogMediaKind.gameHardware: null,
  CatalogMediaKind.gameToy: null,
  CatalogMediaKind.movie: movieKindRelations,
  CatalogMediaKind.music: musicKindRelations,
});

final Map<CatalogMediaKind, LibraryUiPolicy> collectarrKindUiPolicies =
    releasedKindContributions(<CatalogMediaKind, LibraryUiPolicy>{
  CatalogMediaKind.boardgame: boardGameKindUiPolicy,
  CatalogMediaKind.book: bookKindUiPolicy,
  CatalogMediaKind.comic: comicKindUiPolicy,
  CatalogMediaKind.game: gameKindUiPolicy,
  CatalogMediaKind.gameHardware: gameHardwareKindUiPolicy,
  CatalogMediaKind.gameToy: gameToyKindUiPolicy,
  CatalogMediaKind.movie: movieKindUiPolicy,
  CatalogMediaKind.music: musicKindUiPolicy,
});

final Map<CatalogMediaKind, LibraryLinkedMetadataCapability>
    collectarrKindLinkedMetadata = releasedKindContributions(<CatalogMediaKind,
        LibraryLinkedMetadataCapability>{
  CatalogMediaKind.boardgame: boardGameKindLinkedMetadata,
  CatalogMediaKind.book: bookKindLinkedMetadata,
  CatalogMediaKind.comic: comicKindLinkedMetadata,
  CatalogMediaKind.game: gameKindLinkedMetadata,
  CatalogMediaKind.gameHardware: gameHardwareKindLinkedMetadata,
  CatalogMediaKind.gameToy: gameToyKindLinkedMetadata,
  CatalogMediaKind.movie: movieKindLinkedMetadata,
  CatalogMediaKind.music: musicKindLinkedMetadata,
});
