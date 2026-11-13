import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/features/library/config/kind_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/additional_fields.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/catalog_schema.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/ids.dart';
import 'package:collectarr_app/features/library/kinds/book/config/workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/dto.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/facets.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_library_entry.dart';
import 'package:collectarr_app/features/library/workspace/config/typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/schema.dart';
import 'package:flutter/material.dart';

abstract final class BookLibraryEntryWorkspaceFields {
  static final condition =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, String?>(
    id: BookFieldIds.condition,
    metadata: BookWorkspaceFieldMetadata.condition,
    getValue: (context) {
      final entry = BookLibraryEntryProjection.fromDispatch(
          context.item.libraryEntryDispatch);
      return entry is BookLibraryEntry ? entry.personal.condition : null;
    },
  );

  static final location =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, String?>(
    id: BookFieldIds.location,
    metadata: BookWorkspaceFieldMetadata.location,
    getValue: (context) => context.personal.locationPath,
  );

  static final pricePaid =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, int?>(
    id: BookFieldIds.pricePaid,
    metadata: BookWorkspaceFieldMetadata.pricePaid,
    getValue: (context) => context.item.entrySummary?.pricePaidCents,
  );

  static final status =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, String?>(
    id: BookFieldIds.status,
    metadata: BookWorkspaceFieldMetadata.status,
    getValue: (context) => context.personal.isWishlisted
        ? 'wishlist'
        : ((context.item.entrySummary != null) ? 'entry' : null),
  );

  static final rating =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, int?>(
    id: BookFieldIds.rating,
    metadata: BookWorkspaceFieldMetadata.rating,
    getValue: (context) => context.dto.personal.rating,
  );

  static final wishlist =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, bool>(
    id: BookFieldIds.wishlist,
    metadata: BookWorkspaceFieldMetadata.wishlist,
    getValue: (context) => context.personal.isWishlisted,
  );

  static final updatedAt =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, DateTime>(
    id: BookFieldIds.updatedAt,
    metadata: BookWorkspaceFieldMetadata.updatedAt,
    getValue: (context) => context.updatedAt,
  );

  static final addedAt =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, DateTime?>(
    id: BookFieldIds.addedAt,
    metadata: BookWorkspaceFieldMetadata.addedAt,
    getValue: (context) => context.addedAt,
  );

  static final readStatus =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, String?>(
    id: BookFieldIds.readStatus,
    metadata: BookWorkspaceFieldMetadata.readStatus,
    getValue: (context) => context.dto.personal.trackingStatus,
  );

  static final signedBy =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, String?>(
    id: BookFieldIds.signedBy,
    metadata: BookWorkspaceFieldMetadata.signedBy,
    getValue: (context) {
      final entry = BookLibraryEntryProjection.fromDispatch(
          context.item.libraryEntryDispatch);
      final names =
          entry is BookLibraryEntry ? entry.personal.details.signedBy : null;
      return names == null || names.isEmpty ? null : names.join(', ');
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
  for (final (field, title) in [
    (BookLibraryEntryWorkspaceFields.readStatus, 'Read Status'),
    (BookLibraryEntryWorkspaceFields.signedBy, 'Signed By'),
  ])
    groupFromField<BookKind, BookWorkspaceDto, String?>(
      field,
      sidebarTitle: title,
      icon: Icons.label_outline,
    ),
  groupFromField<BookKind, BookWorkspaceDto, String?>(
    BookLibraryEntryWorkspaceFields.location,
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
];

final bookLibraryEntryWorkspaceSortDefinitions = [
  for (final field in [
    BookLibraryEntryWorkspaceFields.condition,
    BookLibraryEntryWorkspaceFields.location,
    BookLibraryEntryWorkspaceFields.readStatus,
    BookLibraryEntryWorkspaceFields.signedBy
  ])
    sortFromField<BookKind, BookWorkspaceDto, String>(field),
  for (final field in [
    BookLibraryEntryWorkspaceFields.rating,
    BookLibraryEntryWorkspaceFields.pricePaid
  ])
    sortFromField<BookKind, BookWorkspaceDto, num>(field),
  sortFromField<BookKind, BookWorkspaceDto, DateTime>(
      BookLibraryEntryWorkspaceFields.addedAt),
  sortFromField<BookKind, BookWorkspaceDto, DateTime>(
      BookLibraryEntryWorkspaceFields.updatedAt),
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

final bookLibraryEntryWorkspaceColumnDefinitions = [
  LibraryColumnDefinition<BookKind, BookWorkspaceDto, String?>(
    id: BookFieldIds.status,
    metadata: BookWorkspaceFieldMetadata.status,
    getValue: BookLibraryEntryWorkspaceFields.status.getValue,
    cellValue: (context) => Text(context.personal.isWishlisted
        ? 'Wishlist'
        : ((context.item.entrySummary != null) ? 'Entry' : '')),
    allowSortInteraction: false,
    allowGroupInteraction: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<BookKind, BookWorkspaceDto, String?>(
    id: BookFieldIds.readStatus,
    metadata: BookWorkspaceFieldMetadata.readStatus,
    getValue: BookLibraryEntryWorkspaceFields.readStatus.getValue,
    cellValue: (context) => Text(context.dto.personal.trackingStatus ?? ''),
    group: 'Personal',
    defaultWidth: 100,
  ),
  LibraryColumnDefinition<BookKind, BookWorkspaceDto, int?>(
    id: BookFieldIds.rating,
    metadata: BookWorkspaceFieldMetadata.rating,
    getValue: BookLibraryEntryWorkspaceFields.rating.getValue,
    cellValue: (context) => Text(context.dto.personal.rating?.toString() ?? ''),
    group: 'Personal',
    defaultWidth: 80,
  ),
  columnFromField<BookKind, BookWorkspaceDto, String?>(
    BookLibraryEntryWorkspaceFields.signedBy,
    group: 'Personal',
    defaultWidth: 130,
  ),
  columnFromField<BookKind, BookWorkspaceDto, String?>(
    BookLibraryEntryWorkspaceFields.condition,
    group: 'Personal',
    defaultWidth: 118,
  ),
  columnFromField<BookKind, BookWorkspaceDto, int?>(
    BookLibraryEntryWorkspaceFields.pricePaid,
    cellValue: (context) => Text(_formatCents(
        context.item.entrySummary?.pricePaidCents, context.dto.currency)),
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
    metadata: BookWorkspaceFieldMetadata.wishlist,
    getValue: BookLibraryEntryWorkspaceFields.wishlist.getValue,
    cellValue: (context) =>
        Text(context.personal.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  columnFromField<BookKind, BookWorkspaceDto, DateTime?>(
    BookLibraryEntryWorkspaceFields.addedAt,
    cellValue: (context) => Text(switch (context.addedAt) {
      final added? => AppFormats.current.formatDate(added),
      null => '',
    }),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<BookKind, BookWorkspaceDto, DateTime>(
    id: BookFieldIds.updatedAt,
    metadata: BookWorkspaceFieldMetadata.updatedAt,
    getValue: BookLibraryEntryWorkspaceFields.updatedAt.getValue,
    cellValue: (context) =>
        Text(AppFormats.current.formatDate(context.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
];

/// The additional fields that belong to the copy.
final _personalExtras = [
  for (final extra in bookAdditionalWorkspaceFields)
    if (extra.field.metadata.source == LibraryFieldSource.libraryEntry) extra,
];

final bookLibraryEntryWorkspaceSchema =
    LibraryWorkspaceSchema<BookKind, BookWorkspaceDto>(
  kindNamespace: 'book',
  // Collection items carry their catalog fields, as in Games: the table
  // resolves columns from this registry alone.
  fields: [
    ...bookCatalogWorkspaceFields,
    ...bookLibraryEntryWorkspaceFieldDefinitions,
    for (final extra in _personalExtras) extra.field,
    ...bookSmartListFacetFields,
  ],
  columns: [
    ...bookCatalogWorkspaceColumns,
    ...bookLibraryEntryWorkspaceColumnDefinitions,
    for (final extra in _personalExtras) extra.column,
  ],
  sorts: [
    ...bookCatalogWorkspaceSorts,
    ...bookLibraryEntryWorkspaceSortDefinitions,
    for (final extra in _personalExtras) extra.sort,
  ],
  groups: bookWorkspaceGroupsWith([
    ...bookCatalogWorkspaceGroups,
    ...bookLibraryEntryWorkspaceGroupDefinitions,
  ], _personalExtras),
  primaryColumn: BookFieldIds.title,
  defaultVisibleColumns: {
    ...bookWorkspaceDefaultColumnOrder,
    BookFieldIds.addedAt,
  },
  // Reference defaults: Author folders, sorted by Author then Title.
  defaultSort: BookSortIds.author,
  defaultThenSort: BookSortIds.title,
  defaultGroup: BookGroupIds.author,
);

String _formatCents(int? cents, String? currency) {
  if (cents == null) return '';
  final amount = (cents / 100).toStringAsFixed(2);
  return currency == null ? amount : '$currency $amount';
}
