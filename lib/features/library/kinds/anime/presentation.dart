import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/workspace_presentation_support.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:collectarr_app/features/library/config/presentation/library_video_media_presentation_builder.dart';
import 'package:collectarr_app/features/library/add/library_add_video_preview_sections.dart';
import 'package:flutter/material.dart';

const animeMetadataLabels = LibraryMetadataLabels(
  identitySectionTitle: 'Anime identity',
  contextSectionTitle: 'Anime context',
  creditsSectionTitle: 'Cast & Discovery',
  values: {'creators': 'Cast & Crew', 'characters': 'Characters'},
);

class AnimeLibraryMediaPresentationBuilder
    extends LibraryVideoMediaPresentationBuilder {
  const AnimeLibraryMediaPresentationBuilder()
      : super(
          showSummary: true,
          metadataLabels: animeMetadataLabels,
          itemNumberLabel: 'Edition no.',
          publisherLabel: 'Studio',
          variantLabel: 'Format / Edition',
          barcodeLabel: 'UPC / Barcode',
          shelfDrilldownEntryTypes: const {'anime'},
        );

  @override
  List<Widget> buildAddPreviewSections({
    required Color accent,
    required CatalogMediaKind kind,
    required String provider,
    required String providerItemId,
  }) {
    return [
      VideoAddPreviewSeasonsSection(
        kind: kind,
        provider: provider,
        providerItemId: providerItemId,
        accent: accent,
      ),
    ];
  }
}

const animeLibraryMediaBuilder = AnimeLibraryMediaPresentationBuilder();

const animePreviewLabels = LibraryMediaPreviewLabels(
  values: {
    'series': 'Series',
    'item_count': 'Episodes',
    'item_number': 'Edition no.',
    'publisher': 'Studio',
    'variant': 'Format / Edition',
    'barcode': 'UPC / Barcode',
  },
);

const animeStatsLabels = LibraryMediaStatsLabels(
  values: {'top_series': 'Top Series', 'top_publisher': 'Top Studios'},
);

final animeLibraryFilterDefinitions = <LibraryFilterDefinition<dynamic>>[
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

const animeLibraryGroupLabels = LibraryMediaGroupLabels(
  values: {
    'series': 'Series',
    'series_plural': 'Series',
    'unknown_series': 'Unknown series',
    'publisher': 'Studio',
    'publisher_plural': 'Studios',
    'unknown_publisher': 'Unknown studio',
    'publisher_mode': 'Studios',
    'genre': 'Genres',
    'genre_plural': 'Genres',
  },
);

const animeLibraryBucketLabelOverrides = LibraryBucketLabelOverrides();

String animeLibraryBucketLabelBuilder(LibraryBucketingContext context) {
  return defaultLibraryBucketLabel(
    context,
    animeLibraryGroupLabels,
    animeLibraryBucketLabelOverrides,
  );
}

final animeLibraryMediaPresentation = LibraryMediaPresentation(
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
  groupLabels: animeLibraryGroupLabels,
  builder: animeLibraryMediaBuilder,
  bucketLabelBuilder: animeLibraryBucketLabelBuilder,
  usesCompactTableLayout: true,
  compactBucketIcon: Icons.tv_outlined,
  previewLabels: animePreviewLabels,
  statsLabels: animeStatsLabels,
  filterDefinitions: animeLibraryFilterDefinitions,
);
