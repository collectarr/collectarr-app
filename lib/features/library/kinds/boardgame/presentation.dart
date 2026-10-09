import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_entry_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/config/boardgame_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/config/boardgame_field_identities.dart';
import 'package:collectarr_app/features/library/config/workspace_presentation_support.dart';

const boardGamesMetadataLabels = LibraryMetadataLabels(
  values: {'creators': 'Creators', 'genres': 'Genres'},
);

const boardGamesLibraryMediaBuilder = BoardGameLibraryMediaPresentationBuilder(
  metadataLabels: boardGamesMetadataLabels,
);

const boardGamesPreviewLabels = LibraryMediaPreviewLabels(
  values: {
    'series': 'Series',
    'item_count': 'Items',
    'item_number': 'Edition',
    'publisher': 'Publisher / Designer',
    'variant': 'Expansion / Edition',
    'barcode': 'Barcode',
  },
);

const boardGamesStatsLabels = LibraryMediaStatsLabels(
  values: {
    'top_series': 'Top Series',
    'top_publisher': 'Top Publishers / Designers',
  },
);

final boardGamesLibraryFilterDefinitions = <LibraryFilterDefinition<Object?>>[
  if (BoardGameFieldIdentities.series.filterable)
    LibraryFilterDefinition<Object?>(
      metadata: BoardGameFieldIdentities.series,
      id: BoardGameFieldIdentities.seriesId,
      label: BoardGameFieldIdentities.seriesLabel,
      anyLabel: 'Any series',
      value: (item) => (item.dto is BoardGameWorkspaceDto)
          ? (item.dto as BoardGameWorkspaceDto).seriesTitle
          : null,
    ),
  LibraryFilterDefinition<Object?>(
    metadata: LibraryEntryFieldMetadata.location,
    id: 'location',
    label: 'Location',
    anyLabel: 'Any location',
  ),
  LibraryFilterDefinition<Object?>(
    metadata: LibraryEntryFieldMetadata.tag,
    id: 'tag',
    label: 'Tag',
    anyLabel: 'Any tag',
    inputKind: LibraryFilterInputKind.autocomplete,
    value: (item) => BoardGameLibraryEntryProjection.fromDispatch(
      item.source.libraryEntryDispatch,
    )?.personal.tags?.split(','),
  ),
  if (BoardGameFieldIdentities.publisher.filterable)
    LibraryFilterDefinition<Object?>(
      metadata: BoardGameFieldIdentities.publisher,
      id: BoardGameFieldIdentities.publisherId,
      label: BoardGameFieldIdentities.publisherLabel,
      anyLabel: 'Any publisher',
      value: (item) => (item.dto is BoardGameWorkspaceDto)
          ? (item.dto as BoardGameWorkspaceDto).publisher
          : null,
    ),
  LibraryFilterDefinition<Object?>(
    metadata: BoardGameWorkspaceFieldMetadata.releaseYear,
    id: 'year',
    label: 'Year',
    anyLabel: 'Any year',
    value: (item) => (item.dto is BoardGameWorkspaceDto)
        ? (item.dto as BoardGameWorkspaceDto).releaseDate?.year.toString()
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    metadata: LibraryEntryFieldMetadata.condition,
    id: 'condition',
    label: 'Condition',
    anyLabel: 'Any condition',
    value: (item) => BoardGameLibraryEntryProjection.fromDispatch(
      item.source.libraryEntryDispatch,
    )?.personal.condition,
  ),
  LibraryFilterDefinition<Object?>(
    metadata: BoardGameWorkspaceFieldMetadata.country,
    id: 'country',
    label: 'Country',
    anyLabel: 'Any country',
    value: (item) => (item.dto is BoardGameWorkspaceDto)
        ? (item.dto as BoardGameWorkspaceDto).country
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    metadata: BoardGameWorkspaceFieldMetadata.language,
    id: 'language',
    label: 'Language',
    anyLabel: 'Any language',
    value: (item) => (item.dto is BoardGameWorkspaceDto)
        ? (item.dto as BoardGameWorkspaceDto).language
        : null,
  ),
];

const boardGamesLibraryGroupLabels = LibraryPresentationLabels(
  values: {
    'series': 'Series',
    'series_plural': 'Series',
    'unknown_series': 'Unknown series',
    'publisher': 'Publisher / Designer',
    'publisher_plural': 'Publishers / Designers',
    'unknown_publisher': 'Unknown publisher / designer',
  },
);

const boardGamesLibraryBucketLabelOverrides = LibraryPresentationLabels();

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
  filterLabels: const LibraryPresentationLabels(
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
  bucketLabelBuilder: boardGamesLibraryBucketLabelBuilder,
  previewLabels: boardGamesPreviewLabels,
  statsLabels: boardGamesStatsLabels,
  filterDefinitions: boardGamesLibraryFilterDefinitions,
);
