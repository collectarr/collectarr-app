import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:flutter/material.dart';

/// Single source of truth schema for Music kind fields.
abstract final class MusicKindSchema {
  static final title = textField<MusicWorkspaceDto>(
    id: 'music.title',
    label: 'Title',
    getValue: (dto) => dto.title,
  );

  static final artist = textField<MusicWorkspaceDto>(
    id: 'music.artist',
    label: 'Artist',
    getValue: (dto) => dto.artist,
  );

  static final publisher = textField<MusicWorkspaceDto>(
    id: 'music.publisher',
    label: 'Label',
    getValue: (dto) => dto.publisher,
  );

  static final releaseDate = dateField<MusicWorkspaceDto>(
    id: 'music.release_date',
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
  );

  static final trackCount = numberField<MusicWorkspaceDto>(
    id: 'music.track_count',
    label: 'Track count',
    getValue: (dto) => dto.trackCount,
  );

  static final barcode = textField<MusicWorkspaceDto>(
    id: 'music.barcode',
    label: 'Barcode',
    getValue: (dto) => dto.barcode,
  );

  static final condition = textField<MusicWorkspaceDto>(
    id: 'music.condition',
    label: 'Condition',
    getValue: (dto) => dto.condition,
  );

  static final location = textField<MusicWorkspaceDto>(
    id: 'music.location',
    label: 'Location',
    getValue: (dto) => dto.locationPath,
  );

  static final price = moneyField<MusicWorkspaceDto>(
    id: 'music.price',
    label: 'Purchase Price',
    getValue: (dto) => dto.pricePaidCents,
  );
}

final musicLibraryFieldDefinitions = [
  MusicKindSchema.title,
  MusicKindSchema.artist,
  MusicKindSchema.publisher,
  MusicKindSchema.releaseDate,
  MusicKindSchema.trackCount,
  MusicKindSchema.barcode,
  MusicKindSchema.condition,
  MusicKindSchema.location,
  MusicKindSchema.price,
];

final musicLibraryGroupDefinitions = [
  groupFromField(
    MusicKindSchema.artist,
    sidebarTitle: 'Artists',
    icon: Icons.person_outline,
    supportsBucketManagement: true,
  ),
  groupFromField(
    MusicKindSchema.publisher,
    sidebarTitle: 'Labels',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
  ),
  groupFromField(
    MusicKindSchema.condition,
    sidebarTitle: 'Conditions',
    icon: Icons.verified_outlined,
    supportsBucketManagement: true,
  ),
  groupFromField(
    MusicKindSchema.location,
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
];

final musicLibrarySortDefinitions = [
  sortFromField(MusicKindSchema.artist),
  sortFromField(MusicKindSchema.publisher),
  LibrarySortDefinition<MusicWorkspaceDto>(
    id: const LibrarySortId('status'),
    compare: (left, right) {
      int rank(MusicWorkspaceDto dto) {
        if (dto.isOwned) return 0;
        if (dto.isWishlisted) return 1;
        return 2;
      }
      final res = rank(left).compareTo(rank(right));
      return res != 0 ? res : left.title.compareTo(right.title);
    },
    label: 'Status',
  ),
  sortFromField(MusicKindSchema.title),
  sortFromField(MusicKindSchema.releaseDate, defaultAscending: false),
  sortFromField(MusicKindSchema.trackCount),
];

const musicLibraryDefaultVisibleColumnIds = {
  'status',
  'cover',
  'artist',
  'title',
  'publisher',
  'release_date',
  'barcode',
  'track_count',
  'rating',
  'condition',
  'price',
  'location',
  'wishlist',
  'updated',
};

final musicLibraryColumnDefinitions = [
  LibraryColumnDefinition<MusicWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('status'),
    label: 'Status',
    getValue: (dto) => dto.isWishlisted ? 'wishlist' : (dto.isOwned ? 'owned' : null),
    cellValue: (dto) => Text(dto.isWishlisted ? 'Wishlist' : (dto.isOwned ? 'Owned' : '')),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<MusicWorkspaceDto, Object?>(
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
  columnFromField(MusicKindSchema.artist, defaultWidth: 160),
  columnFromField(MusicKindSchema.title, defaultWidth: 260, maxWidth: 520),
  columnFromField(MusicKindSchema.publisher, defaultWidth: 140),
  columnFromField(
    MusicKindSchema.releaseDate,
    cellValue: (dto) => Text(_formatDate(dto.releaseDate)),
    defaultWidth: 118,
  ),
  LibraryColumnDefinition<MusicWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('wishlist'),
    label: 'Wishlist',
    getValue: (dto) => dto.isWishlisted,
    cellValue: (dto) => Text(dto.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<MusicWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('updated'),
    label: 'Updated',
    getValue: (dto) => dto.updatedAt,
    cellValue: (dto) => Text(_formatDate(dto.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<MusicWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('added'),
    label: 'Added',
    getValue: (dto) => dto.addedAt,
    cellValue: (dto) => Text(_formatDate(dto.addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  columnFromField(MusicKindSchema.location, group: 'Personal', defaultWidth: 118),
  columnFromField(MusicKindSchema.condition, group: 'Value', defaultWidth: 124),
  columnFromField(
    MusicKindSchema.price,
    cellValue: (dto) => Text(_formatCents(dto.pricePaidCents, dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  columnFromField(MusicKindSchema.barcode, group: 'Edition', defaultWidth: 160, maxWidth: 260),
  columnFromField(MusicKindSchema.trackCount, defaultWidth: 90, isNumeric: true),
  LibraryColumnDefinition<MusicWorkspaceDto, Object?>(
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
