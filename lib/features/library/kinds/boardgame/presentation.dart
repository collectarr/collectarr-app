import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_fields.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:collectarr_app/features/library/config/workspace_presentation_support.dart';

const boardGamesMetadataLabels = LibraryMetadataLabels(
  values: {'creators': 'Creators', 'genres': 'Genres'},
);

const boardGamesLibraryMediaBuilder = BoardGameLibraryMediaPresentationBuilder(
  metadataLabels: boardGamesMetadataLabels,
);

const boardGamesPreviewLabels = LibraryMediaPreviewLabels(
  values: {'series': 'Series', 'item_count': 'Items'},
);

const boardGamesStatsLabels = LibraryMediaStatsLabels(
  values: {
    'top_series': 'Top Series',
    'top_publisher': 'Top Publishers / Designers',
  },
);

final boardGamesLibraryFilterDefinitions = <LibraryFilterDefinition<dynamic>>[
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
    label: 'Publisher / Designer',
    anyLabel: 'Any publisher / designer',
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

const boardGamesLibraryGroupLabels = LibraryMediaGroupLabels(
  values: {
    'series': 'Series',
    'series_plural': 'Series',
    'unknown_series': 'Unknown series',
    'publisher': 'Publisher / Designer',
    'publisher_plural': 'Publishers / Designers',
    'unknown_publisher': 'Unknown publisher / designer',
  },
);

const boardGamesLibraryBucketLabelOverrides = LibraryBucketLabelOverrides();

String boardGamesLibraryBucketLabelBuilder(LibraryBucketingContext context) {
  return defaultLibraryBucketLabel(
    context,
    boardGamesLibraryGroupLabels,
    boardGamesLibraryBucketLabelOverrides,
  );
}

final boardGamesLibraryMediaPresentation = LibraryMediaPresentation(
  searchFieldLabels: const LibraryMediaSearchFieldLabels(
    queryHint: 'Enter title, creator, or keyword...',
    emptySearchMessage: 'Enter a title, creator, series, or keyword.',
  ),
  filterLabels: const LibraryMediaFilterLabels(
    values: {
      'series': 'Series',
      'series_any': 'Any series',
      'publisher': 'Publisher / Designer',
      'publisher_any': 'Any publisher / designer',
      'year': 'Year',
      'year_any': 'Any year',
    },
  ),
  groupLabels: boardGamesLibraryGroupLabels,
  builder: boardGamesLibraryMediaBuilder,
  projector: const BoardGameWorkspaceProjector(),
  bucketLabelBuilder: boardGamesLibraryBucketLabelBuilder,
  previewLabels: boardGamesPreviewLabels,
  statsLabels: boardGamesStatsLabels,
  filterDefinitions: boardGamesLibraryFilterDefinitions,
  fieldDefinitions: boardgameLibraryFieldDefinitions,
);
