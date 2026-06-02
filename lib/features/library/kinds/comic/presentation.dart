import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace_view.dart';
import 'package:collectarr_app/features/library/kinds/shared/presentation_support.dart';
import 'package:collectarr_app/features/library/kinds/shared/workspace_presentation_support.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';

const comicsLibraryGroupModes = [
  LibraryGroupMode.series,
  LibraryGroupMode.ageRating,
  LibraryGroupMode.country,
  LibraryGroupMode.genre,
  LibraryGroupMode.language,
  LibraryGroupMode.releaseDate,
  LibraryGroupMode.releaseMonth,
  LibraryGroupMode.releaseYear,
  LibraryGroupMode.storyArc,
  LibraryGroupMode.character,
  LibraryGroupMode.creator,
  LibraryGroupMode.publisher,
  LibraryGroupMode.writer,
  LibraryGroupMode.artist,
  LibraryGroupMode.penciller,
  LibraryGroupMode.colorist,
  LibraryGroupMode.letterer,
  LibraryGroupMode.coverArtist,
  LibraryGroupMode.editor,
  LibraryGroupMode.format,
  LibraryGroupMode.grade,
  LibraryGroupMode.condition,
  LibraryGroupMode.isKeyComic,
  LibraryGroupMode.rawOrSlabbed,
  LibraryGroupMode.myRating,
  LibraryGroupMode.purchaseDate,
  LibraryGroupMode.purchaseMonth,
  LibraryGroupMode.purchaseYear,
  LibraryGroupMode.purchaseStore,
  LibraryGroupMode.owner,
  LibraryGroupMode.location,
  LibraryGroupMode.ownership,
  LibraryGroupMode.addedDate,
  LibraryGroupMode.addedMonth,
  LibraryGroupMode.addedYear,
  LibraryGroupMode.collectionStatus,
  LibraryGroupMode.imageType,
  LibraryGroupMode.modifiedDate,
  LibraryGroupMode.modifiedMonth,
  LibraryGroupMode.tags,
];

const comicsLibraryGroupModeDefinitions = [
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.series,
    label: 'Series',
    sidebarTitle: 'Series',
    icon: Icons.collections_bookmark_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.ageRating,
    label: 'Age',
    sidebarTitle: 'Ages',
    icon: Icons.family_restroom_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.country,
    label: 'Country',
    sidebarTitle: 'Countries',
    icon: Icons.public_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.genre,
    label: 'Genre',
    sidebarTitle: 'Genres',
    icon: Icons.theater_comedy_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.language,
    label: 'Language',
    sidebarTitle: 'Languages',
    icon: Icons.translate_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.releaseDate,
    label: 'Release Date',
    sidebarTitle: 'Release Dates',
    icon: Icons.event_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.releaseMonth,
    label: 'Release Month',
    sidebarTitle: 'Release Months',
    icon: Icons.calendar_view_month_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.releaseYear,
    label: 'Release Year',
    sidebarTitle: 'Release Years',
    icon: Icons.calendar_today_outlined,
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
    mode: LibraryGroupMode.creator,
    label: 'All Creators',
    sidebarTitle: 'All Creators',
    icon: Icons.group_outlined,
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
    mode: LibraryGroupMode.format,
    label: 'Format',
    sidebarTitle: 'Formats',
    icon: Icons.style_outlined,
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
    mode: LibraryGroupMode.isKeyComic,
    label: 'Key',
    sidebarTitle: 'Keys',
    icon: Icons.key_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.rawOrSlabbed,
    label: 'Raw / Slabbed',
    sidebarTitle: 'Raw / Slabbed',
    icon: Icons.layers_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.myRating,
    label: 'My Rating',
    sidebarTitle: 'My Ratings',
    icon: Icons.star_outline,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.purchaseDate,
    label: 'Purchase Date',
    sidebarTitle: 'Purchase Dates',
    icon: Icons.event_available_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.purchaseMonth,
    label: 'Purchase Month',
    sidebarTitle: 'Purchase Months',
    icon: Icons.calendar_view_month_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.purchaseYear,
    label: 'Purchase Year',
    sidebarTitle: 'Purchase Years',
    icon: Icons.calendar_today_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.purchaseStore,
    label: 'Purchase Store',
    sidebarTitle: 'Purchase Stores',
    icon: Icons.storefront_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.owner,
    label: 'Owner',
    sidebarTitle: 'Owners',
    icon: Icons.person_outline,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.location,
    label: 'Storage Box',
    sidebarTitle: 'Storage Boxes',
    icon: Icons.place_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.ownership,
    label: 'Ownership',
    sidebarTitle: 'Ownership',
    icon: Icons.inventory_2_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.addedDate,
    label: 'Added Date',
    sidebarTitle: 'Added Dates',
    icon: Icons.playlist_add_check_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.addedMonth,
    label: 'Added Month',
    sidebarTitle: 'Added Months',
    icon: Icons.calendar_view_month_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.addedYear,
    label: 'Added Year',
    sidebarTitle: 'Added Years',
    icon: Icons.calendar_today_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.collectionStatus,
    label: 'Collection Status',
    sidebarTitle: 'Collection Status',
    icon: Icons.inventory_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.imageType,
    label: 'Image Type',
    sidebarTitle: 'Image Types',
    icon: Icons.photo_library_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.modifiedDate,
    label: 'Modified Date',
    sidebarTitle: 'Modified Dates',
    icon: Icons.edit_calendar_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.modifiedMonth,
    label: 'Modified Month',
    sidebarTitle: 'Modified Months',
    icon: Icons.calendar_view_month_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.tags,
    label: 'Tags',
    sidebarTitle: 'Tags',
    icon: Icons.sell_outlined,
  ),
];

const comicsLibraryGroupLabels = LibraryMediaGroupLabels(
  series: 'Series',
  seriesPlural: 'Series',
  unknownSeries: 'Unknown series',
  publisher: 'Publisher',
  publisherPlural: 'Publishers',
  unknownPublisher: 'Unknown publisher',
);

String comicsLibraryBucketLabelBuilder(LibraryBucketingContext context) {
  return defaultLibraryBucketLabel(context, comicsLibraryGroupLabels);
}

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
  groupLabels: comicsLibraryGroupLabels,
  builder: comicsLibraryMediaBuilder,
  workspaceEntryBuilder: buildComicsLibraryWorkspaceEntryFromShelf,
  releaseEntryBuilder: buildComicsLibraryReleaseEntry,
  bucketLabelBuilder: comicsLibraryBucketLabelBuilder,
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