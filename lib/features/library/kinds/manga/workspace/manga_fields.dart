import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:flutter/material.dart';

/// Single source of truth schema for Manga kind fields.
abstract final class MangaKindSchema {
  static final title = textField<MangaWorkspaceDto>(
    id: 'manga.title',
    label: 'Title',
    getValue: (dto) => dto.title,
  );

  static final publisher = textField<MangaWorkspaceDto>(
    id: 'manga.publisher',
    label: 'Publisher',
    getValue: (dto) => dto.publisher,
  );

  static final series = textField<MangaWorkspaceDto>(
    id: 'manga.series',
    label: 'Series',
    getValue: (dto) => dto.seriesTitle,
  );

  static final volumeNumber = textField<MangaWorkspaceDto>(
    id: 'manga.number',
    label: 'Volume Number',
    getValue: (dto) => dto.itemNumber,
  );

  static final releaseDate = dateField<MangaWorkspaceDto>(
    id: 'manga.release_date',
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
  );

  static final condition = textField<MangaWorkspaceDto>(
    id: 'manga.condition',
    label: 'Condition',
    getValue: (dto) => dto.condition,
  );

  static final location = textField<MangaWorkspaceDto>(
    id: 'manga.location',
    label: 'Location',
    getValue: (dto) => dto.locationPath,
  );

  static final price = moneyField<MangaWorkspaceDto>(
    id: 'manga.price',
    label: 'Purchase Price',
    getValue: (dto) => dto.pricePaidCents,
  );

  static final barcode = textField<MangaWorkspaceDto>(
    id: 'manga.barcode',
    label: 'ISBN / Barcode',
    getValue: (dto) => dto.barcode,
  );
}

final mangaLibraryFieldDefinitions = [
  MangaKindSchema.title,
  MangaKindSchema.series,
  MangaKindSchema.volumeNumber,
  MangaKindSchema.publisher,
  MangaKindSchema.releaseDate,
  MangaKindSchema.condition,
  MangaKindSchema.location,
  MangaKindSchema.price,
  MangaKindSchema.barcode,
];

final mangaLibraryGroupDefinitions = [
  groupFromField(
    MangaKindSchema.series,
    sidebarTitle: 'Series',
    icon: Icons.collections_bookmark_outlined,
  ),
  groupFromField(
    MangaKindSchema.publisher,
    sidebarTitle: 'Publishers',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
  ),
  groupFromField(
    MangaKindSchema.location,
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
];

final mangaLibrarySortDefinitions = [
  sortFromField(MangaKindSchema.series),
  sortFromField(MangaKindSchema.volumeNumber),
  sortFromField(MangaKindSchema.publisher),
  LibrarySortDefinition<MangaWorkspaceDto>(
    id: const LibrarySortId('status'),
    compare: (left, right) {
      int rank(MangaWorkspaceDto dto) {
        if (dto.isOwned) return 0;
        if (dto.isWishlisted) return 1;
        return 2;
      }

      final res = rank(left).compareTo(rank(right));
      return res != 0 ? res : left.title.compareTo(right.title);
    },
    label: 'Status',
  ),
  sortFromField(MangaKindSchema.title),
  sortFromField(MangaKindSchema.releaseDate, defaultAscending: false),
];

const mangaLibraryDefaultVisibleColumnIds = {
  'status',
  'cover',
  'manga.series',
  'manga.title',
  'manga.publisher',
  'manga.release_date',
  'manga.barcode',
  'rating',
  'manga.condition',
  'manga.price',
  'manga.location',
  'wishlist',
  'updated',
};

final mangaLibraryColumnDefinitions = [
  LibraryColumnDefinition<MangaWorkspaceDto, Object?>(
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
  LibraryColumnDefinition<MangaWorkspaceDto, Object?>(
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
  columnFromField(MangaKindSchema.series, defaultWidth: 160),
  columnFromField(MangaKindSchema.title, defaultWidth: 260, maxWidth: 520),
  columnFromField(MangaKindSchema.publisher, defaultWidth: 140),
  columnFromField(
    MangaKindSchema.releaseDate,
    cellValue: (dto) => Text(_formatDate(dto.releaseDate)),
    defaultWidth: 118,
  ),
  LibraryColumnDefinition<MangaWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('wishlist'),
    label: 'Wishlist',
    getValue: (dto) => dto.isWishlisted,
    cellValue: (dto) => Text(dto.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<MangaWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('updated'),
    label: 'Updated',
    getValue: (dto) => dto.updatedAt,
    cellValue: (dto) => Text(_formatDate(dto.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<MangaWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('added'),
    label: 'Added',
    getValue: (dto) => dto.addedAt,
    cellValue: (dto) => Text(_formatDate(dto.addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  columnFromField(MangaKindSchema.location,
      group: 'Personal', defaultWidth: 118),
  columnFromField(MangaKindSchema.condition, group: 'Value', defaultWidth: 124),
  columnFromField(
    MangaKindSchema.price,
    cellValue: (dto) => Text(_formatCents(dto.pricePaidCents, dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  columnFromField(MangaKindSchema.barcode,
      group: 'Edition', defaultWidth: 160, maxWidth: 260),
  LibraryColumnDefinition<MangaWorkspaceDto, Object?>(
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
