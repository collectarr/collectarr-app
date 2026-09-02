import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/comic/presentation_builder.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace_view.dart';
import 'package:collectarr_app/features/library/config/workspace_presentation_support.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';

const comicsMetadataLabels = LibraryMetadataLabels(
  values: {
    'characters': 'Characters',
    'story_arcs_inline': 'Story arcs',
    'genres': 'Genres',
  },
);

const comicLibraryMediaBuilder = ComicLibraryMediaPresentationBuilder(
  showSummary: true,
  metadataLabels: comicsMetadataLabels,
);

const comicsPreviewLabels = LibraryMediaPreviewLabels(
  values: {
    'series': 'Series',
    'item_count': 'Issues',
    'item_number': 'No. / Vol.',
    'publisher': 'Publisher / Studio / Creator',
    'variant': 'Edition / Variant / Format',
    'barcode': 'Barcode / UPC / ISBN',
    'media_scope': 'Series',
    'export_title': 'Series',
  },
);

const comicsIssueVisibleColumns = {
  'status',
  'cover',
  'title',
  'issue',
  'publisher',
  'release_date',
  'barcode',
  'condition',
  'price',
  'location',
  'wishlist',
  'updated',
};

const comicLibraryGroupLabels = LibraryMediaGroupLabels(
  values: {
    'series': 'Series',
    'series_plural': 'Series',
    'unknown_series': 'Unknown series',
    'publisher': 'Publisher',
    'publisher_plural': 'Publishers',
    'unknown_publisher': 'Unknown publisher',
    'media_scope': 'Series',
    'export_title': 'Series',
  },
);

const comicLibraryBucketLabelOverrides = LibraryBucketLabelOverrides();

final comicLibraryFilterDefinitions = <LibraryFilterDefinition<dynamic>>[
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
    label: 'Publisher',
    anyLabel: 'Any publisher',
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
    id: 'grade',
    label: 'Grade',
    anyLabel: 'Any grade',
    missingValueLabel: 'Missing grade',
    value: (item) => item.source.grade,
    matches: (item, value) => value == LibraryFilterDefinition.missingValue
        ? item.source.isOwned &&
            (item.source.grade == null || item.source.grade!.trim().isEmpty)
        : item.source.grade?.trim() == value,
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

String comicLibraryBucketLabelBuilder(LibraryBucketingContext context) {
  return defaultLibraryBucketLabel(
    context,
    comicLibraryGroupLabels,
    comicLibraryBucketLabelOverrides,
  );
}

const comicLibrarySortFavorites = [
  LibrarySortFavorite(
    id: 'series_issue',
    label: 'Series + issue',
    icon: Icons.format_list_numbered,
    rules: [
      LibrarySortRule(column: 'title', ascending: true),
      LibrarySortRule(column: 'comic.issue', ascending: true),
      LibrarySortRule(column: 'variant', ascending: true),
    ],
  ),
  LibrarySortFavorite(
    id: 'recent',
    label: 'Recently added',
    icon: Icons.update,
    rules: [
      LibrarySortRule(column: 'updated', ascending: false),
      LibrarySortRule(column: 'title', ascending: true),
    ],
  ),
  LibrarySortFavorite(
    id: 'publisher_date',
    label: 'Publisher + date',
    icon: Icons.business_outlined,
    rules: [
      LibrarySortRule(column: 'publisher', ascending: true),
      LibrarySortRule(column: 'release_date', ascending: true),
      LibrarySortRule(column: 'comic.issue', ascending: true),
    ],
  ),
  LibrarySortFavorite(
    id: 'value_desc',
    label: 'Value high to low',
    icon: Icons.attach_money,
    rules: [
      LibrarySortRule(column: 'price', ascending: false),
      LibrarySortRule(column: 'title', ascending: true),
    ],
  ),
];

final comicLibraryMediaPresentation = LibraryMediaPresentation(
  searchFieldLabels: const LibraryMediaSearchFieldLabels(
    queryHint: 'Enter title, creator, or keyword...',
    emptySearchMessage: 'Enter a title, creator, series, or keyword.',
  ),
  filterLabels: const LibraryMediaFilterLabels(
    values: {
      'series': 'Series',
      'series_any': 'Any series',
      'publisher': 'Publisher',
      'publisher_any': 'Any publisher',
      'year': 'Year',
      'year_any': 'Any year',
    },
  ),
  groupLabels: comicLibraryGroupLabels,
  builder: comicLibraryMediaBuilder,
  bucketLabelBuilder: comicLibraryBucketLabelBuilder,
  usesCompactTableLayout: true,
  previewLabels: comicsPreviewLabels,
  filterDefinitions: comicLibraryFilterDefinitions,
  sortFavorites: comicLibrarySortFavorites,
  columnFavorites: comicsTableColumnPresets,
);
