import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/shared/presentation_support.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';

const musicLibraryGroupModes = [
  LibraryGroupMode.series,
  LibraryGroupMode.publisher,
  LibraryGroupMode.year,
  LibraryGroupMode.location,
  LibraryGroupMode.title,
  LibraryGroupMode.ownership,
];

const musicLibraryGroupModeDefinitions = [
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.series,
    label: 'Artist',
    sidebarTitle: 'Artists',
    icon: Icons.collections_bookmark_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.publisher,
    label: 'Label',
    sidebarTitle: 'Labels',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
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

const musicLibrarySortColumnDefinitions = [
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.series,
    label: 'Artist',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.publisher,
    label: 'Label',
  ),
  ...kSharedSortColumnDefinitionsWithoutSeriesPublisher,
];

const musicLibraryMediaPresentation = LibraryMediaPresentation(
  searchFieldLabels: LibraryMediaSearchFieldLabels(
    queryHint: 'Enter album, artist, release, or label...',
    emptySearchMessage: 'Enter an album, artist, release, or label.',
    seriesHint: 'Artist...',
    numberHint: 'Album / Release...',
    publisherHint: 'Label...',
  ),
  filterLabels: LibraryMediaFilterLabels(
    series: 'Artist',
    anySeries: 'Any artist',
    publisher: 'Label',
    anyPublisher: 'Any label',
  ),
  groupLabels: LibraryMediaGroupLabels(
    series: 'Artist',
    seriesPlural: 'Artists',
    unknownSeries: 'Unknown artist',
    publisher: 'Label',
    publisherPlural: 'Labels',
    unknownPublisher: 'Unknown label',
  ),
  builder: musicLibraryMediaBuilder,
  previewLabels: releasesPreviewLabels,
  statsLabels: musicStatsLabels,
  referenceLabels: LibraryReferenceLabels(itemScope: 'Album'),
  compactBucketIcon: Icons.person_2_outlined,
  sortColumnDefinitions: musicLibrarySortColumnDefinitions,
  groupModeDefinitions: musicLibraryGroupModeDefinitions,
  groupModes: musicLibraryGroupModes,
);