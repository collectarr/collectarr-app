import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:flutter/material.dart';

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

final commonFieldDefinitions = [
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('common.title'),
    label: 'Title',
    getValue: (dto) => dto.title,
  ),
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('common.publisher'),
    label: 'Publisher',
    getValue: (dto) => dto.publisher,
  ),
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('common.release_date'),
    label: 'Release date',
    getValue: (dto) => dto.releaseDate,
  ),
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('common.status'),
    label: 'Status',
    getValue: (dto) => dto.isOwned ? 'owned' : (dto.isWishlisted ? 'wishlist' : null),
  ),
];

final commonGroupDefinitions = [
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('title'),
    label: 'Title',
    getValue: (entry) => entry.title,
    sidebarTitle: 'Titles',
    icon: Icons.sort_by_alpha,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('publisher'),
    label: 'Publisher',
    getValue: (entry) => entry.publisher,
    sidebarTitle: 'Publishers',
    icon: Icons.business_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('release_date'),
    label: 'Release Date',
    getValue: (entry) => entry.releaseDate,
    sidebarTitle: 'Release Dates',
    icon: Icons.event_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('release_month'),
    label: 'Release Month',
    getValue: (entry) => entry.releaseDate,
    sidebarTitle: 'Release Months',
    icon: Icons.calendar_view_month_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('release_year'),
    label: 'Release Year',
    getValue: (entry) => entry.releaseYear,
    sidebarTitle: 'Release Years',
    icon: Icons.calendar_today_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('condition'),
    label: 'Condition',
    getValue: (entry) => entry.condition,
    sidebarTitle: 'Conditions',
    icon: Icons.rule_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('location'),
    label: 'Location',
    getValue: (entry) => entry.locationPath,
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('ownership'),
    label: 'Ownership',
    getValue: (entry) => entry.isOwned,
    sidebarTitle: 'Ownership',
    icon: Icons.inventory_2_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('added_date'),
    label: 'Added Date',
    getValue: (entry) => entry.addedAt,
    sidebarTitle: 'Added Dates',
    icon: Icons.playlist_add_check_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('added_month'),
    label: 'Added Month',
    getValue: (entry) => entry.addedAt,
    sidebarTitle: 'Added Months',
    icon: Icons.calendar_view_month_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('added_year'),
    label: 'Added Year',
    getValue: (entry) => entry.addedAt,
    sidebarTitle: 'Added Years',
    icon: Icons.calendar_today_outlined,
  ),
];

final commonSortDefinitions = [
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'title',
    label: 'Title',
    compare: (left, right) => (left.resolvedTitle ?? '').compareTo(right.resolvedTitle ?? ''),
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'publisher',
    label: 'Publisher',
    compare: (left, right) => (left.publisher ?? '').compareTo(right.publisher ?? ''),
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'release_date',
    label: 'Release Date',
    compare: (left, right) => (left.releaseDate ?? DateTime.fromMillisecondsSinceEpoch(0))
        .compareTo(right.releaseDate ?? DateTime.fromMillisecondsSinceEpoch(0)),
    defaultAscending: false,
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'condition',
    label: 'Condition',
    compare: (left, right) => (left.condition ?? '').compareTo(right.condition ?? ''),
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'price',
    label: 'Purchase price',
    compare: (left, right) {
      final l = left.pricePaidCents;
      final r = right.pricePaidCents;
      if (l == null && r != null) return 1;
      if (l != null && r == null) return -1;
      return (l ?? 0).compareTo(r ?? 0);
    },
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'location',
    label: 'Location',
    compare: (left, right) => (left.locationPath ?? '').compareTo(right.locationPath ?? ''),
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'collection_status',
    label: 'Collection status',
    compare: (left, right) => (left.collectionStatus ?? '').compareTo(right.collectionStatus ?? ''),
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'wishlist',
    label: 'Wishlist',
    compare: (left, right) => (left.isWishlisted ? 1 : 0).compareTo(right.isWishlisted ? 1 : 0),
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'added',
    label: 'Added date',
    compare: (left, right) => (left.addedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
        .compareTo(right.addedAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
    defaultAscending: false,
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'updated',
    label: 'Updated',
    compare: (left, right) => (left.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
        .compareTo(right.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
    defaultAscending: false,
  ),
];

final commonColumnDefinitions = [
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
    id: LibraryFieldId<Object?>('format'),
    label: 'Format',
    getValue: (entry) => entry.referenceFormatLabel,
    cellValue: (entry) => Text(entry.referenceFormatLabel ?? ''),
    defaultWidth: 100,
  ),
];
