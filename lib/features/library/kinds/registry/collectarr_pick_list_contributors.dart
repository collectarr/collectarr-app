import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_module.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_module.dart';
import 'package:collectarr_app/features/library/kinds/book/book_module.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_module.dart';
import 'package:collectarr_app/features/library/kinds/game/game_module.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_module.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_module.dart';
import 'package:collectarr_app/features/library/kinds/music/music_module.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_module.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_definition_contributor.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_registry.dart';

/// Generated composition of the vocabulary contributors entry by each kind.
const defaultPickListDefinitionContributors = <PickListDefinitionContributor>[
  VocabularyPickListDefinitionContributor(
    kind: CatalogMediaKind.anime,
    vocabularies: AnimeVocabularies.all,
    entryOptionLoader: AnimeVocabularies.entryOptions,
    entryUsageCounter: AnimeVocabularies.entryUsageCounts,
    entryMergePreviewer: AnimeVocabularies.previewEntryMerge,
    entryMerger: AnimeVocabularies.applyEntryMerge,
  ),
  VocabularyPickListDefinitionContributor(
    kind: CatalogMediaKind.boardgame,
    vocabularies: BoardGameVocabularies.all,
    entryOptionLoader: BoardGameVocabularies.entryOptions,
    entryUsageCounter: BoardGameVocabularies.entryUsageCounts,
    entryMergePreviewer: BoardGameVocabularies.previewEntryMerge,
    entryMerger: BoardGameVocabularies.applyEntryMerge,
  ),
  VocabularyPickListDefinitionContributor(
    kind: CatalogMediaKind.book,
    vocabularies: BookVocabularies.all,
    entryOptionLoader: BookVocabularies.entryOptions,
    entryUsageCounter: BookVocabularies.entryUsageCounts,
    entryMergePreviewer: BookVocabularies.previewEntryMerge,
    entryMerger: BookVocabularies.applyEntryMerge,
  ),
  VocabularyPickListDefinitionContributor(
    kind: CatalogMediaKind.comic,
    vocabularies: ComicVocabularies.all,
    entryOptionLoader: ComicVocabularies.entryOptions,
    entryUsageCounter: ComicVocabularies.entryUsageCounts,
    entryMergePreviewer: ComicVocabularies.previewEntryMerge,
    entryMerger: ComicVocabularies.applyEntryMerge,
  ),
  VocabularyPickListDefinitionContributor(
    kind: CatalogMediaKind.game,
    vocabularies: GameVocabularies.all,
    entryOptionLoader: GameVocabularies.entryOptions,
    entryUsageCounter: GameVocabularies.entryUsageCounts,
    entryMergePreviewer: GameVocabularies.previewEntryMerge,
    entryMerger: GameVocabularies.applyEntryMerge,
  ),
  VocabularyPickListDefinitionContributor(
    kind: CatalogMediaKind.manga,
    vocabularies: MangaVocabularies.all,
    entryOptionLoader: MangaVocabularies.entryOptions,
    entryUsageCounter: MangaVocabularies.entryUsageCounts,
    entryMergePreviewer: MangaVocabularies.previewEntryMerge,
    entryMerger: MangaVocabularies.applyEntryMerge,
  ),
  VocabularyPickListDefinitionContributor(
    kind: CatalogMediaKind.movie,
    vocabularies: MovieVocabularies.all,
    entryOptionLoader: MovieVocabularies.entryOptions,
    entryUsageCounter: MovieVocabularies.entryUsageCounts,
    entryMergePreviewer: MovieVocabularies.previewEntryMerge,
    entryMerger: MovieVocabularies.applyEntryMerge,
  ),
  VocabularyPickListDefinitionContributor(
    kind: CatalogMediaKind.music,
    vocabularies: MusicVocabularies.all,
    entryOptionLoader: MusicVocabularies.entryOptions,
    entryUsageCounter: MusicVocabularies.entryUsageCounts,
    entrySortNameUpdater: MusicVocabularies.updateSortName,
    entryMergePreviewer: MusicVocabularies.previewEntryMerge,
    entryMerger: MusicVocabularies.applyEntryMerge,
  ),
  VocabularyPickListDefinitionContributor(
    kind: CatalogMediaKind.tv,
    vocabularies: TvVocabularies.all,
    entryOptionLoader: TvVocabularies.entryOptions,
    entryUsageCounter: TvVocabularies.entryUsageCounts,
    entryMergePreviewer: TvVocabularies.previewEntryMerge,
    entryMerger: TvVocabularies.applyEntryMerge,
  ),
];

const defaultPickListRegistry = PickListRegistry(
  contributors: defaultPickListDefinitionContributors,
);
