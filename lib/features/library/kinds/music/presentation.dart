import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/music/presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace_entry_builder.dart';
import 'package:collectarr_app/features/library/kinds/shared/workspace_presentation_support.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';

const musicMetadataLabels = LibraryMetadataLabels(
  identitySectionTitle: 'Album identity',
  contextSectionTitle: 'Album context',
  creditsSectionTitle: 'Contributors & Discovery',
  creators: 'Contributors',
  characters: 'Featured artists',
);

const musicLibraryMediaBuilder = MusicLibraryMediaPresentationBuilder(
  metadataLabels: musicMetadataLabels,
);

const musicPreviewLabels = LibraryMediaPreviewLabels(
  series: 'Artist',
  itemCount: 'Releases',
);

const musicStatsLabels = LibraryMediaStatsLabels(
  topSeries: 'Top Artists',
  topPublisher: 'Top Labels',
);

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

const musicLibraryGroupLabels = LibraryMediaGroupLabels(
  series: 'Artist',
  seriesPlural: 'Artists',
  unknownSeries: 'Unknown artist',
  publisher: 'Label',
  publisherPlural: 'Labels',
  unknownPublisher: 'Unknown label',
);

const musicLibraryBucketLabelOverrides = LibraryBucketLabelOverrides();

String musicLibraryBucketLabelBuilder(LibraryBucketingContext context) {
  return defaultLibraryBucketLabel(
    context,
    musicLibraryGroupLabels,
    musicLibraryBucketLabelOverrides,
  );
}

const musicLibrarySortColumnDefinitions = [
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.series,
    label: 'Artist',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.publisher,
    label: 'Label',
  ),
  LibrarySortColumnDefinition(column: LibrarySortColumn.status, label: 'Status'),
  LibrarySortColumnDefinition(column: LibrarySortColumn.title, label: 'Title'),
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
  LibrarySortColumnDefinition(column: LibrarySortColumn.country, label: 'Country'),
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
  LibrarySortColumnDefinition(column: LibrarySortColumn.imprint, label: 'Imprint'),
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
  groupLabels: musicLibraryGroupLabels,
  builder: musicLibraryMediaBuilder,
  workspaceEntryBuilder: buildMusicLibraryWorkspaceEntryFromShelf,
  releaseEntryBuilder: buildMusicLibraryReleaseEntry,
  bucketLabelBuilder: musicLibraryBucketLabelBuilder,
  previewLabels: musicPreviewLabels,
  statsLabels: musicStatsLabels,
  referenceLabels: LibraryReferenceLabels(itemScope: 'Album'),
  compactBucketIcon: Icons.person_2_outlined,
  sortColumnDefinitions: musicLibrarySortColumnDefinitions,
  groupModeDefinitions: musicLibraryGroupModeDefinitions,
  groupModes: musicLibraryGroupModes,
);