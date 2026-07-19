import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
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
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) {
      final dto = BoardGameWorkspaceDto.fromEntry(entry);
      return dto.publisher;
    },
    id: LibraryFieldId<Object?>('publisher'),
    label: 'Publisher / Designer',
    sidebarTitle: 'Publishers / Designers',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) {
      final dto = BoardGameWorkspaceDto.fromEntry(entry);
      return dto.seriesTitle;
    },
    id: LibraryFieldId<Object?>('series'),
    label: 'Series',
    sidebarTitle: 'Series',
    icon: Icons.collections_bookmark_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) {
      final dto = BoardGameWorkspaceDto.fromEntry(entry);
      return dto.releaseDate?.year;
    },
    id: LibraryFieldId<Object?>('year'),
    label: 'Year',
    sidebarTitle: 'Years',
    icon: Icons.calendar_today_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) {
      final dto = BoardGameWorkspaceDto.fromEntry(entry);
      return dto.locationPath;
    },
    id: LibraryFieldId<Object?>('location'),
    label: 'Location',
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) {
      final dto = BoardGameWorkspaceDto.fromEntry(entry);
      return dto.title;
    },
    id: LibraryFieldId<Object?>('title'),
    label: 'Title',
    sidebarTitle: 'Titles',
    icon: Icons.sort_by_alpha,
  ),
  LibraryGroupDefinition<LibraryWorkspaceEntry, Object?>(
    getValue: (entry) {
      final dto = BoardGameWorkspaceDto.fromEntry(entry);
      return dto.isOwned;
    },
    id: LibraryFieldId<Object?>('ownership'),
    label: 'Ownership',
    sidebarTitle: 'Ownership',
    icon: Icons.inventory_2_outlined,
  ),
];

final boardGamesLibrarySortDefinitions = [
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'series',
    compare: (left, right) {
      final l = BoardGameWorkspaceDto.fromEntry(left);
      final r = BoardGameWorkspaceDto.fromEntry(right);
      return (l.seriesTitle ?? "").compareTo(r.seriesTitle ?? "");
    },
    label: 'Series',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'publisher',
    compare: (left, right) {
      final l = BoardGameWorkspaceDto.fromEntry(left);
      final r = BoardGameWorkspaceDto.fromEntry(right);
      return (l.publisher ?? "").compareTo(r.publisher ?? "");
    },
    label: 'Publisher / Designer',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'status',
    compare: (left, right) {
      final l = BoardGameWorkspaceDto.fromEntry(left);
      final r = BoardGameWorkspaceDto.fromEntry(right);
      int rank(BoardGameWorkspaceDto dto) {
        if (dto.isOwned) return 0;
        if (dto.isWishlisted) return 1;
        return 2;
      }
      final res = rank(l).compareTo(rank(r));
      return res != 0 ? res : l.title.compareTo(r.title);
    },
    label: 'Status',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'title',
    compare: (left, right) {
      final l = BoardGameWorkspaceDto.fromEntry(left);
      final r = BoardGameWorkspaceDto.fromEntry(right);
      return l.title.compareTo(r.title);
    },
    label: 'Title',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'issue',
    compare: (left, right) {
      final l = BoardGameWorkspaceDto.fromEntry(left);
      final r = BoardGameWorkspaceDto.fromEntry(right);
      return (l.itemNumber ?? "").compareTo(r.itemNumber ?? "");
    },
    label: 'Issue / number',
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
    compare: (left, right) {
      final l = BoardGameWorkspaceDto.fromEntry(left);
      final r = BoardGameWorkspaceDto.fromEntry(right);
      return (l.releaseDate ?? DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(r.releaseDate ?? DateTime.fromMillisecondsSinceEpoch(0));
    },
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
    id: 'condition',
    compare: (left, right) {
      final l = BoardGameWorkspaceDto.fromEntry(left);
      final r = BoardGameWorkspaceDto.fromEntry(right);
      return (l.condition ?? "").compareTo(r.condition ?? "");
    },
    label: 'Condition',
    group: 'Value',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'price',
    compare: (left, right) {
      final l = BoardGameWorkspaceDto.fromEntry(left);
      final r = BoardGameWorkspaceDto.fromEntry(right);
      return (l.pricePaidCents ?? 0).compareTo(r.pricePaidCents ?? 0);
    },
    label: 'Purchase price',
    group: 'Value',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'location',
    compare: (left, right) {
      final l = BoardGameWorkspaceDto.fromEntry(left);
      final r = BoardGameWorkspaceDto.fromEntry(right);
      return (l.locationPath ?? "").compareTo(r.locationPath ?? "");
    },
    label: 'Location',
    group: 'Personal',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'collection_status',
    compare: (left, right) {
      final l = BoardGameWorkspaceDto.fromEntry(left);
      final r = BoardGameWorkspaceDto.fromEntry(right);
      return (l.collectionStatus ?? "").compareTo(r.collectionStatus ?? "");
    },
    label: 'Collection status',
    group: 'Personal',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'wishlist',
    compare: (left, right) {
      final l = BoardGameWorkspaceDto.fromEntry(left);
      final r = BoardGameWorkspaceDto.fromEntry(right);
      return (l.isWishlisted ? 1 : 0).compareTo(r.isWishlisted ? 1 : 0);
    },
    label: 'Wishlist',
    group: 'Personal',
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'added',
    compare: (left, right) {
      final l = BoardGameWorkspaceDto.fromEntry(left);
      final r = BoardGameWorkspaceDto.fromEntry(right);
      return (l.addedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(r.addedAt ?? DateTime.fromMillisecondsSinceEpoch(0));
    },
    label: 'Added date',
    group: 'Personal',
    defaultAscending: false,
  ),
  LibrarySortDefinition<LibraryWorkspaceEntry>(
    id: 'updated',
    compare: (left, right) {
      final l = BoardGameWorkspaceDto.fromEntry(left);
      final r = BoardGameWorkspaceDto.fromEntry(right);
      return l.updatedAt.compareTo(r.updatedAt);
    },
    label: 'Updated',
    group: 'Personal',
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
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('status'),
    label: 'Status',
    getValue: (entry) {
      final dto = BoardGameWorkspaceDto.fromEntry(entry);
      return dto.isWishlisted ? 'wishlist' : (dto.isOwned ? 'owned' : null);
    },
    cellValue: (entry) {
      final dto = BoardGameWorkspaceDto.fromEntry(entry);
      return Text(dto.isWishlisted ? 'Wishlist' : (dto.isOwned ? 'Owned' : ''));
    },
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
    getValue: (entry) => BoardGameWorkspaceDto.fromEntry(entry).title,
    cellValue: (entry) => Text(BoardGameWorkspaceDto.fromEntry(entry).title),
    defaultWidth: 260,
    maxWidth: 520,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('publisher'),
    label: 'Publisher',
    getValue: (entry) => BoardGameWorkspaceDto.fromEntry(entry).publisher,
    cellValue: (entry) => Text(BoardGameWorkspaceDto.fromEntry(entry).publisher ?? ''),
    defaultWidth: 140,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('release_date'),
    label: 'Release Date',
    getValue: (entry) => BoardGameWorkspaceDto.fromEntry(entry).releaseDate,
    cellValue: (entry) => Text(_formatDate(BoardGameWorkspaceDto.fromEntry(entry).releaseDate)),
    defaultWidth: 118,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('wishlist'),
    label: 'Wishlist',
    getValue: (entry) => BoardGameWorkspaceDto.fromEntry(entry).isWishlisted,
    cellValue: (entry) => Text(BoardGameWorkspaceDto.fromEntry(entry).isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('updated'),
    label: 'Updated',
    getValue: (entry) => BoardGameWorkspaceDto.fromEntry(entry).updatedAt,
    cellValue: (entry) => Text(_formatDate(BoardGameWorkspaceDto.fromEntry(entry).updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('added'),
    label: 'Added',
    getValue: (entry) => BoardGameWorkspaceDto.fromEntry(entry).addedAt,
    cellValue: (entry) => Text(_formatDate(BoardGameWorkspaceDto.fromEntry(entry).addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('location'),
    label: 'Location',
    getValue: (entry) => BoardGameWorkspaceDto.fromEntry(entry).locationPath,
    cellValue: (entry) => Text(BoardGameWorkspaceDto.fromEntry(entry).locationPath ?? ''),
    group: 'Personal',
    defaultWidth: 118,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('condition'),
    label: 'Condition',
    getValue: (entry) => BoardGameWorkspaceDto.fromEntry(entry).condition,
    cellValue: (entry) => Text(BoardGameWorkspaceDto.fromEntry(entry).condition ?? ''),
    group: 'Value',
    defaultWidth: 124,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('price'),
    label: 'Purchase Price',
    getValue: (entry) => BoardGameWorkspaceDto.fromEntry(entry).pricePaidCents,
    cellValue: (entry) {
      final dto = BoardGameWorkspaceDto.fromEntry(entry);
      return Text(_formatCents(dto.pricePaidCents, entry.currency));
    },
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
