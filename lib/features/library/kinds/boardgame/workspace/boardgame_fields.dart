import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:flutter/material.dart';

/// Single source of truth schema for BoardGame kind fields.
abstract final class BoardGameKindSchema {
  static final title = textField<BoardGameWorkspaceDto>(
    id: 'boardgame.title',
    label: 'Title',
    getValue: (dto) => dto.title,
  );

  static final publisher = textField<BoardGameWorkspaceDto>(
    id: 'boardgame.publisher',
    label: 'Publisher / Designer',
    getValue: (dto) => dto.publisher,
  );

  static final series = textField<BoardGameWorkspaceDto>(
    id: 'boardgame.series',
    label: 'Series',
    getValue: (dto) => dto.seriesTitle,
  );

  static final releaseDate = dateField<BoardGameWorkspaceDto>(
    id: 'boardgame.release_date',
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
  );

  static final condition = textField<BoardGameWorkspaceDto>(
    id: 'boardgame.condition',
    label: 'Condition',
    getValue: (dto) => dto.condition,
  );

  static final location = textField<BoardGameWorkspaceDto>(
    id: 'boardgame.location',
    label: 'Location',
    getValue: (dto) => dto.locationPath,
  );

  static final price = moneyField<BoardGameWorkspaceDto>(
    id: 'boardgame.price',
    label: 'Purchase Price',
    getValue: (dto) => dto.pricePaidCents,
  );

  static final barcode = textField<BoardGameWorkspaceDto>(
    id: 'boardgame.barcode',
    label: 'UPC / Barcode',
    getValue: (dto) => dto.barcode,
  );
}

final boardgameLibraryFieldDefinitions = [
  BoardGameKindSchema.title,
  BoardGameKindSchema.publisher,
  BoardGameKindSchema.series,
  BoardGameKindSchema.releaseDate,
  BoardGameKindSchema.condition,
  BoardGameKindSchema.location,
  BoardGameKindSchema.price,
  BoardGameKindSchema.barcode,
];

final boardGamesLibraryGroupDefinitions = [
  groupFromField(
    BoardGameKindSchema.publisher,
    sidebarTitle: 'Publishers / Designers',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
  ),
  groupFromField(
    BoardGameKindSchema.series,
    sidebarTitle: 'Series',
    icon: Icons.collections_bookmark_outlined,
  ),
  groupFromField(
    BoardGameKindSchema.location,
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
];

final boardGamesLibrarySortDefinitions = [
  sortFromField(BoardGameKindSchema.series),
  sortFromField(BoardGameKindSchema.publisher),
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
  sortFromField(BoardGameKindSchema.title),
  sortFromField(BoardGameKindSchema.releaseDate, defaultAscending: false),
];

const boardGamesLibraryDefaultVisibleColumnIds = {
  'status',
  'cover',
  'title',
  'publisher',
  'release_date',
  'barcode',
  'rating',
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
  columnFromField(BoardGameKindSchema.title, defaultWidth: 260, maxWidth: 520),
  columnFromField(BoardGameKindSchema.publisher, defaultWidth: 160),
  columnFromField(
    BoardGameKindSchema.releaseDate,
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
  columnFromField(BoardGameKindSchema.location, group: 'Personal', defaultWidth: 118),
  columnFromField(BoardGameKindSchema.condition, group: 'Value', defaultWidth: 124),
  columnFromField(
    BoardGameKindSchema.price,
    cellValue: (dto) => Text(_formatCents(dto.pricePaidCents, dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  columnFromField(BoardGameKindSchema.barcode, group: 'Edition', defaultWidth: 160, maxWidth: 260),
  LibraryColumnDefinition<BoardGameWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('rating'),
    label: 'Rating',
    getValue: (dto) => dto.rating,
    cellValue: (dto) => Text(dto.rating?.toString() ?? ''),
    defaultWidth: 80,
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
