import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_kind_schema.dart';
import 'package:flutter/material.dart';

export 'package:collectarr_app/features/library/kinds/comic/workspace/comic_ids.dart';
export 'package:collectarr_app/features/library/kinds/comic/workspace/comic_preference_codec.dart';

/// Single source of truth schema for Comic kind fields.
abstract final class ComicKindSchema {
  static final title = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.title,
    label: 'Title',
    getValue: (dto) => dto.title,
  );

  static final publisher = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.publisher,
    label: 'Publisher',
    getValue: (dto) => dto.publisher,
  );

  static final series = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.series,
    label: 'Series',
    getValue: (dto) => dto.seriesTitle,
  );

  static final issueNumber = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.issueNumber,
    label: 'Issue Number',
    getValue: (dto) => dto.itemNumber,
  );

  static final releaseDate = dateField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.releaseDate,
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
  );

  static final condition =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.condition,
    label: 'Condition',
    getValue: (context) => context.source.ownedItem?.condition,
  );

  static final location =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.location,
    label: 'Location',
    getValue: (context) => context.source.locationPath,
  );

  static final pricePaid =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, int?>(
    id: ComicFieldIds.pricePaid,
    label: 'Purchase Price',
    getValue: (context) => context.source.ownedItem?.pricePaidCents,
  );

  static final barcode = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.barcode,
    label: 'Barcode',
    getValue: (dto) => dto.barcode,
  );

  static final status =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.status,
    label: 'Status',
    getValue: (context) => context.source.isWishlisted
        ? 'wishlist'
        : (context.source.isOwned ? 'owned' : null),
  );

  static final cover =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.cover,
    label: 'Cover',
    getValue: (context) => context.dto.coverImageUrl,
  );

  static final rating =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, int?>(
    id: ComicFieldIds.rating,
    label: 'Rating',
    getValue: (context) => context.source.ownedItem?.rating,
  );

  static final wishlist =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, bool>(
    id: ComicFieldIds.wishlist,
    label: 'Wishlist',
    getValue: (context) => context.source.isWishlisted,
  );

  static final updatedAt =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, DateTime>(
    id: ComicFieldIds.updatedAt,
    label: 'Updated',
    getValue: (context) => context.source.updatedAt,
  );

  static final addedAt =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, DateTime?>(
    id: ComicFieldIds.addedAt,
    label: 'Added',
    getValue: (context) => context.source.addedAt,
  );

  static final grade =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.grade,
    label: 'Grade',
    getValue: (context) => context.source.ownedItem?.grade,
  );

  static final keyComic =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, bool>(
    id: ComicFieldIds.keyComic,
    label: 'Key Comic',
    getValue: (context) =>
        context.source.ownedItem?.comicDetails?.keyComic == true,
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
  ComicKindSchema.pricePaid,
  ComicKindSchema.barcode,
  ComicKindSchema.grade,
  ComicKindSchema.keyComic,
];

final comicLibraryGroupDefinitions = [
  groupFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicKindSchema.series,
    sidebarTitle: 'Series',
    category: 'Main',
    icon: Icons.collections_bookmark_outlined,
  ),
  groupFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicKindSchema.publisher,
    sidebarTitle: 'Publishers',
    category: 'Main',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
  ),
  groupFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicKindSchema.location,
    sidebarTitle: 'Locations',
    category: 'Personal',
    icon: Icons.place_outlined,
  ),
];

final comicLibrarySortDefinitions = [
  sortFromField<ComicKind, ComicWorkspaceDto, String>(ComicKindSchema.series),
  sortFromField<ComicKind, ComicWorkspaceDto, String>(
      ComicKindSchema.issueNumber),
  sortFromField<ComicKind, ComicWorkspaceDto, String>(
      ComicKindSchema.publisher),
  LibrarySortDefinition<ComicKind, ComicWorkspaceDto>(
    id: ComicSortIds.status,
    compare: (left, right) {
      int rank(LibraryProjectionContext<ComicWorkspaceDto> ctx) {
        if (ctx.source.isOwned) return 0;
        if (ctx.source.isWishlisted) return 1;
        return 2;
      }

      final res = rank(left).compareTo(rank(right));
      return res != 0 ? res : left.dto.title.compareTo(right.dto.title);
    },
    label: 'Status',
  ),
  sortFromField<ComicKind, ComicWorkspaceDto, String>(ComicKindSchema.title),
  sortFromField<ComicKind, ComicWorkspaceDto, DateTime>(
      ComicKindSchema.releaseDate,
      defaultAscending: false),
];

final comicLibraryDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  ComicFieldIds.status,
  ComicFieldIds.cover,
  ComicFieldIds.series,
  ComicFieldIds.title,
  ComicFieldIds.publisher,
  ComicFieldIds.releaseDate,
  ComicFieldIds.barcode,
  ComicFieldIds.rating,
  ComicFieldIds.condition,
  ComicFieldIds.pricePaid,
  ComicFieldIds.location,
  ComicFieldIds.wishlist,
  ComicFieldIds.updatedAt,
};

final comicLibraryColumnDefinitions = [
  LibraryColumnDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.status,
    label: 'Status',
    getValue: ComicKindSchema.status.getValue,
    cellValue: (context) => Text(context.source.isWishlisted
        ? 'Wishlist'
        : (context.source.isOwned ? 'Owned' : '')),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.cover,
    label: '',
    getValue: ComicKindSchema.cover.getValue,
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
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(ComicKindSchema.series,
      defaultWidth: 160),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(ComicKindSchema.title,
      defaultWidth: 260, maxWidth: 520),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
      ComicKindSchema.publisher,
      defaultWidth: 140),
  columnFromField<ComicKind, ComicWorkspaceDto, DateTime?>(
    ComicKindSchema.releaseDate,
    cellValue: (context) => Text(_formatDate(context.dto.releaseDate)),
    defaultWidth: 118,
  ),
  LibraryColumnDefinition<ComicKind, ComicWorkspaceDto, bool>(
    id: ComicFieldIds.wishlist,
    label: 'Wishlist',
    getValue: ComicKindSchema.wishlist.getValue,
    cellValue: (context) => Text(context.source.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<ComicKind, ComicWorkspaceDto, DateTime>(
    id: ComicFieldIds.updatedAt,
    label: 'Updated',
    getValue: ComicKindSchema.updatedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<ComicKind, ComicWorkspaceDto, DateTime?>(
    id: ComicFieldIds.addedAt,
    label: 'Added',
    getValue: ComicKindSchema.addedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicKindSchema.location,
    group: 'Personal',
    defaultWidth: 118,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicKindSchema.condition,
    group: 'Value',
    defaultWidth: 124,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, int?>(
    ComicKindSchema.pricePaid,
    cellValue: (context) => Text(_formatCents(
        context.source.ownedItem?.pricePaidCents, context.dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicKindSchema.barcode,
    group: 'Edition',
    defaultWidth: 160,
    maxWidth: 260,
  ),
  LibraryColumnDefinition<ComicKind, ComicWorkspaceDto, int?>(
    id: ComicFieldIds.rating,
    label: 'Rating',
    getValue: ComicKindSchema.rating.getValue,
    cellValue: (context) =>
        Text(context.source.ownedItem?.rating?.toString() ?? ''),
    defaultWidth: 80,
  ),
];

final comicLibraryKindSchema = LibraryKindSchema<ComicKind, ComicWorkspaceDto>(
  kindNamespace: 'comic',
  fields: comicLibraryFieldDefinitions,
  columns: comicLibraryColumnDefinitions,
  sorts: comicLibrarySortDefinitions,
  groups: comicLibraryGroupDefinitions,
  defaultVisibleColumns: comicLibraryDefaultVisibleColumns,
  defaultSort: ComicSortIds.series,
  defaultGroup: ComicGroupIds.series,
  preferenceCodec: const ComicPreferenceCodec(),
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
