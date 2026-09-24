import 'package:collectarr_app/features/library/kinds/book/workspace/book_ids.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_owned_item.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:flutter/material.dart';

abstract final class BookCopyWorkspaceFields {
  static final condition =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, String?>(
    id: BookFieldIds.condition,
    label: 'Condition',
    getValue: (context) {
      final owned = BookOwnedItemProjection.fromDispatch(
          context.source.ownedItemDispatch);
      return owned is BookOwnedItem ? owned.condition : null;
    },
    entityScope: LibraryEntityScope.copy,
  );

  static final location =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, String?>(
    id: BookFieldIds.location,
    label: 'Location',
    getValue: (context) => context.source.locationPath,
    entityScope: LibraryEntityScope.copy,
  );

  static final pricePaid =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, int?>(
    id: BookFieldIds.pricePaid,
    label: 'Purchase Price',
    getValue: (context) => context.source.pricePaidCents,
    entityScope: LibraryEntityScope.copy,
  );

  static final status =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, String?>(
    id: BookFieldIds.status,
    label: 'Status',
    getValue: (context) => context.source.isWishlisted
        ? 'wishlist'
        : (context.source.isOwned ? 'owned' : null),
    entityScope: LibraryEntityScope.copy,
  );

  static final rating =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, int?>(
    id: BookFieldIds.rating,
    label: 'Rating',
    getValue: (context) => context.dto.personal.rating,
    entityScope: LibraryEntityScope.copy,
  );

  static final wishlist =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, bool>(
    id: BookFieldIds.wishlist,
    label: 'Wishlist',
    getValue: (context) => context.source.isWishlisted,
    entityScope: LibraryEntityScope.copy,
  );

  static final updatedAt =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, DateTime>(
    id: BookFieldIds.updatedAt,
    label: 'Updated',
    getValue: (context) => context.source.updatedAt,
    entityScope: LibraryEntityScope.copy,
  );

  static final addedAt =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, DateTime?>(
    id: BookFieldIds.addedAt,
    label: 'Added',
    getValue: (context) => context.source.addedAt,
    entityScope: LibraryEntityScope.copy,
  );

  static final readStatus =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, String?>(
    id: BookFieldIds.readStatus,
    label: 'Read Status',
    getValue: (context) => context.dto.personal.trackingStatus,
    entityScope: LibraryEntityScope.copy,
  );

  static final signedBy =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, String?>(
    id: BookFieldIds.signedBy,
    label: 'Signed By',
    getValue: (context) {
      final owned = BookOwnedItemProjection.fromDispatch(
          context.source.ownedItemDispatch);
      return owned is BookOwnedItem ? owned.details.signedBy : null;
    },
    entityScope: LibraryEntityScope.copy,
  );
}

final bookCopyWorkspaceFieldDefinitions = [
  BookCopyWorkspaceFields.condition,
  BookCopyWorkspaceFields.location,
  BookCopyWorkspaceFields.pricePaid,
  BookCopyWorkspaceFields.rating,
  BookCopyWorkspaceFields.wishlist,
  BookCopyWorkspaceFields.updatedAt,
  BookCopyWorkspaceFields.addedAt,
  BookCopyWorkspaceFields.readStatus,
  BookCopyWorkspaceFields.signedBy,
  BookCopyWorkspaceFields.status,
];

final bookCopyWorkspaceGroupDefinitions = [
  groupFromField<BookKind, BookWorkspaceDto, String?>(
    BookCopyWorkspaceFields.condition,
    sidebarTitle: 'Conditions',
    icon: Icons.verified_outlined,
  ),
  groupFromField<BookKind, BookWorkspaceDto, String?>(
    BookCopyWorkspaceFields.location,
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
];

final bookCopyWorkspaceSortDefinitions = [
  LibrarySortDefinition<BookKind, BookWorkspaceDto>(
    id: BookSortIds.status,
    entityScope: LibraryEntityScope.copy,
    compare: (left, right) {
      int rank(LibraryProjectionContext<BookWorkspaceDto> ctx) {
        if (ctx.source.isOwned) return 0;
        if (ctx.source.isWishlisted) return 1;
        return 2;
      }

      final res = rank(left).compareTo(rank(right));
      return res != 0 ? res : left.dto.title.compareTo(right.dto.title);
    },
    label: 'Status',
  ),
];

final bookCopyWorkspaceDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  BookFieldIds.status,
  BookFieldIds.readStatus,
  BookFieldIds.rating,
  BookFieldIds.condition,
  BookFieldIds.pricePaid,
  BookFieldIds.location,
  BookFieldIds.wishlist,
  BookFieldIds.updatedAt,
};

final bookCopyWorkspaceColumnDefinitions = [
  LibraryColumnDefinition<BookKind, BookWorkspaceDto, String?>(
    id: BookFieldIds.status,
    label: 'Status',
    getValue: BookCopyWorkspaceFields.status.getValue,
    cellValue: (context) => Text(context.source.isWishlisted
        ? 'Wishlist'
        : (context.source.isOwned ? 'Owned' : '')),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<BookKind, BookWorkspaceDto, String?>(
    id: BookFieldIds.readStatus,
    label: 'Read Status',
    getValue: BookCopyWorkspaceFields.readStatus.getValue,
    cellValue: (context) => Text(context.dto.personal.trackingStatus ?? ''),
    group: 'Personal',
    defaultWidth: 100,
  ),
  LibraryColumnDefinition<BookKind, BookWorkspaceDto, int?>(
    id: BookFieldIds.rating,
    label: 'Rating',
    getValue: BookCopyWorkspaceFields.rating.getValue,
    cellValue: (context) => Text(context.dto.personal.rating?.toString() ?? ''),
    group: 'Personal',
    defaultWidth: 80,
  ),
  columnFromField<BookKind, BookWorkspaceDto, String?>(
    BookCopyWorkspaceFields.condition,
    group: 'Personal',
    defaultWidth: 118,
  ),
  columnFromField<BookKind, BookWorkspaceDto, int?>(
    BookCopyWorkspaceFields.pricePaid,
    cellValue: (context) =>
        Text(_formatCents(context.source.pricePaidCents, context.dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  columnFromField<BookKind, BookWorkspaceDto, String?>(
    BookCopyWorkspaceFields.location,
    group: 'Personal',
    defaultWidth: 118,
  ),
  LibraryColumnDefinition<BookKind, BookWorkspaceDto, bool>(
    id: BookFieldIds.wishlist,
    label: 'Wishlist',
    getValue: BookCopyWorkspaceFields.wishlist.getValue,
    cellValue: (context) => Text(context.source.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<BookKind, BookWorkspaceDto, DateTime>(
    id: BookFieldIds.updatedAt,
    label: 'Updated',
    getValue: BookCopyWorkspaceFields.updatedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
];

final bookCopyWorkspaceSchema =
    LibraryEntityWorkspaceSchema<BookKind, BookWorkspaceDto>(
  kindNamespace: 'book',
  entityScope: LibraryEntityScope.copy,
  fields: bookCopyWorkspaceFieldDefinitions,
  columns: bookCopyWorkspaceColumnDefinitions,
  sorts: bookCopyWorkspaceSortDefinitions,
  groups: bookCopyWorkspaceGroupDefinitions,
  primaryColumn: BookFieldIds.status,
  defaultVisibleColumns: bookCopyWorkspaceDefaultVisibleColumns,
  defaultSort: BookSortIds.status,
  defaultGroup: BookGroupIds.condition,
  preferenceCodec: const BookPreferenceCodec(),
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
