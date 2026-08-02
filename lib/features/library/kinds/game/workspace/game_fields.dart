import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:flutter/material.dart';

/// Single source of truth schema for Game kind fields.
abstract final class GameKindSchema {
  static final title = textField<GameWorkspaceDto>(
    id: 'game.title',
    label: 'Title',
    getValue: (dto) => dto.title,
  );

  static final publisher = textField<GameWorkspaceDto>(
    id: 'game.publisher',
    label: 'Publisher',
    getValue: (dto) => dto.publisher,
  );

  static final series = textField<GameWorkspaceDto>(
    id: 'game.series',
    label: 'Series',
    getValue: (dto) => dto.seriesTitle,
  );

  static final releaseDate = dateField<GameWorkspaceDto>(
    id: 'game.release_date',
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
  );

  static final condition = textField<GameWorkspaceDto>(
    id: 'game.condition',
    label: 'Condition',
    getValue: (dto) => dto.condition,
  );

  static final location = textField<GameWorkspaceDto>(
    id: 'game.location',
    label: 'Location',
    getValue: (dto) => dto.locationPath,
  );

  static final price = moneyField<GameWorkspaceDto>(
    id: 'game.price',
    label: 'Purchase Price',
    getValue: (dto) => dto.pricePaidCents,
  );

  static final barcode = textField<GameWorkspaceDto>(
    id: 'game.barcode',
    label: 'Barcode',
    getValue: (dto) => dto.barcode,
  );
}

final gameLibraryFieldDefinitions = [
  GameKindSchema.title,
  GameKindSchema.publisher,
  GameKindSchema.series,
  GameKindSchema.releaseDate,
  GameKindSchema.condition,
  GameKindSchema.location,
  GameKindSchema.price,
  GameKindSchema.barcode,
];

final gameLibraryGroupDefinitions = [
  groupFromField(
    GameKindSchema.publisher,
    sidebarTitle: 'Publishers',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
  ),
  groupFromField(
    GameKindSchema.series,
    sidebarTitle: 'Series',
    icon: Icons.collections_bookmark_outlined,
  ),
  groupFromField(
    GameKindSchema.location,
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
];

final gameLibrarySortDefinitions = [
  sortFromField(GameKindSchema.series),
  sortFromField(GameKindSchema.publisher),
  LibrarySortDefinition<GameWorkspaceDto>(
    id: const LibrarySortId('status'),
    compare: (left, right) {
      int rank(GameWorkspaceDto dto) {
        if (dto.isOwned) return 0;
        if (dto.isWishlisted) return 1;
        return 2;
      }

      final res = rank(left).compareTo(rank(right));
      return res != 0 ? res : left.title.compareTo(right.title);
    },
    label: 'Status',
  ),
  sortFromField(GameKindSchema.title),
  sortFromField(GameKindSchema.releaseDate, defaultAscending: false),
];

const gamesLibraryDefaultVisibleColumnIds = {
  'status',
  'cover',
  'game.title',
  'game.publisher',
  'game.release_date',
  'game.barcode',
  'rating',
  'game.condition',
  'game.price',
  'game.location',
  'wishlist',
  'updated',
};

final gameLibraryColumnDefinitions = [
  LibraryColumnDefinition<GameWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('status'),
    label: 'Status',
    getValue: (dto) =>
        dto.isWishlisted ? 'wishlist' : (dto.isOwned ? 'owned' : null),
    cellValue: (dto) =>
        Text(dto.isWishlisted ? 'Wishlist' : (dto.isOwned ? 'Owned' : '')),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<GameWorkspaceDto, Object?>(
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
  columnFromField(GameKindSchema.title, defaultWidth: 260, maxWidth: 520),
  columnFromField(GameKindSchema.publisher, defaultWidth: 160),
  columnFromField(
    GameKindSchema.releaseDate,
    cellValue: (dto) => Text(_formatDate(dto.releaseDate)),
    defaultWidth: 118,
  ),
  LibraryColumnDefinition<GameWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('wishlist'),
    label: 'Wishlist',
    getValue: (dto) => dto.isWishlisted,
    cellValue: (dto) => Text(dto.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<GameWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('updated'),
    label: 'Updated',
    getValue: (dto) => dto.updatedAt,
    cellValue: (dto) => Text(_formatDate(dto.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<GameWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('added'),
    label: 'Added',
    getValue: (dto) => dto.addedAt,
    cellValue: (dto) => Text(_formatDate(dto.addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  columnFromField(GameKindSchema.location,
      group: 'Personal', defaultWidth: 118),
  columnFromField(GameKindSchema.condition, group: 'Value', defaultWidth: 124),
  columnFromField(
    GameKindSchema.price,
    cellValue: (dto) => Text(_formatCents(dto.pricePaidCents, dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  columnFromField(GameKindSchema.barcode,
      group: 'Edition', defaultWidth: 160, maxWidth: 260),
  LibraryColumnDefinition<GameWorkspaceDto, Object?>(
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
