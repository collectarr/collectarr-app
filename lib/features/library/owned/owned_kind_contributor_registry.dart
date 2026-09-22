import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_module.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_module.dart';
import 'package:collectarr_app/features/library/kinds/book/book_module.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_module.dart';
import 'package:collectarr_app/features/library/kinds/game/game_module.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_module.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_module.dart';
import 'package:collectarr_app/features/library/kinds/music/music_module.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_module.dart';
import 'package:collectarr_app/features/library/owned/owned_kind_contributor.dart';

/// Explicit Owned composition root.
///
/// The registry knows only the structural contributor contract and the kind
/// key. Repository classes, IDs, payloads and projections stay in their kind
/// modules.
final Map<CatalogMediaKind, OwnedKindContributor>
    collectarrOwnedKindContributors =
    Map.unmodifiable(<CatalogMediaKind, OwnedKindContributor>{
  CatalogMediaKind.anime: animeOwnedContributor,
  CatalogMediaKind.boardgame: boardGameOwnedContributor,
  CatalogMediaKind.book: bookOwnedContributor,
  CatalogMediaKind.comic: comicOwnedContributor,
  CatalogMediaKind.game: gameOwnedContributor,
  CatalogMediaKind.manga: mangaOwnedContributor,
  CatalogMediaKind.movie: movieOwnedContributor,
  CatalogMediaKind.music: musicOwnedContributor,
  CatalogMediaKind.tv: tvOwnedContributor,
});

OwnedKindContributor ownedContributorForKind(CatalogMediaKind kind) {
  final contributor = collectarrOwnedKindContributors[kind];
  if (contributor == null) {
    throw ArgumentError.value(kind, 'kind', 'Unsupported owned kind');
  }
  return contributor;
}

typedef LibraryOwnedSummaryReader = Future<List<OwnedItemSummary>> Function(
  LocalDatabase database,
);

final Map<CatalogMediaKind, LibraryOwnedSummaryReader>
    libraryOwnedSummaryReadersByKind = Map.unmodifiable({
  for (final entry in collectarrOwnedKindContributors.entries)
    entry.key: entry.value.listActiveSummaries,
});
