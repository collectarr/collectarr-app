import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/generic_library_media_presentation_builder.dart';
import 'package:collectarr_app/features/library/config/generic_library_media_workspace_builder.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';

const genericLibraryMediaBuilder = GenericLibraryMediaPresentationBuilder();

const genericPreviewLabels = LibraryMediaPreviewLabels(
  series: 'Series',
  itemCount: 'Items',
);

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
    id: 'series',
    label: 'Series',
    sidebarTitle: 'Series',
    icon: Icons.collections_bookmark_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.title,
    id: 'title',
    label: 'Title',
    sidebarTitle: 'Titles',
    icon: Icons.sort_by_alpha,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.publisher,
    id: 'publisher',
    label: 'Publisher',
    sidebarTitle: 'Publishers',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.year,
    id: 'year',
    label: 'Year',
    sidebarTitle: 'Years',
    icon: Icons.calendar_today_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.location,
    id: 'location',
    label: 'Location',
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
  LibraryGroupModeDefinition(
    mode: LibraryGroupMode.ownership,
    id: 'ownership',
    label: 'Ownership',
    sidebarTitle: 'Ownership',
    icon: Icons.inventory_2_outlined,
  ),
];

const genericLibraryGroupLabels = LibraryMediaGroupLabels(
  series: 'Series',
  seriesPlural: 'Series',
  unknownSeries: 'Unknown series',
  publisher: 'Publisher',
  publisherPlural: 'Publishers',
  unknownPublisher: 'Unknown publisher',
);

const genericLibraryBucketLabelOverrides = LibraryBucketLabelOverrides();

String genericLibraryBucketLabelBuilder(LibraryBucketingContext context) {
  return _simpleLibraryBucketLabel(
    context,
    genericLibraryGroupLabels,
    genericLibraryBucketLabelOverrides,
  );
}

String _simpleLibraryBucketLabel(
  LibraryBucketingContext context,
  LibraryMediaGroupLabels labels,
  LibraryBucketLabelOverrides overrides,
) {
  final entry = context.entry;
  final publisher = entry.publisher?.trim();
  return switch (context.groupMode) {
    LibraryGroupMode.series => _seriesBucket(entry, labels.unknownSeries),
    LibraryGroupMode.year =>
      entry.releaseYear?.toString() ??
          (entry.releaseDate?.year.toString() ?? 'Unknown year'),
    LibraryGroupMode.publisher =>
      publisher == null || publisher.isEmpty ? labels.unknownPublisher : publisher,
    LibraryGroupMode.location => _locationBucket(entry.locationPath),
    LibraryGroupMode.title => _titleBucket(entry.resolvedTitle),
    LibraryGroupMode.ownership => entry.isOwned
        ? overrides.owned
        : entry.isWishlisted
        ? overrides.wishlist
        : overrides.catalogOnly,
    _ => context.groupMode.name,
  };
}

String _seriesBucket(LibraryWorkspaceEntry entry, String unknownLabel) {
  final seriesTitle = entry.series?.seriesTitle?.trim();
  if (seriesTitle != null && seriesTitle.isNotEmpty) {
    return seriesTitle;
  }
  return unknownLabel;
}

String _locationBucket(String? location) {
  final normalized = location?.trim();
  if (normalized == null || normalized.isEmpty) {
    return 'No location';
  }
  return normalized;
}

String _titleBucket(String title) {
  final trimmed = title.trim();
  return trimmed.isEmpty ? 'Unknown' : trimmed.substring(0, 1).toUpperCase();
}

const genericLibrarySortColumnDefinitions = [
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.series,
    id: 'series',
    label: 'Series',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.publisher,
    id: 'publisher',
    label: 'Publisher',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.status,
    id: 'status',
    label: 'Status',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.title,
    id: 'title',
    label: 'Title',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.issue,
    id: 'issue',
    label: 'Issue / number',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.storyArc,
    id: 'story_arc',
    label: 'Story arc',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.variant,
    id: 'variant',
    label: 'Variant',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.format,
    id: 'format',
    label: 'Format',
    group: LibrarySortFieldGroup.edition,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.releaseDate,
    id: 'release_date',
    label: 'Release date',
    defaultAscending: false,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.barcode,
    id: 'barcode',
    label: 'Barcode',
    group: LibrarySortFieldGroup.edition,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.grade,
    id: 'grade',
    label: 'Grade',
    group: LibrarySortFieldGroup.value,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.rawOrSlabbed,
    id: 'raw_or_slabbed',
    label: 'Raw / slabbed',
    group: LibrarySortFieldGroup.edition,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.gradingCompany,
    id: 'grading_company',
    label: 'Grading company',
    group: LibrarySortFieldGroup.edition,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.condition,
    id: 'condition',
    label: 'Condition',
    group: LibrarySortFieldGroup.value,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.price,
    id: 'price',
    label: 'Purchase price',
    group: LibrarySortFieldGroup.value,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.location,
    id: 'location',
    label: 'Location',
    group: LibrarySortFieldGroup.personal,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.collectionStatus,
    id: 'collection_status',
    label: 'Collection status',
    group: LibrarySortFieldGroup.personal,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.wishlist,
    id: 'wishlist',
    label: 'Wishlist',
    group: LibrarySortFieldGroup.personal,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.keyComic,
    id: 'key_comic',
    label: 'Key comic',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.added,
    id: 'added',
    label: 'Added date',
    group: LibrarySortFieldGroup.personal,
    defaultAscending: false,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.updated,
    id: 'updated',
    label: 'Updated',
    group: LibrarySortFieldGroup.personal,
    defaultAscending: false,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.country,
    id: 'country',
    label: 'Country',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.language,
    id: 'language',
    label: 'Language',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.pageCount,
    id: 'page_count',
    label: 'Page count',
    group: LibrarySortFieldGroup.edition,
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.ageRating,
    id: 'age_rating',
    label: 'Age rating',
  ),
  LibrarySortColumnDefinition(
    column: LibrarySortColumn.imprint,
    id: 'imprint',
    label: 'Imprint',
  ),
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
  groupLabels: genericLibraryGroupLabels,
  builder: genericLibraryMediaBuilder,
  workspaceEntryBuilder: buildGenericLibraryWorkspaceEntryFromShelf,
  releaseEntryBuilder: buildGenericLibraryReleaseEntry,
  bucketLabelBuilder: genericLibraryBucketLabelBuilder,
  previewLabels: genericPreviewLabels,
  sortColumnDefinitions: genericLibrarySortColumnDefinitions,
  groupModeDefinitions: genericLibraryGroupModeDefinitions,
  groupModes: genericLibraryGroupModes,
);
