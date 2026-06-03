import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/game/presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace_entry_builder.dart';
import 'package:collectarr_app/features/library/kinds/shared/planned_media_presentation_support.dart';
import 'package:collectarr_app/features/library/kinds/shared/workspace_presentation_support.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';

const gamesLibraryMediaBuilder = GameLibraryMediaPresentationBuilder();

const gamesPreviewLabels = LibraryMediaPreviewLabels(
  series: 'Series',
  itemCount: 'Items',
);

const gamesStatsLabels = LibraryMediaStatsLabels(
  topSeries: 'Top Series',
  topPublisher: 'Top Publishers / Studios',
);

const gamesLibraryGroupModes = [
  LibraryGroupMode.publisher,
  LibraryGroupMode.series,
  LibraryGroupMode.year,
  LibraryGroupMode.location,
  LibraryGroupMode.title,
  LibraryGroupMode.ownership,
];

const gamesLibraryGroupModeDefinitions = [
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.publisher,
    label: 'Publisher / Studio',
    sidebarTitle: 'Publishers / Studios',
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

const gamesLibraryGroupLabels = LibraryMediaGroupLabels(
  series: 'Series',
  seriesPlural: 'Series',
  unknownSeries: 'Unknown series',
  publisher: 'Publisher / Studio',
  publisherPlural: 'Publishers / Studios',
  unknownPublisher: 'Unknown publisher / studio',
);

const gamesLibraryBucketLabelOverrides = LibraryBucketLabelOverrides();

String gamesLibraryBucketLabelBuilder(LibraryBucketingContext context) {
  return defaultLibraryBucketLabel(
    context,
    gamesLibraryGroupLabels,
    gamesLibraryBucketLabelOverrides,
  );
}

const gamesLibrarySortColumnDefinitions = [
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.series,
    label: 'Series',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.publisher,
    label: 'Publisher / Studio',
  ),
  ...plannedMediaCommonTailSortColumnDefinitions,
];

const gamesLibraryMediaPresentation = LibraryMediaPresentation(
  searchFieldLabels: LibraryMediaSearchFieldLabels(
    queryHint: 'Enter title, creator, or keyword...',
    emptySearchMessage: 'Enter a title, creator, series, or keyword.',
    seriesHint: 'Series...',
    numberHint: 'Version...',
    publisherHint: 'Publisher / Studio...',
  ),
  filterLabels: LibraryMediaFilterLabels(
    series: 'Series',
    anySeries: 'Any series',
    publisher: 'Publisher / Studio',
    anyPublisher: 'Any publisher / studio',
  ),
  groupLabels: gamesLibraryGroupLabels,
  builder: gamesLibraryMediaBuilder,
  workspaceEntryBuilder: buildGamesLibraryWorkspaceEntryFromShelf,
  releaseEntryBuilder: buildGamesLibraryReleaseEntry,
  bucketLabelBuilder: gamesLibraryBucketLabelBuilder,
  previewLabels: gamesPreviewLabels,
  statsLabels: gamesStatsLabels,
  sortColumnDefinitions: gamesLibrarySortColumnDefinitions,
  groupModeDefinitions: gamesLibraryGroupModeDefinitions,
  groupModes: gamesLibraryGroupModes,
);