import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace_view.dart';
import 'package:collectarr_app/features/library/kinds/shared/presentation_support.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';

const comicLibrarySortFavorites = [
  LibrarySortFavorite(
    id: 'series_issue',
    label: 'Series + issue',
    icon: Icons.format_list_numbered,
    rules: [
      LibrarySortRule(column: LibrarySortColumn.title, ascending: true),
      LibrarySortRule(column: LibrarySortColumn.issue, ascending: true),
      LibrarySortRule(column: LibrarySortColumn.variant, ascending: true),
    ],
  ),
  LibrarySortFavorite(
    id: 'recent',
    label: 'Recently added',
    icon: Icons.update,
    rules: [
      LibrarySortRule(column: LibrarySortColumn.updated, ascending: false),
      LibrarySortRule(column: LibrarySortColumn.title, ascending: true),
    ],
  ),
  LibrarySortFavorite(
    id: 'publisher_date',
    label: 'Publisher + date',
    icon: Icons.business_outlined,
    rules: [
      LibrarySortRule(column: LibrarySortColumn.publisher, ascending: true),
      LibrarySortRule(column: LibrarySortColumn.releaseDate, ascending: true),
      LibrarySortRule(column: LibrarySortColumn.issue, ascending: true),
    ],
  ),
  LibrarySortFavorite(
    id: 'value_desc',
    label: 'Value high to low',
    icon: Icons.attach_money,
    rules: [
      LibrarySortRule(column: LibrarySortColumn.price, ascending: false),
      LibrarySortRule(column: LibrarySortColumn.title, ascending: true),
    ],
  ),
];

const comicsLibraryMediaPresentation = LibraryMediaPresentation(
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
  groupLabels: LibraryMediaGroupLabels(
    series: 'Series',
    seriesPlural: 'Series',
    unknownSeries: 'Unknown series',
    publisher: 'Publisher',
    publisherPlural: 'Publishers',
    unknownPublisher: 'Unknown publisher',
  ),
  builder: comicsLibraryMediaBuilder,
  defaultVisibleColumns: issueVisibleColumns,
  previewLabels: issuesPreviewLabels,
  usesTreeProviderCandidates: true,
  externalFacetBucketModes: [
    LibraryGroupMode.storyArc,
    LibraryGroupMode.character,
  ],
  supportsSeriesIssueJump: true,
  sortFavorites: comicLibrarySortFavorites,
  columnFavorites: comicsTableColumnPresets,
  groupModes: [
    LibraryGroupMode.series,
    LibraryGroupMode.storyArc,
    LibraryGroupMode.character,
    LibraryGroupMode.publisher,
    LibraryGroupMode.year,
    LibraryGroupMode.writer,
    LibraryGroupMode.artist,
    LibraryGroupMode.penciller,
    LibraryGroupMode.colorist,
    LibraryGroupMode.letterer,
    LibraryGroupMode.coverArtist,
    LibraryGroupMode.editor,
    LibraryGroupMode.grade,
    LibraryGroupMode.condition,
    LibraryGroupMode.location,
    LibraryGroupMode.title,
    LibraryGroupMode.ownership,
  ],
);