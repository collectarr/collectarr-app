import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_module.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_module.dart';
import 'package:collectarr_app/features/library/kinds/book/book_module.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_module.dart';
import 'package:collectarr_app/features/library/kinds/game/game_module.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_module.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_module.dart';
import 'package:collectarr_app/features/library/kinds/music/music_module.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_module.dart';
import 'package:collectarr_app/features/library/entries/entry_kind_contributor.dart';

/// Explicit Entry composition root.
///
/// The registry knows only the structural contributor contract and the kind
/// key. Repository classes, IDs, payloads and projections stay in their kind
/// modules.
final Map<CatalogMediaKind, EntryKindContributor>
    collectarrEntryKindContributors =
    Map.unmodifiable(<CatalogMediaKind, EntryKindContributor>{
  CatalogMediaKind.anime: animeEntryContributor,
  CatalogMediaKind.boardgame: boardGameEntryContributor,
  CatalogMediaKind.book: bookEntryContributor,
  CatalogMediaKind.comic: comicEntryContributor,
  CatalogMediaKind.game: gameEntryContributor,
  CatalogMediaKind.manga: mangaEntryContributor,
  CatalogMediaKind.movie: movieEntryContributor,
  CatalogMediaKind.music: musicEntryContributor,
  CatalogMediaKind.tv: tvEntryContributor,
});

EntryKindContributor entryContributorForKind(CatalogMediaKind kind) {
  final contributor = collectarrEntryKindContributors[kind];
  if (contributor == null) {
    throw ArgumentError.value(kind, 'kind', 'Unsupported entry kind');
  }
  return contributor;
}

typedef LibraryEntrySummaryReader = Future<List<LibraryEntrySummary>> Function(
  LocalDatabase database,
);

final Map<CatalogMediaKind, LibraryEntrySummaryReader>
    libraryLibraryEntrySummaryReadersByKind = Map.unmodifiable({
  for (final entry in collectarrEntryKindContributors.entries)
    entry.key: entry.value.listActiveSummaries,
});
