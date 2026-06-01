import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/shared/presentation_support.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';

const genericLibraryGroupModes = [
  LibraryGroupMode.series,
  LibraryGroupMode.title,
  LibraryGroupMode.publisher,
  LibraryGroupMode.year,
  LibraryGroupMode.location,
  LibraryGroupMode.ownership,
];

const genericLibraryGroupModeDefinitions = [
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.series,
    label: 'Series',
    sidebarTitle: 'Series',
    icon: Icons.collections_bookmark_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.title,
    label: 'Title',
    sidebarTitle: 'Titles',
    icon: Icons.sort_by_alpha,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.publisher,
    label: 'Publisher',
    sidebarTitle: 'Publishers',
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
    mode: LibraryGroupMode.ownership,
    label: 'Ownership',
    sidebarTitle: 'Ownership',
    icon: Icons.inventory_2_outlined,
  ),
];

const genericLibrarySortColumnDefinitions = [
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.series,
    label: 'Series',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.publisher,
    label: 'Publisher',
  ),
  ...kSharedSortColumnDefinitionsWithoutSeriesPublisher,
  ...kSharedComicOnlySortColumnDefinitions,
];

const genericLibraryMediaPresentation = LibraryMediaPresentation(
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
  builder: genericLibraryMediaBuilder,
  previewLabels: defaultPreviewLabels,
  sortColumnDefinitions: genericLibrarySortColumnDefinitions,
  groupModeDefinitions: genericLibraryGroupModeDefinitions,
  groupModes: genericLibraryGroupModes,
);