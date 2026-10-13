import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/music/music_module.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_definition_contributor.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_registry.dart';

/// Generated composition of the vocabulary contributors entry by each kind.
const defaultPickListDefinitionContributors = <PickListDefinitionContributor>[
  VocabularyPickListDefinitionContributor(
    kind: CatalogMediaKind.music,
    vocabularies: MusicVocabularies.all,
    entryOptionLoader: MusicVocabularies.entryOptions,
    entryUsageCounter: MusicVocabularies.entryUsageCounts,
    entrySortNameUpdater: MusicVocabularies.updateSortName,
    entryMergePreviewer: MusicVocabularies.previewEntryMerge,
    entryMerger: MusicVocabularies.applyEntryMerge,
  ),
];

const defaultPickListRegistry = PickListRegistry(
  contributors: defaultPickListDefinitionContributors,
);
