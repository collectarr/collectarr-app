import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_ids.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_kind_schema.dart';
import 'package:flutter/material.dart';

export 'package:collectarr_app/features/library/kinds/anime/workspace/anime_ids.dart';
export 'package:collectarr_app/features/library/kinds/anime/workspace/anime_preference_codec.dart';

/// Single source of truth schema for Anime kind fields.
abstract final class AnimeKindSchema {
  static final title = textField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.title,
    label: 'Title',
    getValue: (dto) => dto.title,
  );

  static final studio = textField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.studio,
    label: 'Studio',
    getValue: (dto) => dto.creator,
  );

  static final publisher = textField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.publisher,
    label: 'Publisher',
    getValue: (dto) => dto.publisher,
  );

  static final releaseDate = dateField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.releaseDate,
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
  );

  static final condition =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, String?>(
    id: AnimeFieldIds.condition,
    label: 'Condition',
    getValue: (context) => context.source.ownedItem?.condition,
  );

  static final location =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, String?>(
    id: AnimeFieldIds.location,
    label: 'Location',
    getValue: (context) => context.source.locationPath,
  );

  static final pricePaid =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, int?>(
    id: AnimeFieldIds.pricePaid,
    label: 'Purchase Price',
    getValue: (context) => context.source.ownedItem?.pricePaidCents,
  );

  static final barcode = textField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.barcode,
    label: 'UPC / Barcode',
    getValue: (dto) => dto.barcode,
  );

  static final status =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, String?>(
    id: AnimeFieldIds.status,
    label: 'Status',
    getValue: (context) => context.source.isWishlisted
        ? 'wishlist'
        : (context.source.isOwned ? 'owned' : null),
  );

  static final cover =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, String?>(
    id: AnimeFieldIds.cover,
    label: 'Cover',
    getValue: (context) => context.dto.coverImageUrl,
  );

  static final rating =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, int?>(
    id: AnimeFieldIds.rating,
    label: 'Rating',
    getValue: (context) => context.source.ownedItem?.rating,
  );

  static final wishlist =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, bool>(
    id: AnimeFieldIds.wishlist,
    label: 'Wishlist',
    getValue: (context) => context.source.isWishlisted,
  );

  static final updatedAt =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, DateTime>(
    id: AnimeFieldIds.updatedAt,
    label: 'Updated',
    getValue: (context) => context.source.updatedAt,
  );

  static final addedAt =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, DateTime?>(
    id: AnimeFieldIds.addedAt,
    label: 'Added',
    getValue: (context) => context.source.addedAt,
  );

  static final watchStatus =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, String?>(
    id: AnimeFieldIds.watchStatus,
    label: 'Watch Status',
    getValue: (context) => context.source.ownedItem?.readStatus,
  );
}

final animeLibraryFieldDefinitions = [
  AnimeKindSchema.title,
  AnimeKindSchema.studio,
  AnimeKindSchema.publisher,
  AnimeKindSchema.releaseDate,
  AnimeKindSchema.condition,
  AnimeKindSchema.location,
  AnimeKindSchema.pricePaid,
  AnimeKindSchema.barcode,
];

final animeLibraryGroupDefinitions = [
  groupFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeKindSchema.studio,
    sidebarTitle: 'Studios',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
  ),
  groupFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeKindSchema.location,
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
];

final animeLibrarySortDefinitions = [
  sortFromField<AnimeKind, AnimeWorkspaceDto, String>(AnimeKindSchema.studio),
  sortFromField<AnimeKind, AnimeWorkspaceDto, String>(
      AnimeKindSchema.publisher),
  LibrarySortDefinition<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeSortIds.status,
    compare: (left, right) {
      int rank(LibraryProjectionContext<AnimeWorkspaceDto> ctx) {
        if (ctx.source.isOwned) return 0;
        if (ctx.source.isWishlisted) return 1;
        return 2;
      }

      final res = rank(left).compareTo(rank(right));
      return res != 0 ? res : left.dto.title.compareTo(right.dto.title);
    },
    label: 'Status',
  ),
  sortFromField<AnimeKind, AnimeWorkspaceDto, String>(AnimeKindSchema.title),
  sortFromField<AnimeKind, AnimeWorkspaceDto, DateTime>(
      AnimeKindSchema.releaseDate,
      defaultAscending: false),
];

final animeLibraryDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  AnimeFieldIds.status,
  AnimeFieldIds.cover,
  AnimeFieldIds.studio,
  AnimeFieldIds.title,
  AnimeFieldIds.publisher,
  AnimeFieldIds.releaseDate,
  AnimeFieldIds.barcode,
  AnimeFieldIds.rating,
  AnimeFieldIds.condition,
  AnimeFieldIds.pricePaid,
  AnimeFieldIds.location,
  AnimeFieldIds.wishlist,
  AnimeFieldIds.updatedAt,
};

final animeLibraryColumnDefinitions = [
  LibraryColumnDefinition<AnimeKind, AnimeWorkspaceDto, String?>(
    id: AnimeFieldIds.status,
    label: 'Status',
    getValue: AnimeKindSchema.status.getValue,
    cellValue: (context) => Text(context.source.isWishlisted
        ? 'Wishlist'
        : (context.source.isOwned ? 'Owned' : '')),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<AnimeKind, AnimeWorkspaceDto, String?>(
    id: AnimeFieldIds.cover,
    label: '',
    getValue: AnimeKindSchema.cover.getValue,
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
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(AnimeKindSchema.studio,
      defaultWidth: 150),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(AnimeKindSchema.title,
      defaultWidth: 260, maxWidth: 520),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
      AnimeKindSchema.publisher,
      defaultWidth: 140),
  columnFromField<AnimeKind, AnimeWorkspaceDto, DateTime?>(
    AnimeKindSchema.releaseDate,
    cellValue: (context) => Text(_formatDate(context.dto.releaseDate)),
    defaultWidth: 118,
  ),
  LibraryColumnDefinition<AnimeKind, AnimeWorkspaceDto, bool>(
    id: AnimeFieldIds.wishlist,
    label: 'Wishlist',
    getValue: AnimeKindSchema.wishlist.getValue,
    cellValue: (context) => Text(context.source.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<AnimeKind, AnimeWorkspaceDto, DateTime>(
    id: AnimeFieldIds.updatedAt,
    label: 'Updated',
    getValue: AnimeKindSchema.updatedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<AnimeKind, AnimeWorkspaceDto, DateTime?>(
    id: AnimeFieldIds.addedAt,
    label: 'Added',
    getValue: AnimeKindSchema.addedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeKindSchema.location,
    group: 'Personal',
    defaultWidth: 118,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeKindSchema.condition,
    group: 'Value',
    defaultWidth: 124,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, int?>(
    AnimeKindSchema.pricePaid,
    cellValue: (context) => Text(_formatCents(
        context.source.ownedItem?.pricePaidCents, context.dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeKindSchema.barcode,
    group: 'Edition',
    defaultWidth: 160,
    maxWidth: 260,
  ),
  LibraryColumnDefinition<AnimeKind, AnimeWorkspaceDto, int?>(
    id: AnimeFieldIds.rating,
    label: 'Rating',
    getValue: AnimeKindSchema.rating.getValue,
    cellValue: (context) =>
        Text(context.source.ownedItem?.rating?.toString() ?? ''),
    defaultWidth: 80,
  ),
];

final animeLibraryKindSchema = LibraryKindSchema<AnimeKind, AnimeWorkspaceDto>(
  kindNamespace: 'anime',
  fields: animeLibraryFieldDefinitions,
  columns: animeLibraryColumnDefinitions,
  sorts: animeLibrarySortDefinitions,
  groups: animeLibraryGroupDefinitions,
  defaultVisibleColumns: animeLibraryDefaultVisibleColumns,
  defaultSort: AnimeSortIds.studio,
  defaultGroup: AnimeGroupIds.studio,
  preferenceCodec: const AnimePreferenceCodec(),
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
