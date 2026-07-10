import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/config/common_fields.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:flutter/material.dart';

final boardgameLibraryFieldDefinitions = [
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('boardgame.title'),
    label: 'Title',
    getValue: (dto) => dto.title,
  ),
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('boardgame.series'),
    label: 'Series',
    getValue: (dto) => dto.seriesTitle,
  ),
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('boardgame.number'),
    label: 'Number',
    getValue: (dto) => dto.itemNumber,
  ),
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('boardgame.publisher'),
    label: 'Publisher',
    getValue: (dto) => dto.publisher,
  ),
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('boardgame.release_date'),
    label: 'Release date',
    getValue: (dto) => dto.releaseDate,
  ),
];

const boardGamesLibraryGroupModes = [
  LibraryGroupMode.publisher,
  LibraryGroupMode.series,
  LibraryGroupMode.year,
  LibraryGroupMode.location,
  LibraryGroupMode.title,
  LibraryGroupMode.ownership,
];

final boardGamesLibraryGroupDefinitions = [
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('publisher'),
    label: 'Publisher / Designer',
    sidebarTitle: 'Publishers / Designers',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('series'),
    label: 'Series',
    sidebarTitle: 'Series',
    icon: Icons.collections_bookmark_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('year'),
    label: 'Year',
    sidebarTitle: 'Years',
    icon: Icons.calendar_today_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('location'),
    label: 'Location',
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('title'),
    label: 'Title',
    sidebarTitle: 'Titles',
    icon: Icons.sort_by_alpha,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('ownership'),
    label: 'Ownership',
    sidebarTitle: 'Ownership',
    icon: Icons.inventory_2_outlined,
  ),
];

final boardGamesLibrarySortDefinitions = [
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'series',
    compare: (left, right) => (left.series?.seriesTitle ?? "").compareTo(right.series?.seriesTitle ?? ""),
    label: 'Series',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'publisher',
    compare: (left, right) => (left.publisher ?? "").compareTo(right.publisher ?? ""),
    label: 'Publisher / Designer',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
      id: 'status',
    compare: (left, right) => (left.isOwned ? 0 : 1).compareTo(right.isOwned ? 0 : 1), label: 'Status'),
  LibrarySortDefinition<LibraryWorkspaceEntry>(id: 'title',
    compare: (left, right) => (left.resolvedTitle ?? "").compareTo(right.resolvedTitle ?? ""), label: 'Title'),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'issue',
    compare: (left, right) => (left.itemNumber ?? "").compareTo(right.itemNumber ?? ""),
    label: 'Issue / number',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'story_arc',
    compare: (left, right) => (left.storyArcs?.join(", ") ?? "").compareTo(right.storyArcs?.join(", ") ?? ""),
    label: 'Story arc',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'variant',
    compare: (left, right) => (left.variant ?? "").compareTo(right.variant ?? ""),
    label: 'Variant',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'format',
    compare: (left, right) => (left.referenceFormatLabel ?? "").compareTo(right.referenceFormatLabel ?? ""),
    label: 'Format',
    group: 'Edition',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'release_date',
    compare: (left, right) => (left.releaseDate ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(right.releaseDate ?? DateTime.fromMillisecondsSinceEpoch(0)),
    label: 'Release date',
    defaultAscending: false,
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'barcode',
    compare: (left, right) => (left.barcode ?? "").compareTo(right.barcode ?? ""),
    label: 'Barcode',
    group: 'Edition',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'grade',
    compare: (left, right) => (left.grade ?? "").compareTo(right.grade ?? ""),
    label: 'Grade',
    group: 'Value',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'condition',
    compare: (left, right) => (left.condition ?? "").compareTo(right.condition ?? ""),
    label: 'Condition',
    group: 'Value',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'price',
    compare: (left, right) => (left.pricePaidCents ?? 0).compareTo(right.pricePaidCents ?? 0),
    label: 'Purchase price',
    group: 'Value',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'location',
    compare: (left, right) => (left.locationPath ?? "").compareTo(right.locationPath ?? ""),
    label: 'Location',
    group: 'Personal',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'collection_status',
    compare: (left, right) => (left.collectionStatus ?? "").compareTo(right.collectionStatus ?? ""),
    label: 'Collection status',
    group: 'Personal',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'wishlist',
    compare: (left, right) => (left.isWishlisted ? 1 : 0).compareTo(right.isWishlisted ? 1 : 0),
    label: 'Wishlist',
    group: 'Personal',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'added',
    compare: (left, right) => (left.addedAt ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(left.addedAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
    label: 'Added date',
    group: 'Personal',
    defaultAscending: false,
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'updated',
    compare: (left, right) => (left.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(right.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
    label: 'Updated',
    group: 'Personal',
    defaultAscending: false,
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
      id: 'country',
    compare: (left, right) => (left.country ?? "").compareTo(right.country ?? ""), label: 'Country'),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'language',
    compare: (left, right) => (left.language ?? "").compareTo(right.language ?? ""),
    label: 'Language',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'page_count',
    compare: (left, right) => (left.publishing?.pageCount ?? 0).compareTo(right.publishing?.pageCount ?? 0),
    label: 'Page count',
    group: 'Edition',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'age_rating',
    compare: (left, right) => (left.ageRating ?? "").compareTo(right.ageRating ?? ""),
    label: 'Age rating',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
      id: 'imprint',
    compare: (left, right) => (left.publishing?.imprint ?? "").compareTo(right.publishing?.imprint ?? ""), label: 'Imprint'),
];

const boardGamesLibrarySortColumns = [
  LibrarySortColumn.series,
  LibrarySortColumn.publisher,
  LibrarySortColumn.status,
  LibrarySortColumn.title,
  LibrarySortColumn.releaseDate,
  LibrarySortColumn.country,
  LibrarySortColumn.language,
  LibrarySortColumn.ageRating,
  LibrarySortColumn.collectionStatus,
  LibrarySortColumn.added,
  LibrarySortColumn.updated,
];

const boardGamesLibraryTableColumns = [
  LibraryTableColumn.status,
  LibraryTableColumn.cover,
  LibraryTableColumn.title,
  LibraryTableColumn.publisher,
  LibraryTableColumn.releaseDate,
  LibraryTableColumn.barcode,
  LibraryTableColumn.condition,
  LibraryTableColumn.price,
  LibraryTableColumn.location,
  LibraryTableColumn.wishlist,
  LibraryTableColumn.updated,
];

const boardGamesLibraryDefaultVisibleColumns = {
  LibraryTableColumn.status,
  LibraryTableColumn.cover,
  LibraryTableColumn.title,
  LibraryTableColumn.publisher,
  LibraryTableColumn.releaseDate,
  LibraryTableColumn.barcode,
  LibraryTableColumn.condition,
  LibraryTableColumn.price,
  LibraryTableColumn.location,
  LibraryTableColumn.wishlist,
  LibraryTableColumn.updated,
};

final boardGamesLibraryColumnDefinitions = [
  ...commonColumnDefinitions,
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('variant'),
    label: 'Edition / Print run',
    getValue: (entry) => entry.variant,
    cellValue: (entry) => Text(entry.variant ?? ''),
    defaultWidth: 170,
    maxWidth: 420,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('barcode'),
    label: 'UPC / Barcode',
    getValue: (entry) => entry.barcode,
    cellValue: (entry) => Text(entry.barcode ?? ''),
    group: 'Edition',
    defaultWidth: 160,
    maxWidth: 260,
  ),
];

const boardGamesLibraryDefaultVisibleColumnIds = {
  'status',
  'cover',
  'title',
  'publisher',
  'release_date',
  'barcode',
  'condition',
  'price',
  'location',
  'wishlist',
  'updated'
};
