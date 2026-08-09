import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_ids.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_kind_schema.dart';
import 'package:flutter/material.dart';

export 'package:collectarr_app/features/library/kinds/manga/workspace/manga_ids.dart';
export 'package:collectarr_app/features/library/kinds/manga/workspace/manga_preference_codec.dart';

/// Single source of truth schema for Manga kind fields.
abstract final class MangaKindSchema {
  static final title = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.title,
    label: 'Title',
    getValue: (dto) => dto.title,
  );

  static final publisher = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.publisher,
    label: 'Publisher',
    getValue: (dto) => dto.publisher,
  );

  static final series = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.series,
    label: 'Series',
    getValue: (dto) => dto.seriesTitle,
  );

  static final volumeNumber = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.volumeNumber,
    label: 'Volume Number',
    getValue: (dto) => dto.itemNumber,
  );

  static final releaseDate = dateField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.releaseDate,
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
  );

  static final condition =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.condition,
    label: 'Condition',
    getValue: (context) => context.source.ownedItem?.condition,
  );

  static final location =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.location,
    label: 'Location',
    getValue: (context) => context.source.locationPath,
  );

  static final pricePaid =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, int?>(
    id: MangaFieldIds.pricePaid,
    label: 'Purchase Price',
    getValue: (context) => context.source.ownedItem?.pricePaidCents,
  );

  static final barcode = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.barcode,
    label: 'ISBN / Barcode',
    getValue: (dto) => dto.barcode,
  );

  static final status =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.status,
    label: 'Status',
    getValue: (context) => context.source.isWishlisted
        ? 'wishlist'
        : (context.source.isOwned ? 'owned' : null),
  );

  static final cover =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.cover,
    label: 'Cover',
    getValue: (context) => context.dto.coverImageUrl,
  );

  static final rating =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, int?>(
    id: MangaFieldIds.rating,
    label: 'Rating',
    getValue: (context) => context.source.ownedItem?.rating,
  );

  static final wishlist =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, bool>(
    id: MangaFieldIds.wishlist,
    label: 'Wishlist',
    getValue: (context) => context.source.isWishlisted,
  );

  static final updatedAt =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, DateTime>(
    id: MangaFieldIds.updatedAt,
    label: 'Updated',
    getValue: (context) => context.source.updatedAt,
  );

  static final addedAt =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, DateTime?>(
    id: MangaFieldIds.addedAt,
    label: 'Added',
    getValue: (context) => context.source.addedAt,
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
  MangaKindSchema.pricePaid,
  MangaKindSchema.barcode,
];

final mangaLibraryGroupDefinitions = [
  groupFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaKindSchema.series,
    sidebarTitle: 'Series',
    icon: Icons.collections_bookmark_outlined,
  ),
  groupFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaKindSchema.publisher,
    sidebarTitle: 'Publishers',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
  ),
  groupFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaKindSchema.location,
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
];

final mangaLibrarySortDefinitions = [
  sortFromField<MangaKind, MangaWorkspaceDto, String>(MangaKindSchema.series),
  sortFromField<MangaKind, MangaWorkspaceDto, String>(
      MangaKindSchema.volumeNumber),
  sortFromField<MangaKind, MangaWorkspaceDto, String>(
      MangaKindSchema.publisher),
  LibrarySortDefinition<MangaKind, MangaWorkspaceDto>(
    id: MangaSortIds.status,
    compare: (left, right) {
      int rank(LibraryProjectionContext<MangaWorkspaceDto> ctx) {
        if (ctx.source.isOwned) return 0;
        if (ctx.source.isWishlisted) return 1;
        return 2;
      }

      final res = rank(left).compareTo(rank(right));
      return res != 0 ? res : left.dto.title.compareTo(right.dto.title);
    },
    label: 'Status',
  ),
  sortFromField<MangaKind, MangaWorkspaceDto, String>(MangaKindSchema.title),
  sortFromField<MangaKind, MangaWorkspaceDto, DateTime>(
      MangaKindSchema.releaseDate,
      defaultAscending: false),
];

final mangaLibraryDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  MangaFieldIds.status,
  MangaFieldIds.cover,
  MangaFieldIds.series,
  MangaFieldIds.title,
  MangaFieldIds.publisher,
  MangaFieldIds.releaseDate,
  MangaFieldIds.barcode,
  MangaFieldIds.rating,
  MangaFieldIds.condition,
  MangaFieldIds.pricePaid,
  MangaFieldIds.location,
  MangaFieldIds.wishlist,
  MangaFieldIds.updatedAt,
};

final mangaLibraryColumnDefinitions = [
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.status,
    label: 'Status',
    getValue: MangaKindSchema.status.getValue,
    cellValue: (context) => Text(context.source.isWishlisted
        ? 'Wishlist'
        : (context.source.isOwned ? 'Owned' : '')),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.cover,
    label: '',
    getValue: MangaKindSchema.cover.getValue,
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
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(MangaKindSchema.series,
      defaultWidth: 160),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(MangaKindSchema.title,
      defaultWidth: 260, maxWidth: 520),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
      MangaKindSchema.publisher,
      defaultWidth: 140),
  columnFromField<MangaKind, MangaWorkspaceDto, DateTime?>(
    MangaKindSchema.releaseDate,
    cellValue: (context) => Text(_formatDate(context.dto.releaseDate)),
    defaultWidth: 118,
  ),
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, bool>(
    id: MangaFieldIds.wishlist,
    label: 'Wishlist',
    getValue: MangaKindSchema.wishlist.getValue,
    cellValue: (context) => Text(context.source.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, DateTime>(
    id: MangaFieldIds.updatedAt,
    label: 'Updated',
    getValue: MangaKindSchema.updatedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, DateTime?>(
    id: MangaFieldIds.addedAt,
    label: 'Added',
    getValue: MangaKindSchema.addedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaKindSchema.location,
    group: 'Personal',
    defaultWidth: 118,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaKindSchema.condition,
    group: 'Value',
    defaultWidth: 124,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, int?>(
    MangaKindSchema.pricePaid,
    cellValue: (context) => Text(_formatCents(
        context.source.ownedItem?.pricePaidCents, context.dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaKindSchema.barcode,
    group: 'Edition',
    defaultWidth: 160,
    maxWidth: 260,
  ),
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, int?>(
    id: MangaFieldIds.rating,
    label: 'Rating',
    getValue: MangaKindSchema.rating.getValue,
    cellValue: (context) =>
        Text(context.source.ownedItem?.rating?.toString() ?? ''),
    defaultWidth: 80,
  ),
];

final mangaLibraryKindSchema = LibraryKindSchema<MangaKind, MangaWorkspaceDto>(
  kindNamespace: 'manga',
  fields: mangaLibraryFieldDefinitions,
  columns: mangaLibraryColumnDefinitions,
  sorts: mangaLibrarySortDefinitions,
  groups: mangaLibraryGroupDefinitions,
  defaultVisibleColumns: mangaLibraryDefaultVisibleColumns,
  defaultSort: MangaSortIds.series,
  defaultGroup: MangaGroupIds.series,
  preferenceCodec: const MangaPreferenceCodec(),
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
