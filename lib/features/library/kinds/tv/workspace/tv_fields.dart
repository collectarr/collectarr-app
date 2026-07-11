import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/config/common_fields.dart';
import 'package:collectarr_app/features/library/config/library_kind_workspace_behavior.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:flutter/material.dart';

final tvLibraryFieldDefinitions = [
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('tv.title'),
    label: 'Title',
    getValue: (dto) => dto.title,
  ),
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('tv.series'),
    label: 'Series',
    getValue: (dto) => dto.seriesTitle,
  ),
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('tv.number'),
    label: 'Number',
    getValue: (dto) => dto.itemNumber,
  ),
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('tv.publisher'),
    label: 'Publisher',
    getValue: (dto) => dto.publisher,
  ),
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('tv.release_date'),
    label: 'Release date',
    getValue: (dto) => dto.releaseDate,
  ),
];

const tvDefaultWorkspaceGroupMode = 'series';
const tvDefaultWorkspaceGroupPresentation = LibraryGroupPresentation.folderGrid;
const tvDefaultVideoDisplayLevel = VideoDisplayLevel.season;
const tvDefaultVideoGrouping = VideoGroupingDefault.bySeries;

const tvLibraryGroupModes = [
  'series',
  'genre',
  'country',
  'language',
  'age_rating',
  'movie_or_tv_series',
  'release_date',
  'release_month',
  'release_year',
  'publisher',
  'title',
  'ownership',
  'added_date',
  'added_month',
  'added_year',
  'collection_status',
  'modified_date',
  'modified_month',
  'watched',
  'watch_date',
  'watch_month',
  'watch_year',
  'watched_where',
];

final tvLibraryGroupDefinitions = [
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('genre'),
    label: 'Genres',
    sidebarTitle: 'Genres',
    icon: Icons.theater_comedy_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('country'),
    label: 'Country',
    sidebarTitle: 'Countries',
    icon: Icons.flag_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('language'),
    label: 'Language',
    sidebarTitle: 'Languages',
    icon: Icons.translate_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('age_rating'),
    label: 'Age',
    sidebarTitle: 'Age Ratings',
    icon: Icons.verified_user_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('movie_or_tv_series'),
    label: 'Movie / TV Series',
    sidebarTitle: 'Movie / TV Series',
    icon: Icons.tv_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('release_date'),
    label: 'Release Date',
    sidebarTitle: 'Release Dates',
    icon: Icons.event_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('release_month'),
    label: 'Release Month',
    sidebarTitle: 'Release Months',
    icon: Icons.event_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('release_year'),
    label: 'Release Year',
    sidebarTitle: 'Release Years',
    icon: Icons.event_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('series'),
    label: 'Series',
    sidebarTitle: 'Series',
    icon: Icons.tv_outlined,
    presentation: tvDefaultWorkspaceGroupPresentation,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('publisher'),
    label: 'Networks',
    sidebarTitle: 'Networks',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
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
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('added_date'),
    label: 'Added Date',
    sidebarTitle: 'Added Dates',
    icon: Icons.add_task_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('added_month'),
    label: 'Added Month',
    sidebarTitle: 'Added Months',
    icon: Icons.add_task_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('added_year'),
    label: 'Added Year',
    sidebarTitle: 'Added Years',
    icon: Icons.add_task_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('collection_status'),
    label: 'Collection Status',
    sidebarTitle: 'Collection Status',
    icon: Icons.stacked_bar_chart_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('modified_date'),
    label: 'Modified Date',
    sidebarTitle: 'Modified Dates',
    icon: Icons.update_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('modified_month'),
    label: 'Modified Month',
    sidebarTitle: 'Modified Months',
    icon: Icons.update_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('watched'),
    label: 'Watched',
    sidebarTitle: 'Watched',
    icon: Icons.visibility_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('watch_date'),
    label: 'Watch Date',
    sidebarTitle: 'Watch Dates',
    icon: Icons.play_circle_outline,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('watch_month'),
    label: 'Watch Month',
    sidebarTitle: 'Watch Months',
    icon: Icons.play_circle_outline,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('watch_year'),
    label: 'Watch Year',
    sidebarTitle: 'Watch Years',
    icon: Icons.play_circle_outline,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) => null,
    id: LibraryFieldId<Object?>('watched_where'),
    label: 'Watched Where',
    sidebarTitle: 'Watched Where',
    icon: Icons.tv_outlined,
  ),
];

final tvLibrarySortDefinitions = [
  LibrarySortDefinition<LibraryWorkspaceEntry>(
      id: 'series',
    compare: (left, right) => (left.series?.seriesTitle ?? "").compareTo(right.series?.seriesTitle ?? ""), label: 'Series'),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'publisher',
    compare: (left, right) => (left.publisher ?? "").compareTo(right.publisher ?? ""),
    label: 'Network',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'title',
    compare: (left, right) => (left.resolvedTitle ?? "").compareTo(right.resolvedTitle ?? ""),
    label: 'Title',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'release_date',
    compare: (left, right) => (left.releaseDate ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(right.releaseDate ?? DateTime.fromMillisecondsSinceEpoch(0)),
    label: 'Release date',
    defaultAscending: false,
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'country',
    compare: (left, right) => (left.country ?? "").compareTo(right.country ?? ""),
    label: 'Country',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'language',
    compare: (left, right) => (left.language ?? "").compareTo(right.language ?? ""),
    label: 'Language',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'age_rating',
    compare: (left, right) => (left.ageRating ?? "").compareTo(right.ageRating ?? ""),
    label: 'Age rating',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'collection_status',
    compare: (left, right) => (left.collectionStatus ?? "").compareTo(right.collectionStatus ?? ""),
    label: 'Collection status',
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
];
const tvLibrarySortColumns = [
  'status',
  'title',
  'publisher',
  'release_date',
  'country',
  'language',
  'age_rating',
  'condition',
  'price',
  'location',
  'collection_status',
  'wishlist',
  'added',
  'updated',
];

const tvLibraryTableColumns = [
  'status',
  'cover',
  'title',
  'publisher',
  'release_date',
  'country',
  'language',
  'age_rating',
  'wishlist',
  'updated',
];

const tvLibraryDefaultVisibleColumns = {
  'status',
  'cover',
  'title',
  'publisher',
  'release_date',
  'country',
  'language',
  'age_rating',
  'wishlist',
  'updated',
};

final tvLibraryColumnDefinitions = [
  ...commonColumnDefinitions,
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('variant'),
    label: 'Edition / Release',
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

const tvLibraryDefaultVisibleColumnIds = {
  'status',
  'cover',
  'title',
  'publisher',
  'release_date',
  'country',
  'language',
  'age_rating',
  'wishlist',
  'updated'
};
