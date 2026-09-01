import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/game/presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_fields.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:collectarr_app/features/library/config/workspace_presentation_support.dart';

const gamesMetadataLabels = LibraryMetadataLabels(
  values: {'creators': 'Creators', 'genres': 'Genres'},
);

const gamesLibraryMediaBuilder = GameLibraryMediaPresentationBuilder(
  metadataLabels: gamesMetadataLabels,
);

const gamesPreviewLabels = LibraryMediaPreviewLabels(
  values: {'series': 'Series', 'item_count': 'Items'},
);

const gamesStatsLabels = LibraryMediaStatsLabels(
  values: {
    'top_series': 'Top Series',
    'top_publisher': 'Top Publishers / Studios',
  },
);

const gamesLibraryGroupLabels = LibraryMediaGroupLabels(
  values: {
    'series': 'Series',
    'series_plural': 'Series',
    'unknown_series': 'Unknown series',
    'publisher': 'Publisher / Studio',
    'publisher_plural': 'Publishers / Studios',
    'unknown_publisher': 'Unknown publisher / studio',
  },
);

const gamesLibraryBucketLabelOverrides = LibraryBucketLabelOverrides();

final gamesLibraryFilterDefinitions = <LibraryFilterDefinition<dynamic>>[
  LibraryFilterDefinition<dynamic>(
    id: 'series',
    label: 'Series',
    anyLabel: 'Any series',
    value: (item) => (item.dto is WorkspaceDtoAdapter)
        ? (item.dto as WorkspaceDtoAdapter).seriesTitle
        : null,
  ),
  LibraryFilterDefinition<dynamic>(
    id: 'location',
    label: 'Location',
    anyLabel: 'Any location',
  ),
  LibraryFilterDefinition<dynamic>(
    id: 'tag',
    label: 'Tag',
    anyLabel: 'Any tag',
    inputKind: LibraryFilterInputKind.autocomplete,
  ),
  LibraryFilterDefinition<dynamic>(
    id: 'publisher',
    label: 'Publisher / Studio',
    anyLabel: 'Any publisher / studio',
    value: (item) => (item.dto is WorkspaceDtoAdapter)
        ? (item.dto as WorkspaceDtoAdapter).publisher
        : null,
  ),
  LibraryFilterDefinition<dynamic>(
    id: 'year',
    label: 'Year',
    anyLabel: 'Any year',
    value: (item) => (item.dto is WorkspaceDtoAdapter)
        ? (item.dto as WorkspaceDtoAdapter).releaseDate?.year.toString()
        : null,
  ),
  LibraryFilterDefinition<dynamic>(
    id: 'condition',
    label: 'Condition',
    anyLabel: 'Any condition',
  ),
  LibraryFilterDefinition<dynamic>(
    id: 'country',
    label: 'Country',
    anyLabel: 'Any country',
    value: (item) => (item.dto is WorkspaceDtoAdapter)
        ? (item.dto as WorkspaceDtoAdapter).country
        : null,
  ),
  LibraryFilterDefinition<dynamic>(
    id: 'language',
    label: 'Language',
    anyLabel: 'Any language',
    value: (item) => (item.dto is WorkspaceDtoAdapter)
        ? (item.dto as WorkspaceDtoAdapter).language
        : null,
  ),
];

String gamesLibraryBucketLabelBuilder(LibraryBucketingContext context) {
  return defaultLibraryBucketLabel(
    context,
    gamesLibraryGroupLabels,
    gamesLibraryBucketLabelOverrides,
  );
}

final gamesLibraryMediaPresentation = LibraryMediaPresentation(
  searchFieldLabels: const LibraryMediaSearchFieldLabels(
    queryHint: 'Enter title, creator, or keyword...',
    emptySearchMessage: 'Enter a title, creator, series, or keyword.',
  ),
  filterLabels: const LibraryMediaFilterLabels(
    values: {
      'series': 'Series',
      'series_any': 'Any series',
      'publisher': 'Publisher / Studio',
      'publisher_any': 'Any publisher / studio',
      'year': 'Year',
      'year_any': 'Any year',
    },
  ),
  groupLabels: gamesLibraryGroupLabels,
  builder: gamesLibraryMediaBuilder,
  projector: const GameWorkspaceProjector(),
  bucketLabelBuilder: gamesLibraryBucketLabelBuilder,
  previewLabels: gamesPreviewLabels,
  statsLabels: gamesStatsLabels,
  filterDefinitions: gamesLibraryFilterDefinitions,
  fieldDefinitions: gameLibraryFieldDefinitions,
);
