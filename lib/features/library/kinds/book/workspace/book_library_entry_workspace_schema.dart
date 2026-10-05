import 'package:collectarr_app/features/library/kinds/book/workspace/book_ids.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_library_entry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_schema.dart';
import 'package:flutter/material.dart';

abstract final class BookLibraryEntryWorkspaceFields {
  static final condition =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, String?>(
    id: BookFieldIds.condition,
    label: 'Condition',
    getValue: (context) {
      final entry = BookLibraryEntryProjection.fromDispatch(
          context.item.libraryEntryDispatch);
      return entry is BookLibraryEntry ? entry.personal.condition : null;
    },
  );

  static final location =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, String?>(
    id: BookFieldIds.location,
    label: 'Location',
    getValue: (context) => context.personal.locationPath,
  );

  static final pricePaid =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, int?>(
    id: BookFieldIds.pricePaid,
    label: 'Purchase Price',
    getValue: (context) => context.item.entrySummary?.pricePaidCents,
  );

  static final status =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, String?>(
    id: BookFieldIds.status,
    label: 'Status',
    getValue: (context) => context.personal.isWishlisted
        ? 'wishlist'
        : ((context.item.entrySummary != null) ? 'entry' : null),
  );

  static final rating =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, int?>(
    id: BookFieldIds.rating,
    label: 'Rating',
    getValue: (context) => context.dto.personal.rating,
  );

  static final wishlist =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, bool>(
    id: BookFieldIds.wishlist,
    label: 'Wishlist',
    getValue: (context) => context.personal.isWishlisted,
  );

  static final updatedAt =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, DateTime>(
    id: BookFieldIds.updatedAt,
    label: 'Updated',
    getValue: (context) => context.updatedAt,
  );

  static final addedAt =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, DateTime?>(
    id: BookFieldIds.addedAt,
    label: 'Added',
    getValue: (context) => context.addedAt,
  );

  static final readStatus =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, String?>(
    id: BookFieldIds.readStatus,
    label: 'Read Status',
    getValue: (context) => context.dto.personal.trackingStatus,
  );

  static final signedBy =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, String?>(
    id: BookFieldIds.signedBy,
    label: 'Signed By',
    getValue: (context) {
      final entry = BookLibraryEntryProjection.fromDispatch(
          context.item.libraryEntryDispatch);
      return entry is BookLibraryEntry ? entry.personal.details.signedBy : null;
    },
  );
}

final bookLibraryEntryWorkspaceFieldDefinitions = [
  BookLibraryEntryWorkspaceFields.condition,
  BookLibraryEntryWorkspaceFields.location,
  BookLibraryEntryWorkspaceFields.pricePaid,
  BookLibraryEntryWorkspaceFields.rating,
  BookLibraryEntryWorkspaceFields.wishlist,
  BookLibraryEntryWorkspaceFields.updatedAt,
  BookLibraryEntryWorkspaceFields.addedAt,
  BookLibraryEntryWorkspaceFields.readStatus,
  BookLibraryEntryWorkspaceFields.signedBy,
  BookLibraryEntryWorkspaceFields.status,
];

final bookLibraryEntryWorkspaceGroupDefinitions = [
  groupFromField<BookKind, BookWorkspaceDto, String?>(
    BookLibraryEntryWorkspaceFields.condition,
    sidebarTitle: 'Conditions',
    icon: Icons.verified_outlined,
  ),
  groupFromField<BookKind, BookWorkspaceDto, String?>(
    BookLibraryEntryWorkspaceFields.location,
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
];

final bookLibraryEntryWorkspaceSortDefinitions = [
  LibrarySortDefinition<BookKind, BookWorkspaceDto>(
    id: BookSortIds.status,
    compare: (left, right) {
      int rank(LibraryProjectionContext<BookWorkspaceDto> ctx) {
        if ((ctx.item.entrySummary != null)) return 0;
        if (ctx.personal.isWishlisted) return 1;
        return 2;
      }

      final res = rank(left).compareTo(rank(right));
      return res != 0 ? res : left.dto.title.compareTo(right.dto.title);
    },
    label: 'Status',
  ),
];

final bookLibraryEntryWorkspaceDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  BookFieldIds.status,
  BookFieldIds.readStatus,
  BookFieldIds.rating,
  BookFieldIds.condition,
  BookFieldIds.pricePaid,
  BookFieldIds.location,
  BookFieldIds.wishlist,
  BookFieldIds.updatedAt,
};

final bookLibraryEntryWorkspaceColumnDefinitions = [
  LibraryColumnDefinition<BookKind, BookWorkspaceDto, String?>(
    id: BookFieldIds.status,
    label: 'Status',
    getValue: BookLibraryEntryWorkspaceFields.status.getValue,
    cellValue: (context) => Text(context.personal.isWishlisted
        ? 'Wishlist'
        : ((context.item.entrySummary != null) ? 'Entry' : '')),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<BookKind, BookWorkspaceDto, String?>(
    id: BookFieldIds.readStatus,
    label: 'Read Status',
    getValue: BookLibraryEntryWorkspaceFields.readStatus.getValue,
    cellValue: (context) => Text(context.dto.personal.trackingStatus ?? ''),
    group: 'Personal',
    defaultWidth: 100,
  ),
  LibraryColumnDefinition<BookKind, BookWorkspaceDto, int?>(
    id: BookFieldIds.rating,
    label: 'Rating',
    getValue: BookLibraryEntryWorkspaceFields.rating.getValue,
    cellValue: (context) => Text(context.dto.personal.rating?.toString() ?? ''),
    group: 'Personal',
    defaultWidth: 80,
  ),
  columnFromField<BookKind, BookWorkspaceDto, String?>(
    BookLibraryEntryWorkspaceFields.condition,
    group: 'Personal',
    defaultWidth: 118,
  ),
  columnFromField<BookKind, BookWorkspaceDto, int?>(
    BookLibraryEntryWorkspaceFields.pricePaid,
    cellValue: (context) =>
        Text(_formatCents(context.item.entrySummary?.pricePaidCents, context.dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  columnFromField<BookKind, BookWorkspaceDto, String?>(
    BookLibraryEntryWorkspaceFields.location,
    group: 'Personal',
    defaultWidth: 118,
  ),
  LibraryColumnDefinition<BookKind, BookWorkspaceDto, bool>(
    id: BookFieldIds.wishlist,
    label: 'Wishlist',
    getValue: BookLibraryEntryWorkspaceFields.wishlist.getValue,
    cellValue: (context) => Text(context.personal.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<BookKind, BookWorkspaceDto, DateTime>(
    id: BookFieldIds.updatedAt,
    label: 'Updated',
    getValue: BookLibraryEntryWorkspaceFields.updatedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
];

final bookLibraryEntryWorkspaceSchema =
    LibraryWorkspaceSchema<BookKind, BookWorkspaceDto>(
  kindNamespace: 'book',
  fields: bookLibraryEntryWorkspaceFieldDefinitions,
  columns: bookLibraryEntryWorkspaceColumnDefinitions,
  sorts: bookLibraryEntryWorkspaceSortDefinitions,
  groups: bookLibraryEntryWorkspaceGroupDefinitions,
  primaryColumn: BookFieldIds.status,
  defaultVisibleColumns: bookLibraryEntryWorkspaceDefaultVisibleColumns,
  defaultSort: BookSortIds.status,
  defaultGroup: BookGroupIds.condition,
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
