import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_projector.dart';
import 'package:collectarr_app/features/library/config/workspace_presentation_support.dart';
import 'package:collectarr_app/features/library/kinds/tv/presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_fields.dart';
import 'package:flutter/material.dart';

const tvPreviewLabels = LibraryMediaPreviewLabels(
  series: 'Series',
  itemCount: 'Episodes',
);

const tvStatsLabels = LibraryMediaStatsLabels(
  topSeries: 'Top Series',
  topPublisher: 'Top Networks',
);

const tvLibraryGroupLabels = LibraryMediaGroupLabels(
  series: 'Series',
  seriesPlural: 'Series',
  unknownSeries: 'Unknown series',
  publisher: 'Network',
  publisherPlural: 'Networks',
  unknownPublisher: 'Unknown network',
  publisherMode: 'Networks',
  genre: 'Genres',
);

const tvLibraryBucketLabelOverrides = LibraryBucketLabelOverrides();

String tvLibraryBucketLabelBuilder(LibraryBucketingContext context) {
  return defaultLibraryBucketLabel(
    context,
    tvLibraryGroupLabels,
    tvLibraryBucketLabelOverrides,
  );
}

final tvLibraryMediaPresentation = LibraryMediaPresentation(
  searchFieldLabels: const LibraryMediaSearchFieldLabels(
    queryHint: 'Enter series, episode, or keyword...',
    emptySearchMessage: 'Enter a series, episode, or keyword.',
    seriesHint: 'Series...',
    numberHint: 'Episode no....',
    publisherHint: 'Network...',
  ),
  filterLabels: const LibraryMediaFilterLabels(
    series: 'Series',
    anySeries: 'Any series',
    publisher: 'Network',
    anyPublisher: 'Any network',
  ),
  groupLabels: tvLibraryGroupLabels,
  builder: const TvLibraryMediaPresentationBuilder(),
  projector: const TvWorkspaceProjector(),
  bucketLabelBuilder: tvLibraryBucketLabelBuilder,
  previewLabels: tvPreviewLabels,
  statsLabels: tvStatsLabels,
  showsSeasonGroupProgress: true,
  defaultVideoDisplayLevel: tvDefaultVideoDisplayLevel,
  defaultVideoGrouping: tvDefaultVideoGrouping,
  videoSeriesEntryTypes: const {'tv'},
  videoShelfDrilldownEntryTypes: const {'tv'},
  compactBucketIcon: Icons.tv_outlined,
  emptyStateProviderSummarySuffix: ' Episodes are tracked as seasons.',
  fieldDefinitions: tvLibraryFieldDefinitions,
);
