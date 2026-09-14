import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/movie/presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_card_presentation.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_dto.dart';
import 'package:collectarr_app/features/library/config/workspace_presentation_support.dart';
import 'package:flutter/material.dart';

const moviesMetadataLabels = LibraryMetadataLabels(
  identitySectionTitle: 'Screen identity',
  contextSectionTitle: 'Release context',
  creditsSectionTitle: 'Cast & Discovery',
  values: {'creators': 'Cast & Crew', 'genres': 'Genres'},
);

const moviesLibraryMediaBuilder = MovieLibraryMediaPresentationBuilder(
  showSummary: true,
  metadataLabels: moviesMetadataLabels,
);

const moviesPreviewLabels = LibraryMediaPreviewLabels(
  values: {
    'series': 'Series',
    'item_count': 'Items',
    'item_number': 'Edition no.',
    'publisher': 'Studio',
    'variant': 'Format / Edition',
    'barcode': 'UPC / Barcode',
  },
);

const moviesStatsLabels = LibraryMediaStatsLabels(
  values: {'top_series': 'Top Franchises', 'top_publisher': 'Top Studios'},
);

const moviesLibraryGroupLabels = LibraryPresentationLabels(
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

const moviesLibraryBucketLabelOverrides = LibraryPresentationLabels();

final moviesLibraryFilterDefinitions = <LibraryFilterDefinition<Object?>>[
  LibraryFilterDefinition<Object?>(
    id: 'series',
    label: 'Series',
    anyLabel: 'Any series',
    value: (item) => (item.dto is MovieWorkspaceDto)
        ? (item.dto as MovieWorkspaceDto).seriesTitle
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    id: 'location',
    label: 'Location',
    anyLabel: 'Any location',
  ),
  LibraryFilterDefinition<Object?>(
    id: 'tag',
    label: 'Tag',
    anyLabel: 'Any tag',
    inputKind: LibraryFilterInputKind.autocomplete,
    value: (item) => MovieOwnedItemProjection.fromDispatch(
      item.source.ownedItemDispatch,
    )?.tags?.split(','),
  ),
  LibraryFilterDefinition<Object?>(
    id: 'publisher',
    label: 'Studio',
    anyLabel: 'Any studio',
    value: (item) => (item.dto is MovieWorkspaceDto)
        ? (item.dto as MovieWorkspaceDto).publisher
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    id: 'year',
    label: 'Year',
    anyLabel: 'Any year',
    value: (item) => (item.dto is MovieWorkspaceDto)
        ? (item.dto as MovieWorkspaceDto).releaseDate?.year.toString()
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    id: 'condition',
    label: 'Condition',
    anyLabel: 'Any condition',
    value: (item) => MovieOwnedItemProjection.fromDispatch(
      item.source.ownedItemDispatch,
    )?.condition,
  ),
  LibraryFilterDefinition<Object?>(
    id: 'country',
    label: 'Country',
    anyLabel: 'Any country',
    value: (item) => (item.dto is MovieWorkspaceDto)
        ? (item.dto as MovieWorkspaceDto).country
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    id: 'language',
    label: 'Language',
    anyLabel: 'Any language',
    value: (item) => (item.dto is MovieWorkspaceDto)
        ? (item.dto as MovieWorkspaceDto).language
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
  filterLabels: const LibraryPresentationLabels(
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
  bucketLabelBuilder: moviesLibraryBucketLabelBuilder,
  cardPresentationBuilder: buildMovieCardPresentation,
  compactBucketIcon: Icons.movie_filter_outlined,
  emptyStateProviderSummarySuffix: ' Physical formats are tracked as editions.',
  previewLabels: moviesPreviewLabels,
  statsLabels: moviesStatsLabels,
  filterDefinitions: moviesLibraryFilterDefinitions,
);
