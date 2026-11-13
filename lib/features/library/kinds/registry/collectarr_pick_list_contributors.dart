import 'package:collectarr_app/features/library/kinds/game_hardware/game_hardware_module.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/game_toy_module.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/book/book_module.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_module.dart';
import 'package:collectarr_app/features/library/kinds/game/game_module.dart';
import 'package:collectarr_app/features/library/kinds/music/music_module.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_definition_contributor.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_registry.dart';

/// Generated composition of the vocabulary contributors entry by each kind.
const defaultPickListDefinitionContributors = <PickListDefinitionContributor>[
  VocabularyPickListDefinitionContributor(
    kind: CatalogMediaKind.book,
    vocabularies: BookVocabularies.all,
    entries: BookVocabularies.entries,
  ),
  VocabularyPickListDefinitionContributor(
    kind: CatalogMediaKind.comic,
    vocabularies: ComicVocabularies.all,
    entries: ComicVocabularies.entries,
  ),
  VocabularyPickListDefinitionContributor(
    kind: CatalogMediaKind.music,
    vocabularies: MusicVocabularies.all,
    entries: MusicVocabularies.entries,
    entrySortNameUpdater: MusicVocabularies.updateSortName,
  ),
  VocabularyPickListDefinitionContributor(
    kind: CatalogMediaKind.game,
    vocabularies: GameVocabularies.all,
    entries: GameVocabularies.entries,
  ),
  VocabularyPickListDefinitionContributor(
    kind: CatalogMediaKind.gameHardware,
    vocabularies: GameHardwareVocabularies.all,
    entries: GameHardwareVocabularies.entries,
  ),
  VocabularyPickListDefinitionContributor(
    kind: CatalogMediaKind.gameToy,
    vocabularies: GameToyVocabularies.all,
    entries: GameToyVocabularies.entries,
  ),
];

const defaultPickListRegistry = PickListRegistry(
  contributors: defaultPickListDefinitionContributors,
);
