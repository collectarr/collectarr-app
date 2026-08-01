import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/movie/presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_fields.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_projector.dart';
import 'package:collectarr_app/features/library/shared/workspace_presentation_support.dart';
import 'package:flutter/material.dart';

const moviesMetadataLabels = LibraryMetadataLabels(
  identitySectionTitle: 'Screen identity',
  contextSectionTitle: 'Release context',
  creditsSectionTitle: 'Cast & Discovery',
  creators: 'Cast & Crew',
);

const moviesLibraryMediaBuilder = VideoLibraryMediaPresentationBuilder(
  showSummary: true,
  metadataLabels: moviesMetadataLabels,
);

const moviesPreviewLabels = LibraryMediaPreviewLabels(
  series: 'Series',
  itemCount: 'Items',
);

const moviesStatsLabels = LibraryMediaStatsLabels(
  topSeries: 'Top Franchises',
  topPublisher: 'Top Studios',
);

const moviesLibraryGroupLabels = LibraryMediaGroupLabels(
  series: 'Series',
  seriesPlural: 'Series',
  unknownSeries: 'Unknown series',
  publisher: 'Studio',
  publisherPlural: 'Studios',
  unknownPublisher: 'Unknown studio',
  publisherMode: 'Studios',
  genre: 'Genres',
);

const moviesLibraryBucketLabelOverrides = LibraryBucketLabelOverrides();

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
    seriesHint: 'Series...',
    numberHint: 'Edition no....',
    publisherHint: 'Studio...',
  ),
  filterLabels: const LibraryMediaFilterLabels(
    series: 'Series',
    anySeries: 'Any series',
    publisher: 'Studio',
    anyPublisher: 'Any studio',
  ),
  groupLabels: moviesLibraryGroupLabels,
  builder: moviesLibraryMediaBuilder,
  projector: const MovieWorkspaceProjector(),
  bucketLabelBuilder: moviesLibraryBucketLabelBuilder,
  previewLabels: moviesPreviewLabels,
  statsLabels: moviesStatsLabels,
  compactBucketIcon: Icons.movie_filter_outlined,
  emptyStateProviderSummarySuffix: ' Physical formats are tracked as editions.',
  fieldDefinitions: movieLibraryFieldDefinitions,
);
