import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:flutter/material.dart';

/// Single source of truth schema for Comic kind fields.
abstract final class ComicKindSchema {
  static final title = textField<ComicWorkspaceDto>(
    id: 'comic.title',
    label: 'Title',
    getValue: (dto) => dto.title,
  );

  static final publisher = textField<ComicWorkspaceDto>(
    id: 'comic.publisher',
    label: 'Publisher',
    getValue: (dto) => dto.publisher,
  );

  static final series = textField<ComicWorkspaceDto>(
    id: 'comic.series',
    label: 'Series',
    getValue: (dto) => dto.seriesTitle,
  );

  static final issueNumber = textField<ComicWorkspaceDto>(
    id: 'comic.number',
    label: 'Issue Number',
    getValue: (dto) => dto.itemNumber,
  );

  static final releaseDate = dateField<ComicWorkspaceDto>(
    id: 'comic.release_date',
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
  );

  static final condition = textField<ComicWorkspaceDto>(
    id: 'comic.condition',
    label: 'Condition',
    getValue: (dto) => dto.condition,
  );

  static final location = textField<ComicWorkspaceDto>(
    id: 'comic.location',
    label: 'Location',
    getValue: (dto) => dto.locationPath,
  );

  static final price = moneyField<ComicWorkspaceDto>(
    id: 'comic.price',
    label: 'Purchase Price',
    getValue: (dto) => dto.pricePaidCents,
  );

  static final barcode = textField<ComicWorkspaceDto>(
    id: 'comic.barcode',
    label: 'Barcode',
    getValue: (dto) => dto.barcode,
  );
}

final comicLibraryFieldDefinitions = [
  ComicKindSchema.title,
  ComicKindSchema.series,
  ComicKindSchema.issueNumber,
  ComicKindSchema.publisher,
  ComicKindSchema.releaseDate,
  ComicKindSchema.condition,
  ComicKindSchema.location,
  ComicKindSchema.price,
  ComicKindSchema.barcode,
];

final comicLibraryGroupDefinitions = [
  groupFromField(
    ComicKindSchema.series,
    sidebarTitle: 'Series',
    icon: Icons.collections_bookmark_outlined,
  ),
  groupFromField(
    ComicKindSchema.publisher,
    sidebarTitle: 'Publishers',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
  ),
  groupFromField(
    ComicKindSchema.location,
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
];

final comicLibrarySortDefinitions = [
  sortFromField(ComicKindSchema.series),
  sortFromField(ComicKindSchema.issueNumber),
  sortFromField(ComicKindSchema.publisher),
  LibrarySortDefinition<ComicWorkspaceDto>(
    id: const LibrarySortId('status'),
    compare: (left, right) {
      int rank(ComicWorkspaceDto dto) {
        if (dto.isOwned) return 0;
        if (dto.isWishlisted) return 1;
        return 2;
      }
      final res = rank(left).compareTo(rank(right));
      return res != 0 ? res : left.title.compareTo(right.title);
    },
    label: 'Status',
  ),
  sortFromField(ComicKindSchema.title),
  sortFromField(ComicKindSchema.releaseDate, defaultAscending: false),
];

const comicLibraryDefaultVisibleColumnIds = {
  'status',
  'cover',
  'series',
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

final comicLibraryColumnDefinitions = [
  LibraryColumnDefinition<ComicWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('status'),
    label: 'Status',
    getValue: (dto) => dto.isWishlisted ? 'wishlist' : (dto.isOwned ? 'owned' : null),
    cellValue: (dto) => Text(dto.isWishlisted ? 'Wishlist' : (dto.isOwned ? 'Owned' : '')),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<ComicWorkspaceDto, Object?>(
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
  columnFromField(ComicKindSchema.series, defaultWidth: 160),
  columnFromField(ComicKindSchema.title, defaultWidth: 260, maxWidth: 520),
  columnFromField(ComicKindSchema.publisher, defaultWidth: 140),
  columnFromField(
    ComicKindSchema.releaseDate,
    cellValue: (dto) => Text(_formatDate(dto.releaseDate)),
    defaultWidth: 118,
  ),
  LibraryColumnDefinition<ComicWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('wishlist'),
    label: 'Wishlist',
    getValue: (dto) => dto.isWishlisted,
    cellValue: (dto) => Text(dto.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<ComicWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('updated'),
    label: 'Updated',
    getValue: (dto) => dto.updatedAt,
    cellValue: (dto) => Text(_formatDate(dto.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<ComicWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('added'),
    label: 'Added',
    getValue: (dto) => dto.addedAt,
    cellValue: (dto) => Text(_formatDate(dto.addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  columnFromField(ComicKindSchema.location, group: 'Personal', defaultWidth: 118),
  columnFromField(ComicKindSchema.condition, group: 'Value', defaultWidth: 124),
  columnFromField(
    ComicKindSchema.price,
    cellValue: (dto) => Text(_formatCents(dto.pricePaidCents, dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  columnFromField(ComicKindSchema.barcode, group: 'Edition', defaultWidth: 160, maxWidth: 260),
  LibraryColumnDefinition<ComicWorkspaceDto, Object?>(
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
