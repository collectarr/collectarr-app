import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_entry_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/tv/config/tv_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_library_entry_projection.dart';
import 'package:collectarr_app/features/library/config/workspace_presentation_support.dart';
import 'package:collectarr_app/features/library/kinds/tv/presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_card_presentation.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_dto.dart';
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

final tvLibraryFilterDefinitions = <LibraryFilterDefinition<Object?>>[
  LibraryFilterDefinition<Object?>(
    metadata: TvWorkspaceFieldMetadata.series,
    id: 'series',
    label: 'Series',
    anyLabel: 'Any series',
    value: (item) => (item.dto is TvWorkspaceDto)
        ? (item.dto as TvWorkspaceDto).seriesTitle
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
    value: (item) => TvLibraryEntryProjection.fromDispatch(
      item.source.libraryEntryDispatch,
    )?.personal.tags?.split(','),
  ),
  LibraryFilterDefinition<Object?>(
    metadata: TvWorkspaceFieldMetadata.publisher,
    id: 'publisher',
    label: 'Network',
    anyLabel: 'Any network',
    value: (item) => (item.dto is TvWorkspaceDto)
        ? (item.dto as TvWorkspaceDto).network
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    metadata: TvWorkspaceFieldMetadata.releaseYear,
    id: 'year',
    label: 'Year',
    anyLabel: 'Any year',
    value: (item) => (item.dto is TvWorkspaceDto)
        ? (item.dto as TvWorkspaceDto).releaseDate?.year.toString()
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    metadata: LibraryEntryFieldMetadata.condition,
    id: 'condition',
    label: 'Condition',
    anyLabel: 'Any condition',
    value: (item) => TvLibraryEntryProjection.fromDispatch(
      item.source.libraryEntryDispatch,
    )?.personal.condition,
  ),
  LibraryFilterDefinition<Object?>(
    metadata: TvWorkspaceFieldMetadata.country,
    id: 'country',
    label: 'Country',
    anyLabel: 'Any country',
    value: (item) => (item.dto is TvWorkspaceDto)
        ? (item.dto as TvWorkspaceDto).country
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    metadata: TvWorkspaceFieldMetadata.language,
    id: 'language',
    label: 'Language',
    anyLabel: 'Any language',
    value: (item) => (item.dto is TvWorkspaceDto)
        ? (item.dto as TvWorkspaceDto).language
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
  emptyStateSummarySuffix: ' Episodes are tracked as seasons.',
  previewLabels: tvPreviewLabels,
  statsLabels: tvStatsLabels,
  filterDefinitions: tvLibraryFilterDefinitions,
);
