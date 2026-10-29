import 'package:collectarr_app/features/library/kinds/game_hardware/game_hardware_module.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/game_toy_module.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_module.dart';
import 'package:collectarr_app/features/library/kinds/game/game_module.dart';
import 'package:collectarr_app/features/library/kinds/music/music_module.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_definition_contributor.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_registry.dart';

/// Generated composition of the vocabulary contributors entry by each kind.
const defaultPickListDefinitionContributors = <PickListDefinitionContributor>[
  VocabularyPickListDefinitionContributor(
    kind: CatalogMediaKind.comic,
    vocabularies: ComicVocabularies.all,
    entryOptionLoader: ComicVocabularies.entryOptions,
    entryUsageCounter: ComicVocabularies.entryUsageCounts,
    entryMergePreviewer: ComicVocabularies.previewEntryMerge,
    entryMerger: ComicVocabularies.applyEntryMerge,
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
    kind: CatalogMediaKind.game,
    vocabularies: GameVocabularies.all,
    entryOptionLoader: GameVocabularies.entryOptions,
    entryUsageCounter: GameVocabularies.entryUsageCounts,
    entryMergePreviewer: GameVocabularies.previewEntryMerge,
    entryMerger: GameVocabularies.applyEntryMerge,
  ),
  VocabularyPickListDefinitionContributor(
    kind: CatalogMediaKind.gameHardware,
    vocabularies: GameHardwareVocabularies.all,
    entryOptionLoader: GameHardwareVocabularies.entryOptions,
    entryUsageCounter: GameHardwareVocabularies.entryUsageCounts,
    entryMergePreviewer: GameHardwareVocabularies.previewEntryMerge,
    entryMerger: GameHardwareVocabularies.applyEntryMerge,
  ),
  VocabularyPickListDefinitionContributor(
    kind: CatalogMediaKind.gameToy,
    vocabularies: GameToyVocabularies.all,
    entryOptionLoader: GameToyVocabularies.entryOptions,
    entryUsageCounter: GameToyVocabularies.entryUsageCounts,
    entryMergePreviewer: GameToyVocabularies.previewEntryMerge,
    entryMerger: GameToyVocabularies.applyEntryMerge,
  ),
];

const defaultPickListRegistry = PickListRegistry(
  contributors: defaultPickListDefinitionContributors,
);
