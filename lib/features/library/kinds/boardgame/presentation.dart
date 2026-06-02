import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/shared/presentation_support.dart';
import 'package:collectarr_app/features/library/kinds/shared/workspace_presentation_support.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';

const boardGamesLibraryGroupModes = [
  LibraryGroupMode.publisher,
  LibraryGroupMode.series,
  LibraryGroupMode.year,
  LibraryGroupMode.location,
  LibraryGroupMode.title,
  LibraryGroupMode.ownership,
];

const boardGamesLibraryGroupModeDefinitions = [
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.publisher,
    label: 'Publisher / Designer',
    sidebarTitle: 'Publishers / Designers',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.series,
    label: 'Series',
    sidebarTitle: 'Series',
    icon: Icons.collections_bookmark_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.year,
    label: 'Year',
    sidebarTitle: 'Years',
    icon: Icons.calendar_today_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.location,
    label: 'Location',
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.title,
    label: 'Title',
    sidebarTitle: 'Titles',
    icon: Icons.sort_by_alpha,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.ownership,
    label: 'Ownership',
    sidebarTitle: 'Ownership',
    icon: Icons.inventory_2_outlined,
  ),
];

const boardGamesLibraryGroupLabels = LibraryMediaGroupLabels(
  series: 'Series',
  seriesPlural: 'Series',
  unknownSeries: 'Unknown series',
  publisher: 'Publisher / Designer',
  publisherPlural: 'Publishers / Designers',
  unknownPublisher: 'Unknown publisher / designer',
);

String boardGamesLibraryBucketLabelBuilder(LibraryBucketingContext context) {
  return defaultLibraryBucketLabel(context, boardGamesLibraryGroupLabels);
}

const boardGamesLibrarySortColumnDefinitions = [
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.series,
    label: 'Series',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.publisher,
    label: 'Publisher / Designer',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.status,
    label: 'Status',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.title,
    label: 'Title',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.issue,
    label: 'Issue / number',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.storyArc,
    label: 'Story arc',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.variant,
    label: 'Variant',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.format,
    label: 'Format',
    group: LibrarySortFieldGroup.edition,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.releaseDate,
    label: 'Release date',
    defaultAscending: false,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.barcode,
    label: 'Barcode',
    group: LibrarySortFieldGroup.edition,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.grade,
    label: 'Grade',
    group: LibrarySortFieldGroup.value,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.condition,
    label: 'Condition',
    group: LibrarySortFieldGroup.value,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.price,
    label: 'Purchase price',
    group: LibrarySortFieldGroup.value,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.location,
    label: 'Storage box',
    group: LibrarySortFieldGroup.personal,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.collectionStatus,
    label: 'Collection status',
    group: LibrarySortFieldGroup.personal,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.wishlist,
    label: 'Wishlist',
    group: LibrarySortFieldGroup.personal,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.added,
    label: 'Added date',
    group: LibrarySortFieldGroup.personal,
    defaultAscending: false,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.updated,
    label: 'Updated',
    group: LibrarySortFieldGroup.personal,
    defaultAscending: false,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.country,
    label: 'Country',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.language,
    label: 'Language',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.pageCount,
    label: 'Page count',
    group: LibrarySortFieldGroup.edition,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.ageRating,
    label: 'Age rating',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.imprint,
    label: 'Imprint',
  ),
];

const boardGamesLibraryMediaPresentation = LibraryMediaPresentation(
  searchFieldLabels: LibraryMediaSearchFieldLabels(
    queryHint: 'Enter title, creator, or keyword...',
    emptySearchMessage: 'Enter a title, creator, series, or keyword.',
    seriesHint: 'Series...',
    numberHint: 'Edition...',
    publisherHint: 'Publisher / Designer...',
  ),
  filterLabels: LibraryMediaFilterLabels(
    series: 'Series',
    anySeries: 'Any series',
    publisher: 'Publisher / Designer',
    anyPublisher: 'Any publisher / designer',
  ),
  groupLabels: boardGamesLibraryGroupLabels,
  builder: boardGamesLibraryMediaBuilder,
  workspaceEntryBuilder: buildBoardGamesLibraryWorkspaceEntryFromShelf,
  releaseEntryBuilder: buildBoardGamesLibraryReleaseEntry,
  bucketLabelBuilder: boardGamesLibraryBucketLabelBuilder,
  previewLabels: defaultPreviewLabels,
  statsLabels: gameStatsLabels,
  sortColumnDefinitions: boardGamesLibrarySortColumnDefinitions,
  groupModeDefinitions: boardGamesLibraryGroupModeDefinitions,
  groupModes: boardGamesLibraryGroupModes,
);