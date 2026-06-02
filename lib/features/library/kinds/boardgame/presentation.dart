import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/shared/planned_media_presentation_support.dart';
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
  ...plannedMediaCommonTailGroupModeDefinitions,
];

const boardGamesLibraryGroupLabels = LibraryMediaGroupLabels(
  series: 'Series',
  seriesPlural: 'Series',
  unknownSeries: 'Unknown series',
  publisher: 'Publisher / Designer',
  publisherPlural: 'Publishers / Designers',
  unknownPublisher: 'Unknown publisher / designer',
);

const boardGamesLibraryBucketLabelOverrides = LibraryBucketLabelOverrides();

String boardGamesLibraryBucketLabelBuilder(LibraryBucketingContext context) {
  return defaultLibraryBucketLabel(
    context,
    boardGamesLibraryGroupLabels,
    boardGamesLibraryBucketLabelOverrides,
  );
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
  ...plannedMediaCommonTailSortColumnDefinitions,
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