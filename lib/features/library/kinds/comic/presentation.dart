import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace_view.dart';
import 'package:collectarr_app/features/library/kinds/shared/presentation_support.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';

const comicsLibraryGroupModes = [
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
];

const comicsLibraryGroupModeDefinitions = [
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.series,
    label: 'Series',
    sidebarTitle: 'Series',
    icon: Icons.collections_bookmark_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.storyArc,
    label: 'Story Arc',
    sidebarTitle: 'Story Arcs',
    icon: Icons.auto_stories_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.character,
    label: 'Character',
    sidebarTitle: 'Characters',
    icon: Icons.groups_2_outlined,
    supportsBucketManagement: true,
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
    mode: LibraryGroupMode.writer,
    label: 'Writer',
    sidebarTitle: 'Writers',
    icon: Icons.edit_note_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.artist,
    label: 'Artist',
    sidebarTitle: 'Artists',
    icon: Icons.brush_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.penciller,
    label: 'Penciller',
    sidebarTitle: 'Pencillers',
    icon: Icons.edit_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.colorist,
    label: 'Colorist',
    sidebarTitle: 'Colorists',
    icon: Icons.format_color_fill_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.letterer,
    label: 'Letterer',
    sidebarTitle: 'Letterers',
    icon: Icons.text_fields_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.coverArtist,
    label: 'Cover Artist',
    sidebarTitle: 'Cover Artists',
    icon: Icons.image_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.editor,
    label: 'Editor',
    sidebarTitle: 'Editors',
    icon: Icons.fact_check_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.grade,
    label: 'Grade',
    sidebarTitle: 'Grades',
    icon: Icons.verified_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.condition,
    label: 'Condition',
    sidebarTitle: 'Conditions',
    icon: Icons.rule_outlined,
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

const comicsLibrarySortColumnDefinitions = [
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.series,
    label: 'Series',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.publisher,
    label: 'Publisher',
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
    column: LibrarySortColumn.rawOrSlabbed,
    label: 'Raw / slabbed',
    group: LibrarySortFieldGroup.edition,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.gradingCompany,
    label: 'Grading company',
    group: LibrarySortFieldGroup.edition,
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
    column: LibrarySortColumn.keyComic,
    label: 'Key comic',
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
  sortColumnDefinitions: comicsLibrarySortColumnDefinitions,
  groupModeDefinitions: comicsLibraryGroupModeDefinitions,
  groupModes: comicsLibraryGroupModes,
);