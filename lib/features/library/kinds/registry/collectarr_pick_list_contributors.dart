import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/anime/vocabulary/anime_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/vocabulary/boardgame_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/book/vocabulary/book_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/comic/vocabulary/comic_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/game/vocabulary/game_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/manga/vocabulary/manga_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/movie/vocabulary/movie_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/tv/vocabulary/tv_vocabularies.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_definition_contributor.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_registry.dart';

/// Generated composition of the vocabulary contributors owned by each kind.
const defaultPickListDefinitionContributors = <PickListDefinitionContributor>[
  VocabularyPickListDefinitionContributor(
    kind: CatalogMediaKind.anime,
    vocabularies: AnimeVocabularies.all,
    ownedValueCounter: AnimeVocabularies.countOwnedValue,
    ownedMergePreviewer: AnimeVocabularies.previewOwnedMerge,
    ownedMerger: AnimeVocabularies.applyOwnedMerge,
  ),
  VocabularyPickListDefinitionContributor(
    kind: CatalogMediaKind.boardgame,
    vocabularies: BoardGameVocabularies.all,
    ownedValueCounter: BoardGameVocabularies.countOwnedValue,
    ownedMergePreviewer: BoardGameVocabularies.previewOwnedMerge,
    ownedMerger: BoardGameVocabularies.applyOwnedMerge,
  ),
  VocabularyPickListDefinitionContributor(
    kind: CatalogMediaKind.book,
    vocabularies: BookVocabularies.all,
    ownedValueCounter: BookVocabularies.countOwnedValue,
    ownedMergePreviewer: BookVocabularies.previewOwnedMerge,
    ownedMerger: BookVocabularies.applyOwnedMerge,
  ),
  VocabularyPickListDefinitionContributor(
    kind: CatalogMediaKind.comic,
    vocabularies: ComicVocabularies.all,
    ownedValueCounter: ComicVocabularies.countOwnedValue,
    ownedMergePreviewer: ComicVocabularies.previewOwnedMerge,
    ownedMerger: ComicVocabularies.applyOwnedMerge,
  ),
  VocabularyPickListDefinitionContributor(
    kind: CatalogMediaKind.game,
    vocabularies: GameVocabularies.all,
    ownedValueCounter: GameVocabularies.countOwnedValue,
    ownedMergePreviewer: GameVocabularies.previewOwnedMerge,
    ownedMerger: GameVocabularies.applyOwnedMerge,
  ),
  VocabularyPickListDefinitionContributor(
    kind: CatalogMediaKind.manga,
    vocabularies: MangaVocabularies.all,
    ownedValueCounter: MangaVocabularies.countOwnedValue,
    ownedMergePreviewer: MangaVocabularies.previewOwnedMerge,
    ownedMerger: MangaVocabularies.applyOwnedMerge,
  ),
  VocabularyPickListDefinitionContributor(
    kind: CatalogMediaKind.movie,
    vocabularies: MovieVocabularies.all,
    ownedValueCounter: MovieVocabularies.countOwnedValue,
    ownedMergePreviewer: MovieVocabularies.previewOwnedMerge,
    ownedMerger: MovieVocabularies.applyOwnedMerge,
  ),
  VocabularyPickListDefinitionContributor(
    kind: CatalogMediaKind.music,
    vocabularies: MusicVocabularies.all,
    ownedValueCounter: MusicVocabularies.countOwnedValue,
    ownedMergePreviewer: MusicVocabularies.previewOwnedMerge,
    ownedMerger: MusicVocabularies.applyOwnedMerge,
  ),
  VocabularyPickListDefinitionContributor(
    kind: CatalogMediaKind.tv,
    vocabularies: TvVocabularies.all,
    ownedValueCounter: TvVocabularies.countOwnedValue,
    ownedMergePreviewer: TvVocabularies.previewOwnedMerge,
    ownedMerger: TvVocabularies.applyOwnedMerge,
  ),
];

const defaultPickListRegistry = PickListRegistry(
  contributors: defaultPickListDefinitionContributors,
);
