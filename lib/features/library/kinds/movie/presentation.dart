import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/movie/presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_fields.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:collectarr_app/features/library/config/workspace_presentation_support.dart';
import 'package:flutter/material.dart';

const moviesMetadataLabels = LibraryMetadataLabels(
  identitySectionTitle: 'Screen identity',
  contextSectionTitle: 'Release context',
  creditsSectionTitle: 'Cast & Discovery',
  values: {'creators': 'Cast & Crew', 'genres': 'Genres'},
);

const moviesLibraryMediaBuilder = VideoLibraryMediaPresentationBuilder(
  showSummary: true,
  metadataLabels: moviesMetadataLabels,
);

const moviesPreviewLabels = LibraryMediaPreviewLabels(
  values: {'series': 'Series', 'item_count': 'Items'},
);

const moviesStatsLabels = LibraryMediaStatsLabels(
  values: {'top_series': 'Top Franchises', 'top_publisher': 'Top Studios'},
);

const moviesLibraryGroupLabels = LibraryMediaGroupLabels(
  values: {
    'series': 'Series',
    'series_plural': 'Series',
    'unknown_series': 'Unknown series',
    'publisher': 'Studio',
    'publisher_plural': 'Studios',
    'unknown_publisher': 'Unknown studio',
    'publisher_mode': 'Studios',
    'genre': 'Genres',
  },
);

const moviesLibraryBucketLabelOverrides = LibraryBucketLabelOverrides();

final moviesLibraryFilterDefinitions = <LibraryFilterDefinition<dynamic>>[
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
    label: 'Studio',
    anyLabel: 'Any studio',
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

String moviesLibraryBucketLabelBuilder(LibraryBucketingContext context) {
  return defaultLibraryBucketLabel(
    context,
    moviesLibraryGroupLabels,
    moviesLibraryBucketLabelOverrides,
  );
}

final moviesLibraryMediaPresentation = LibraryMediaPresentation(
  searchFieldLabels: const LibraryMediaSearchFieldLabels(
    queryHint: 'Enter title, creator, or keyword...',
    emptySearchMessage: 'Enter a title, creator, series, or keyword.',
  ),
  filterLabels: const LibraryMediaFilterLabels(
    values: {
      'series': 'Series',
      'series_any': 'Any series',
      'publisher': 'Studio',
      'publisher_any': 'Any studio',
      'year': 'Year',
      'year_any': 'Any year',
    },
  ),
  groupLabels: moviesLibraryGroupLabels,
  builder: moviesLibraryMediaBuilder,
  projector: const MovieWorkspaceProjector(),
  bucketLabelBuilder: moviesLibraryBucketLabelBuilder,
  previewLabels: moviesPreviewLabels,
  statsLabels: moviesStatsLabels,
  filterDefinitions: moviesLibraryFilterDefinitions,
  defaultVideoDisplayLevel: VideoDisplayLevel.titleWork,
  defaultVideoGrouping: VideoGroupingDefault.none,
  videoSeriesEntryTypes: const {'tv'},
  videoShelfDrilldownEntryTypes: const {'movie', 'tv', 'anime'},
  compactBucketIcon: Icons.movie_filter_outlined,
  emptyStateProviderSummarySuffix: ' Physical formats are tracked as editions.',
  fieldDefinitions: movieLibraryFieldDefinitions,
);
