import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:flutter/material.dart';

/// Single source of truth schema for TV kind fields.
abstract final class TvKindSchema {
  static final title = textField<TvWorkspaceDto>(
    id: 'tv.title',
    label: 'Title',
    getValue: (dto) => dto.title,
  );

  static final publisher = textField<TvWorkspaceDto>(
    id: 'tv.publisher',
    label: 'Network / Studio',
    getValue: (dto) => dto.publisher,
  );

  static final series = textField<TvWorkspaceDto>(
    id: 'tv.series',
    label: 'Series',
    getValue: (dto) => dto.seriesTitle,
  );

  static final releaseDate = dateField<TvWorkspaceDto>(
    id: 'tv.release_date',
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
  );

  static final condition = textField<TvWorkspaceDto>(
    id: 'tv.condition',
    label: 'Condition',
    getValue: (dto) => dto.condition,
  );

  static final location = textField<TvWorkspaceDto>(
    id: 'tv.location',
    label: 'Location',
    getValue: (dto) => dto.locationPath,
  );

  static final price = moneyField<TvWorkspaceDto>(
    id: 'tv.price',
    label: 'Purchase Price',
    getValue: (dto) => dto.pricePaidCents,
  );

  static final barcode = textField<TvWorkspaceDto>(
    id: 'tv.barcode',
    label: 'UPC / Barcode',
    getValue: (dto) => dto.barcode,
  );
}

final tvLibraryFieldDefinitions = [
  TvKindSchema.title,
  TvKindSchema.publisher,
  TvKindSchema.series,
  TvKindSchema.releaseDate,
  TvKindSchema.condition,
  TvKindSchema.location,
  TvKindSchema.price,
  TvKindSchema.barcode,
];

final tvLibraryGroupDefinitions = [
  groupFromField(
    TvKindSchema.publisher,
    sidebarTitle: 'Networks',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
  ),
  groupFromField(
    TvKindSchema.series,
    sidebarTitle: 'Series',
    icon: Icons.collections_bookmark_outlined,
  ),
  groupFromField(
    TvKindSchema.location,
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
];

final tvLibrarySortDefinitions = [
  sortFromField(TvKindSchema.series),
  sortFromField(TvKindSchema.publisher),
  LibrarySortDefinition<TvWorkspaceDto>(
    id: 'status',
    compare: (left, right) {
      int rank(TvWorkspaceDto dto) {
        if (dto.isOwned) return 0;
        if (dto.isWishlisted) return 1;
        return 2;
      }
      final res = rank(left).compareTo(rank(right));
      return res != 0 ? res : left.title.compareTo(right.title);
    },
    label: 'Status',
  ),
  sortFromField(TvKindSchema.title),
  sortFromField(TvKindSchema.releaseDate, defaultAscending: false),
];

const tvLibraryDefaultVisibleColumnIds = {
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

final tvLibraryColumnDefinitions = [
  LibraryColumnDefinition<TvWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('status'),
    label: 'Status',
    getValue: (dto) => dto.isWishlisted ? 'wishlist' : (dto.isOwned ? 'owned' : null),
    cellValue: (dto) => Text(dto.isWishlisted ? 'Wishlist' : (dto.isOwned ? 'Owned' : '')),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<TvWorkspaceDto, Object?>(
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
  columnFromField(TvKindSchema.title, defaultWidth: 260, maxWidth: 520),
  columnFromField(TvKindSchema.publisher, defaultWidth: 160),
  columnFromField(
    TvKindSchema.releaseDate,
    cellValue: (dto) => Text(_formatDate(dto.releaseDate)),
    defaultWidth: 118,
  ),
  LibraryColumnDefinition<TvWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('wishlist'),
    label: 'Wishlist',
    getValue: (dto) => dto.isWishlisted,
    cellValue: (dto) => Text(dto.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<TvWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('updated'),
    label: 'Updated',
    getValue: (dto) => dto.updatedAt,
    cellValue: (dto) => Text(_formatDate(dto.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<TvWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('added'),
    label: 'Added',
    getValue: (dto) => dto.addedAt,
    cellValue: (dto) => Text(_formatDate(dto.addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  columnFromField(TvKindSchema.location, group: 'Personal', defaultWidth: 118),
  columnFromField(TvKindSchema.condition, group: 'Value', defaultWidth: 124),
  columnFromField(
    TvKindSchema.price,
    cellValue: (dto) => Text(_formatCents(dto.pricePaidCents, dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  columnFromField(TvKindSchema.barcode, group: 'Edition', defaultWidth: 160, maxWidth: 260),
  LibraryColumnDefinition<TvWorkspaceDto, Object?>(
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
