import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/generic_library_media_presentation_builder.dart';
import 'package:collectarr_app/features/library/config/generic_library_media_workspace_builder.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
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

final genericLibraryGroupModeDefinitions = [
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
  LibraryGroupMode? stdMode;
  for (final m in LibraryGroupMode.values) {
    if (m.name == context.groupMode ||
        m.toString() == context.groupMode ||
        m.toString().split('.').last == context.groupMode) {
      stdMode = m;
      break;
    }
  }
  if (stdMode != null) {
    return switch (stdMode) {
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
      _ => context.groupMode,
    };
  }
  return context.groupMode;
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

final genericLibrarySortColumnDefinitions = [
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

String _formatDate(DateTime? value) {
  if (value == null) return '';
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

String _formatCents(int? cents, String? currency) {
  if (cents == null) return '';
  final amount = (cents / 100).toStringAsFixed(2);
  return currency == null ? amount : '$currency $amount';
}

final genericLibraryColumnDefinitions = [
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('status'),
    label: 'Status',
    getValue: (entry) =>
        entry.isWishlisted ? 'wishlist' : (entry.isOwned ? 'owned' : null),
    cellValue: (entry) => Text(
      entry.isWishlisted ? 'Wishlist' : (entry.isOwned ? 'Owned' : ''),
    ),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('cover'),
    label: '',
    getValue: (entry) => entry.coverImageUrl,
    cellValue: (entry) => entry.coverImageUrl == null
        ? const SizedBox.shrink()
        : Image.network(
            entry.coverImageUrl!,
            width: 32,
            height: 32,
            fit: BoxFit.cover,
          ),
    sortable: false,
    groupable: false,
    defaultWidth: 42,
    minWidth: 44,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('title'),
    label: 'Title',
    getValue: (entry) => entry.resolvedTitle,
    cellValue: (entry) => Text(entry.resolvedTitle),
    defaultWidth: 260,
    maxWidth: 520,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('publisher'),
    label: 'Publisher',
    getValue: (entry) => entry.publisher,
    cellValue: (entry) => Text(entry.publisher ?? ''),
    defaultWidth: 140,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('release_date'),
    label: 'Release Date',
    getValue: (entry) => entry.releaseDate,
    cellValue: (entry) => Text(_formatDate(entry.releaseDate)),
    defaultWidth: 118,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('country'),
    label: 'Country',
    getValue: (entry) => entry.country,
    cellValue: (entry) => Text(entry.country ?? ''),
    group: 'Edition',
    defaultWidth: 100,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('language'),
    label: 'Language',
    getValue: (entry) => entry.language,
    cellValue: (entry) => Text(entry.language ?? ''),
    group: 'Edition',
    defaultWidth: 100,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('age_rating'),
    label: 'Age Rating',
    getValue: (entry) => entry.ageRating,
    cellValue: (entry) => Text(entry.ageRating ?? ''),
    group: 'Edition',
    defaultWidth: 100,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('wishlist'),
    label: 'Wishlist',
    getValue: (entry) => entry.isWishlisted,
    cellValue: (entry) => Text(entry.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('updated'),
    label: 'Updated',
    getValue: (entry) => entry.updatedAt,
    cellValue: (entry) => Text(_formatDate(entry.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('added'),
    label: 'Added',
    getValue: (entry) => entry.addedAt,
    cellValue: (entry) => Text(_formatDate(entry.addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('location'),
    label: 'Location',
    getValue: (entry) => entry.locationPath,
    cellValue: (entry) => Text(entry.locationPath ?? ''),
    group: 'Personal',
    defaultWidth: 118,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('condition'),
    label: 'Condition',
    getValue: (entry) => entry.condition,
    cellValue: (entry) => Text(entry.condition ?? ''),
    group: 'Value',
    defaultWidth: 124,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('price'),
    label: 'Purchase Price',
    getValue: (entry) => entry.pricePaidCents,
    cellValue: (entry) =>
        Text(_formatCents(entry.pricePaidCents, entry.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('variant'),
    label: 'Variant Description',
    getValue: (entry) => entry.variant,
    cellValue: (entry) => Text(entry.variant ?? ''),
    defaultWidth: 170,
    maxWidth: 420,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('format'),
    label: 'Format',
    getValue: (entry) => entry.referenceFormatLabel,
    cellValue: (entry) => Text(entry.referenceFormatLabel ?? ''),
    group: 'Edition',
    defaultWidth: 100,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('barcode'),
    label: 'Barcode',
    getValue: (entry) => entry.barcode,
    cellValue: (entry) => Text(entry.barcode ?? ''),
    group: 'Edition',
    defaultWidth: 160,
    maxWidth: 260,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('author'),
    label: 'Author',
    getValue: (entry) => entry.creators?.firstOrNull?['name']?.toString(),
    cellValue: (entry) => Text(entry.creators?.firstOrNull?['name']?.toString() ?? ''),
    defaultWidth: 160,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('artist'),
    label: 'Artist',
    getValue: (entry) => entry.series?.seriesTitle,
    cellValue: (entry) => Text(entry.series?.seriesTitle ?? ''),
    defaultWidth: 140,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('album'),
    label: 'Album',
    getValue: (entry) => entry.resolvedTitle,
    cellValue: (entry) => Text(entry.resolvedTitle),
    defaultWidth: 160,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('label'),
    label: 'Label',
    getValue: (entry) => entry.publisher,
    cellValue: (entry) => Text(entry.publisher ?? ''),
    defaultWidth: 140,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('catalogNumber'),
    label: 'Catalog Number',
    getValue: (entry) => entry.music?.catalogNumber,
    cellValue: (entry) => Text(entry.music?.catalogNumber ?? ''),
    defaultWidth: 130,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('discCount'),
    label: 'Disc Count',
    getValue: (entry) => entry.music?.discCount,
    cellValue: (entry) => Text(entry.music?.discCount?.toString() ?? ''),
    defaultWidth: 90,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('trackCount'),
    label: 'Track Count',
    getValue: (entry) => entry.music?.trackCount,
    cellValue: (entry) => Text(entry.music?.trackCount?.toString() ?? ''),
    defaultWidth: 90,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('length'),
    label: 'Length',
    getValue: (entry) => entry.music?.length,
    cellValue: (entry) => Text(entry.music?.length?.toString() ?? ''),
    defaultWidth: 80,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('vinylColor'),
    label: 'Vinyl Color',
    getValue: (entry) => entry.music?.vinylColor,
    cellValue: (entry) => Text(entry.music?.vinylColor ?? ''),
    defaultWidth: 110,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('rpm'),
    label: 'RPM',
    getValue: (entry) => entry.music?.rpm,
    cellValue: (entry) => Text(entry.music?.rpm?.toString() ?? ''),
    defaultWidth: 70,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('readStatus'),
    label: 'Read Status',
    getValue: (entry) => entry.readStatus,
    cellValue: (entry) => Text(entry.readStatus ?? ''),
    defaultWidth: 100,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('rating'),
    label: 'Rating',
    getValue: (entry) => entry.rating,
    cellValue: (entry) => Text(entry.rating?.toString() ?? ''),
    defaultWidth: 80,
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
);
