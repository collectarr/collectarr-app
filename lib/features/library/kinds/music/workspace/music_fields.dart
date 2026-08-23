import 'package:collectarr_app/features/library/kinds/music/workspace/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_kind_schema.dart';
import 'package:flutter/material.dart';

export 'package:collectarr_app/features/library/kinds/music/workspace/music_ids.dart';
export 'package:collectarr_app/features/library/kinds/music/workspace/music_preference_codec.dart';

/// Single source of truth schema for Music kind fields.
abstract final class MusicKindSchema {
  static final title = textField<MusicKind, MusicWorkspaceDto>(
    id: MusicFieldIds.title,
    label: 'Title',
    getValue: (dto) => dto.title,
  );

  static final artist = textField<MusicKind, MusicWorkspaceDto>(
    id: MusicFieldIds.artist,
    label: 'Artist',
    getValue: (dto) => dto.music.work.artist,
  );

  static final publisher = textField<MusicKind, MusicWorkspaceDto>(
    id: MusicFieldIds.publisher,
    label: 'Label',
    getValue: (dto) => dto.publisher,
  );

  static final releaseDate = dateField<MusicKind, MusicWorkspaceDto>(
    id: MusicFieldIds.releaseDate,
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
  );

  static final trackCount = numberField<MusicKind, MusicWorkspaceDto>(
    id: MusicFieldIds.trackCount,
    label: 'Track count',
    getValue: (dto) => dto.music.recording.trackCount,
  );

  static final barcode = textField<MusicKind, MusicWorkspaceDto>(
    id: MusicFieldIds.barcode,
    label: 'Barcode',
    getValue: (dto) => dto.barcode,
    scope: LibraryFieldScope.release,
  );

  static final condition =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceDto, String?>(
    id: MusicFieldIds.condition,
    label: 'Condition',
    getValue: (context) => context.source.ownedItem?.condition,
    scope: LibraryFieldScope.copy,
  );

  static final location =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceDto, String?>(
    id: MusicFieldIds.location,
    label: 'Location',
    getValue: (context) => context.source.locationPath,
    scope: LibraryFieldScope.copy,
  );

  static final pricePaid =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceDto, int?>(
    id: MusicFieldIds.pricePaid,
    label: 'Purchase Price',
    getValue: (context) => context.source.ownedItem?.pricePaidCents,
    scope: LibraryFieldScope.copy,
  );

  static final status =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceDto, String?>(
    id: MusicFieldIds.status,
    label: 'Status',
    getValue: (context) => context.source.isWishlisted
        ? 'wishlist'
        : (context.source.isOwned ? 'owned' : null),
    scope: LibraryFieldScope.copy,
  );

  static final cover =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceDto, String?>(
    id: MusicFieldIds.cover,
    label: 'Cover',
    getValue: (context) => context.dto.coverImageUrl,
    scope: LibraryFieldScope.media,
  );

  static final rating =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceDto, int?>(
    id: MusicFieldIds.rating,
    label: 'Rating',
    getValue: (context) => context.source.ownedItem?.rating,
    scope: LibraryFieldScope.copy,
  );

  static final wishlist =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceDto, bool>(
    id: MusicFieldIds.wishlist,
    label: 'Wishlist',
    getValue: (context) => context.source.isWishlisted,
    scope: LibraryFieldScope.copy,
  );

  static final updatedAt =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceDto, DateTime>(
    id: MusicFieldIds.updatedAt,
    label: 'Updated',
    getValue: (context) => context.source.updatedAt,
    scope: LibraryFieldScope.copy,
  );

  static final addedAt =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceDto, DateTime?>(
    id: MusicFieldIds.addedAt,
    label: 'Added',
    getValue: (context) => context.source.addedAt,
    scope: LibraryFieldScope.copy,
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
  MusicKindSchema.pricePaid,
];

final musicLibraryGroupDefinitions = [
  groupFromField<MusicKind, MusicWorkspaceDto, String?>(
    MusicKindSchema.artist,
    sidebarTitle: 'Artists',
    icon: Icons.person_outline,
    supportsBucketManagement: true,
  ),
  groupFromField<MusicKind, MusicWorkspaceDto, String?>(
    MusicKindSchema.publisher,
    sidebarTitle: 'Labels',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
  ),
  groupFromField<MusicKind, MusicWorkspaceDto, String?>(
    MusicKindSchema.condition,
    sidebarTitle: 'Conditions',
    icon: Icons.verified_outlined,
    supportsBucketManagement: true,
  ),
  groupFromField<MusicKind, MusicWorkspaceDto, String?>(
    MusicKindSchema.location,
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
];

final musicLibrarySortDefinitions = [
  sortFromField<MusicKind, MusicWorkspaceDto, String>(MusicKindSchema.artist),
  sortFromField<MusicKind, MusicWorkspaceDto, String>(
      MusicKindSchema.publisher),
  LibrarySortDefinition<MusicKind, MusicWorkspaceDto>(
    id: MusicSortIds.status,
    compare: (left, right) {
      int rank(LibraryProjectionContext<MusicWorkspaceDto> ctx) {
        if (ctx.source.isOwned) return 0;
        if (ctx.source.isWishlisted) return 1;
        return 2;
      }

      final res = rank(left).compareTo(rank(right));
      return res != 0 ? res : left.dto.title.compareTo(right.dto.title);
    },
    label: 'Status',
  ),
  sortFromField<MusicKind, MusicWorkspaceDto, String>(MusicKindSchema.title),
  sortFromField<MusicKind, MusicWorkspaceDto, DateTime>(
      MusicKindSchema.releaseDate,
      defaultAscending: false),
];

final musicLibraryDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  MusicFieldIds.status,
  MusicFieldIds.cover,
  MusicFieldIds.artist,
  MusicFieldIds.title,
  MusicFieldIds.publisher,
  MusicFieldIds.releaseDate,
  MusicFieldIds.trackCount,
  MusicFieldIds.barcode,
  MusicFieldIds.rating,
  MusicFieldIds.condition,
  MusicFieldIds.pricePaid,
  MusicFieldIds.location,
  MusicFieldIds.wishlist,
  MusicFieldIds.updatedAt,
};

final musicLibraryColumnDefinitions = [
  LibraryColumnDefinition<MusicKind, MusicWorkspaceDto, String?>(
    id: MusicFieldIds.status,
    label: 'Status',
    getValue: MusicKindSchema.status.getValue,
    cellValue: (context) => Text(context.source.isWishlisted
        ? 'Wishlist'
        : (context.source.isOwned ? 'Owned' : '')),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<MusicKind, MusicWorkspaceDto, String?>(
    id: MusicFieldIds.cover,
    label: '',
    getValue: MusicKindSchema.cover.getValue,
    cellValue: (context) => context.dto.coverImageUrl == null
        ? const SizedBox.shrink()
        : Image.network(
            context.dto.coverImageUrl!,
            width: 32,
            height: 32,
            fit: BoxFit.cover,
          ),
    sortable: false,
    groupable: false,
    defaultWidth: 42,
    minWidth: 44,
  ),
  columnFromField<MusicKind, MusicWorkspaceDto, String?>(MusicKindSchema.artist,
      defaultWidth: 160),
  columnFromField<MusicKind, MusicWorkspaceDto, String?>(MusicKindSchema.title,
      defaultWidth: 260, maxWidth: 520),
  columnFromField<MusicKind, MusicWorkspaceDto, String?>(
      MusicKindSchema.publisher,
      defaultWidth: 140),
  columnFromField<MusicKind, MusicWorkspaceDto, DateTime?>(
    MusicKindSchema.releaseDate,
    cellValue: (context) => Text(_formatDate(context.dto.releaseDate)),
    defaultWidth: 118,
  ),
  columnFromField<MusicKind, MusicWorkspaceDto, num?>(
    MusicKindSchema.trackCount,
    defaultWidth: 90,
  ),
  LibraryColumnDefinition<MusicKind, MusicWorkspaceDto, bool>(
    id: MusicFieldIds.wishlist,
    label: 'Wishlist',
    getValue: MusicKindSchema.wishlist.getValue,
    cellValue: (context) => Text(context.source.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<MusicKind, MusicWorkspaceDto, DateTime>(
    id: MusicFieldIds.updatedAt,
    label: 'Updated',
    getValue: MusicKindSchema.updatedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<MusicKind, MusicWorkspaceDto, DateTime?>(
    id: MusicFieldIds.addedAt,
    label: 'Added',
    getValue: MusicKindSchema.addedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  columnFromField<MusicKind, MusicWorkspaceDto, String?>(
    MusicKindSchema.location,
    group: 'Personal',
    defaultWidth: 118,
  ),
  columnFromField<MusicKind, MusicWorkspaceDto, String?>(
    MusicKindSchema.condition,
    group: 'Value',
    defaultWidth: 124,
  ),
  columnFromField<MusicKind, MusicWorkspaceDto, int?>(
    MusicKindSchema.pricePaid,
    cellValue: (context) => Text(_formatCents(
        context.source.ownedItem?.pricePaidCents, context.dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  columnFromField<MusicKind, MusicWorkspaceDto, String?>(
    MusicKindSchema.barcode,
    group: 'Edition',
    defaultWidth: 160,
    maxWidth: 260,
  ),
  LibraryColumnDefinition<MusicKind, MusicWorkspaceDto, int?>(
    id: MusicFieldIds.rating,
    label: 'Rating',
    getValue: MusicKindSchema.rating.getValue,
    cellValue: (context) =>
        Text(context.source.ownedItem?.rating?.toString() ?? ''),
    defaultWidth: 80,
  ),
];

final musicLibraryKindSchema = LibraryKindSchema<MusicKind, MusicWorkspaceDto>(
  kindNamespace: 'music',
  fields: musicLibraryFieldDefinitions,
  columns: musicLibraryColumnDefinitions,
  sorts: musicLibrarySortDefinitions,
  groups: musicLibraryGroupDefinitions,
  defaultVisibleColumns: musicLibraryDefaultVisibleColumns,
  defaultSort: MusicSortIds.artist,
  defaultGroup: MusicGroupIds.artist,
  preferenceCodec: const MusicPreferenceCodec(),
);

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
