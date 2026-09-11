import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_owned_item_projection.dart';
import 'package:collectarr_app/features/library/config/workspace_presentation_support.dart';
import 'package:collectarr_app/features/library/kinds/tv/presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_card_presentation.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:flutter/material.dart';

const tvPreviewLabels = LibraryMediaPreviewLabels(
  values: {
    'item_count': 'Episodes',
    'publisher': 'Studio',
    'variant': 'Format / Edition',
    'barcode': 'UPC / Barcode',
  },
);

const tvStatsLabels = LibraryMediaStatsLabels(
  values: {'top_series': 'Top Series', 'top_publisher': 'Top Networks'},
);

const tvLibraryGroupLabels = LibraryPresentationLabels(
  values: {
    'series': 'Series',
    'series_plural': 'Series',
    'unknown_series': 'Unknown series',
    'publisher': 'Network',
    'publisher_plural': 'Networks',
    'unknown_publisher': 'Unknown network',
    'publisher_mode': 'Networks',
    'genre': 'Genres',
  },
);

const tvLibraryBucketLabelOverrides = LibraryPresentationLabels();

final tvLibraryFilterDefinitions = <LibraryFilterDefinition<dynamic>>[
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
    value: (item) => TvOwnedItemProjection.fromDispatch(
      item.source.ownedItemDispatch,
    )?.tags?.split(','),
  ),
  LibraryFilterDefinition<dynamic>(
    id: 'publisher',
    label: 'Network',
    anyLabel: 'Any network',
    value: (item) => (item.dto is TvWorkspaceDto)
        ? (item.dto as TvWorkspaceDto).network
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
    value: (item) => TvOwnedItemProjection.fromDispatch(
      item.source.ownedItemDispatch,
    )?.condition,
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
  ),
  filterLabels: const LibraryPresentationLabels(
    values: {
      'series': 'Series',
      'series_any': 'Any series',
      'publisher': 'Network',
      'publisher_any': 'Any network',
      'year': 'Year',
      'year_any': 'Any year',
    },
  ),
  groupLabels: tvLibraryGroupLabels,
  builder: const TvLibraryMediaPresentationBuilder(),
  bucketLabelBuilder: tvLibraryBucketLabelBuilder,
  cardPresentationBuilder: buildTvCardPresentation,
  compactBucketIcon: Icons.tv_outlined,
  emptyStateProviderSummarySuffix: ' Episodes are tracked as seasons.',
  previewLabels: tvPreviewLabels,
  statsLabels: tvStatsLabels,
  filterDefinitions: tvLibraryFilterDefinitions,
);
