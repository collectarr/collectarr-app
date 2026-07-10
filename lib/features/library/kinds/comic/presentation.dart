import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/comic/presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_fields.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace_entry_builder.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace_view.dart';
import 'package:collectarr_app/features/library/shared/workspace_presentation_support.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';

const comicLibraryMediaBuilder = ComicLibraryMediaPresentationBuilder(
  showSummary: true,
);

const comicsPreviewLabels = LibraryMediaPreviewLabels(
  series: 'Series',
  itemCount: 'Issues',
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
  series: 'Series',
  seriesPlural: 'Series',
  unknownSeries: 'Unknown series',
  publisher: 'Publisher',
  publisherPlural: 'Publishers',
  unknownPublisher: 'Unknown publisher',
);

const comicLibraryBucketLabelOverrides = LibraryBucketLabelOverrides();

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
  searchFieldLabels: LibraryMediaSearchFieldLabels(
    queryHint: 'Enter title, creator, or keyword...',
    emptySearchMessage: 'Enter a title, creator, series, or keyword.',
    seriesHint: 'Series...',
    numberHint: 'No. / Vol....',
    publisherHint: 'Publisher / Studio / Creator...',
  ),
  filterLabels: LibraryMediaFilterLabels(
    series: 'Series',
    anySeries: 'Any series',
    publisher: 'Publisher',
    anyPublisher: 'Any publisher',
  ),
  groupLabels: comicLibraryGroupLabels,
  builder: comicLibraryMediaBuilder,
  workspaceEntryBuilder: buildComicsLibraryWorkspaceEntryFromShelf,
  releaseEntryBuilder: buildComicsLibraryReleaseEntry,
  bucketLabelBuilder: comicLibraryBucketLabelBuilder,
  previewLabels: comicsPreviewLabels,
  usesTreeProviderCandidates: true,
  externalFacetBucketIdsByMode: {
    'comic.story_arc': LibraryFacetId.comicStoryArc,
    'comic.character': LibraryFacetId.comicCharacter,
  },
  supportsSeriesIssueJump: true,
  usesCompactTableLayout: true,
  sortFavorites: comicLibrarySortFavorites,
  columnFavorites: comicsTableColumnPresets,
  fieldDefinitions: comicLibraryFieldDefinitions,
);
