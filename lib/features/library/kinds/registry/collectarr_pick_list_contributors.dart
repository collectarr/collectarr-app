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

/// Composition-root registration of kind-owned pick-list definitions.
///
/// This is the only place that combines all concrete kind vocabulary modules
/// for the generic pick-list manager.
const defaultPickListDefinitionContributors = <PickListDefinitionContributor>[
  VocabularyPickListDefinitionContributor(
    kind: CatalogMediaKind.comic,
    vocabularies: ComicVocabularies.all,
  ),
  VocabularyPickListDefinitionContributor(
    kind: CatalogMediaKind.manga,
    vocabularies: MangaVocabularies.all,
  ),
  VocabularyPickListDefinitionContributor(
    kind: CatalogMediaKind.book,
    vocabularies: BookVocabularies.all,
  ),
  VocabularyPickListDefinitionContributor(
    kind: CatalogMediaKind.game,
    vocabularies: GameVocabularies.all,
  ),
  VocabularyPickListDefinitionContributor(
    kind: CatalogMediaKind.boardgame,
    vocabularies: BoardGameVocabularies.all,
  ),
  VocabularyPickListDefinitionContributor(
    kind: CatalogMediaKind.movie,
    vocabularies: MovieVocabularies.all,
  ),
  VocabularyPickListDefinitionContributor(
    kind: CatalogMediaKind.tv,
    vocabularies: TvVocabularies.all,
  ),
  VocabularyPickListDefinitionContributor(
    kind: CatalogMediaKind.anime,
    vocabularies: AnimeVocabularies.all,
  ),
  VocabularyPickListDefinitionContributor(
    kind: CatalogMediaKind.music,
    vocabularies: MusicVocabularies.all,
  ),
];

const defaultPickListRegistry = PickListRegistry(
  contributors: defaultPickListDefinitionContributors,
);
