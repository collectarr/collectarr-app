import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_dto.dart';
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

final boardGamesLibraryGroupDefinitions = [
  LibraryGroupDefinition<BoardGameWorkspaceDto, Object?>(
    getValue: (dto) => dto.publisher,
    id: LibraryFieldId<Object?>('publisher'),
    label: 'Publisher / Designer',
    sidebarTitle: 'Publishers / Designers',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<BoardGameWorkspaceDto, Object?>(
    getValue: (dto) => dto.seriesTitle,
    id: LibraryFieldId<Object?>('series'),
    label: 'Series',
    sidebarTitle: 'Series',
    icon: Icons.collections_bookmark_outlined,
  ),
  LibraryGroupDefinition<BoardGameWorkspaceDto, Object?>(
    getValue: (dto) => dto.releaseDate?.year,
    id: LibraryFieldId<Object?>('year'),
    label: 'Year',
    sidebarTitle: 'Years',
    icon: Icons.calendar_today_outlined,
  ),
  LibraryGroupDefinition<BoardGameWorkspaceDto, Object?>(
    getValue: (dto) => dto.locationPath,
    id: LibraryFieldId<Object?>('location'),
    label: 'Location',
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
  LibraryGroupDefinition<BoardGameWorkspaceDto, Object?>(
    getValue: (dto) => dto.title,
    id: LibraryFieldId<Object?>('title'),
    label: 'Title',
    sidebarTitle: 'Titles',
    icon: Icons.sort_by_alpha,
  ),
  LibraryGroupDefinition<BoardGameWorkspaceDto, Object?>(
    getValue: (dto) => dto.isOwned,
    id: LibraryFieldId<Object?>('ownership'),
    label: 'Ownership',
    sidebarTitle: 'Ownership',
    icon: Icons.inventory_2_outlined,
  ),
];

final boardGamesLibrarySortDefinitions = [
  LibrarySortDefinition<BoardGameWorkspaceDto>(
    id: 'series',
    compare: (left, right) => (left.seriesTitle ?? "").compareTo(right.seriesTitle ?? ""),
    label: 'Series',
  ),
  LibrarySortDefinition<BoardGameWorkspaceDto>(
    id: 'publisher',
    compare: (left, right) => (left.publisher ?? "").compareTo(right.publisher ?? ""),
    label: 'Publisher / Designer',
  ),
  LibrarySortDefinition<BoardGameWorkspaceDto>(
    id: 'status',
    compare: (left, right) {
      int rank(BoardGameWorkspaceDto dto) {
        if (dto.isOwned) return 0;
        if (dto.isWishlisted) return 1;
        return 2;
      }
      final res = rank(left).compareTo(rank(right));
      return res != 0 ? res : left.title.compareTo(right.title);
    },
    label: 'Status',
  ),
  LibrarySortDefinition<BoardGameWorkspaceDto>(
    id: 'title',
    compare: (left, right) => left.title.compareTo(right.title),
    label: 'Title',
  ),
  LibrarySortDefinition<BoardGameWorkspaceDto>(
    id: 'number',
    compare: (left, right) => (left.itemNumber ?? "").compareTo(right.itemNumber ?? ""),
    label: 'Number',
  ),
  LibrarySortDefinition<BoardGameWorkspaceDto>(
    id: 'variant',
    compare: (left, right) => (left.variant ?? "").compareTo(right.variant ?? ""),
    label: 'Variant',
  ),
  LibrarySortDefinition<BoardGameWorkspaceDto>(
    id: 'format',
    compare: (left, right) => (left.referenceFormatLabel ?? "").compareTo(right.referenceFormatLabel ?? ""),
    label: 'Format',
    group: 'Edition',
  ),
  LibrarySortDefinition<BoardGameWorkspaceDto>(
    id: 'release_date',
    compare: (left, right) {
      return (left.releaseDate ?? DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(right.releaseDate ?? DateTime.fromMillisecondsSinceEpoch(0));
    },
    label: 'Release date',
    defaultAscending: false,
  ),
  LibrarySortDefinition<BoardGameWorkspaceDto>(
    id: 'barcode',
    compare: (left, right) => (left.barcode ?? "").compareTo(right.barcode ?? ""),
    label: 'Barcode',
    group: 'Edition',
  ),
  LibrarySortDefinition<BoardGameWorkspaceDto>(
    id: 'condition',
    compare: (left, right) => (left.condition ?? "").compareTo(right.condition ?? ""),
    label: 'Condition',
    group: 'Value',
  ),
  LibrarySortDefinition<BoardGameWorkspaceDto>(
    id: 'price',
    compare: (left, right) => (left.pricePaidCents ?? 0).compareTo(right.pricePaidCents ?? 0),
    label: 'Purchase price',
    group: 'Value',
  ),
  LibrarySortDefinition<BoardGameWorkspaceDto>(
    id: 'location',
    compare: (left, right) => (left.locationPath ?? "").compareTo(right.locationPath ?? ""),
    label: 'Location',
    group: 'Personal',
  ),
  LibrarySortDefinition<BoardGameWorkspaceDto>(
    id: 'collection_status',
    compare: (left, right) => (left.collectionStatus ?? "").compareTo(right.collectionStatus ?? ""),
    label: 'Collection status',
    group: 'Personal',
  ),
  LibrarySortDefinition<BoardGameWorkspaceDto>(
    id: 'wishlist',
    compare: (left, right) => (left.isWishlisted ? 1 : 0).compareTo(right.isWishlisted ? 1 : 0),
    label: 'Wishlist',
    group: 'Personal',
  ),
  LibrarySortDefinition<BoardGameWorkspaceDto>(
    id: 'added',
    compare: (left, right) {
      return (left.addedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(right.addedAt ?? DateTime.fromMillisecondsSinceEpoch(0));
    },
    label: 'Added date',
    group: 'Personal',
    defaultAscending: false,
  ),
  LibrarySortDefinition<BoardGameWorkspaceDto>(
    id: 'updated',
    compare: (left, right) => left.updatedAt.compareTo(right.updatedAt),
    label: 'Updated',
    group: 'Personal',
    defaultAscending: false,
  ),
  LibrarySortDefinition<BoardGameWorkspaceDto>(
    id: 'country',
    compare: (left, right) => (left.country ?? "").compareTo(right.country ?? ""),
    label: 'Country',
  ),
  LibrarySortDefinition<BoardGameWorkspaceDto>(
    id: 'language',
    compare: (left, right) => (left.language ?? "").compareTo(right.language ?? ""),
    label: 'Language',
  ),
  LibrarySortDefinition<BoardGameWorkspaceDto>(
    id: 'age_rating',
    compare: (left, right) => (left.grade ?? "").compareTo(right.grade ?? ""),
    label: 'Age rating',
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
  'updated',
};

final boardGamesLibraryColumnDefinitions = [
  LibraryColumnDefinition<BoardGameWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('status'),
    label: 'Status',
    getValue: (dto) => dto.isWishlisted ? 'wishlist' : (dto.isOwned ? 'owned' : null),
    cellValue: (dto) => Text(dto.isWishlisted ? 'Wishlist' : (dto.isOwned ? 'Owned' : '')),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<BoardGameWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('cover'),
    label: '',
    getValue: (dto) => dto.coverImageUrl,
    cellValue: (dto) => dto.coverImageUrl == null
        ? const SizedBox.shrink()
        : Image.network(
            dto.coverImageUrl!,
            width: 32,
            height: 32,
            fit: BoxFit.cover,
          ),
    sortable: false,
    groupable: false,
    defaultWidth: 42,
    minWidth: 44,
  ),
  LibraryColumnDefinition<BoardGameWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('title'),
    label: 'Title',
    getValue: (dto) => dto.title,
    cellValue: (dto) => Text(dto.title),
    defaultWidth: 260,
    maxWidth: 520,
  ),
  LibraryColumnDefinition<BoardGameWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('publisher'),
    label: 'Publisher',
    getValue: (dto) => dto.publisher,
    cellValue: (dto) => Text(dto.publisher ?? ''),
    defaultWidth: 140,
  ),
  LibraryColumnDefinition<BoardGameWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('release_date'),
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
    cellValue: (dto) => Text(_formatDate(dto.releaseDate)),
    defaultWidth: 118,
  ),
  LibraryColumnDefinition<BoardGameWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('wishlist'),
    label: 'Wishlist',
    getValue: (dto) => dto.isWishlisted,
    cellValue: (dto) => Text(dto.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<BoardGameWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('updated'),
    label: 'Updated',
    getValue: (dto) => dto.updatedAt,
    cellValue: (dto) => Text(_formatDate(dto.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<BoardGameWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('added'),
    label: 'Added',
    getValue: (dto) => dto.addedAt,
    cellValue: (dto) => Text(_formatDate(dto.addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<BoardGameWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('location'),
    label: 'Location',
    getValue: (dto) => dto.locationPath,
    cellValue: (dto) => Text(dto.locationPath ?? ''),
    group: 'Personal',
    defaultWidth: 118,
  ),
  LibraryColumnDefinition<BoardGameWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('condition'),
    label: 'Condition',
    getValue: (dto) => dto.condition,
    cellValue: (dto) => Text(dto.condition ?? ''),
    group: 'Value',
    defaultWidth: 124,
  ),
  LibraryColumnDefinition<BoardGameWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('price'),
    label: 'Purchase Price',
    getValue: (dto) => dto.pricePaidCents,
    cellValue: (dto) => Text(_formatCents(dto.pricePaidCents, dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  LibraryColumnDefinition<BoardGameWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('format'),
    label: 'Format',
    getValue: (dto) => dto.referenceFormatLabel,
    cellValue: (dto) => Text(dto.referenceFormatLabel ?? ''),
    defaultWidth: 100,
  ),
  LibraryColumnDefinition<BoardGameWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('variant'),
    label: 'Edition / Print run',
    getValue: (dto) => dto.variant,
    cellValue: (dto) => Text(dto.variant ?? ''),
    defaultWidth: 170,
    maxWidth: 420,
  ),
  LibraryColumnDefinition<BoardGameWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('barcode'),
    label: 'UPC / Barcode',
    getValue: (dto) => dto.barcode,
    cellValue: (dto) => Text(dto.barcode ?? ''),
    group: 'Edition',
    defaultWidth: 160,
    maxWidth: 260,
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
