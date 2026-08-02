import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_kind_schema.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:flutter/material.dart';

/// Single source of truth schema for Book kind fields.
abstract final class BookKindSchema {
  static final title = textField<BookWorkspaceDto>(
    id: 'book.title',
    label: 'Title',
    getValue: (dto) => dto.title,
  );

  static final author = textField<BookWorkspaceDto>(
    id: 'book.author',
    label: 'Author',
    getValue: (dto) => dto.author,
  );

  static final publisher = textField<BookWorkspaceDto>(
    id: 'book.publisher',
    label: 'Publisher',
    getValue: (dto) => dto.publisher,
  );

  static final pageCount = numberField<BookWorkspaceDto>(
    id: 'book.page_count',
    label: 'Page count',
    getValue: (dto) => dto.pageCount,
  );

  static final isbn = textField<BookWorkspaceDto>(
    id: 'book.isbn',
    label: 'ISBN',
    getValue: (dto) => dto.isbn ?? dto.barcode,
  );

  static final condition = textField<BookWorkspaceDto>(
    id: 'book.condition',
    label: 'Condition',
    getValue: (dto) => dto.condition,
  );

  static final location = textField<BookWorkspaceDto>(
    id: 'book.location',
    label: 'Location',
    getValue: (dto) => dto.locationPath,
  );

  static final series = textField<BookWorkspaceDto>(
    id: 'book.series',
    label: 'Series',
    getValue: (dto) => dto.seriesTitle,
  );

  static final releaseDate = dateField<BookWorkspaceDto>(
    id: 'book.release_date',
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
  );

  static final price = moneyField<BookWorkspaceDto>(
    id: 'book.price',
    label: 'Purchase Price',
    getValue: (dto) => dto.pricePaidCents,
  );
}

final bookLibraryFieldDefinitions = [
  BookKindSchema.title,
  BookKindSchema.author,
  BookKindSchema.publisher,
  BookKindSchema.pageCount,
  BookKindSchema.isbn,
  BookKindSchema.condition,
  BookKindSchema.location,
  BookKindSchema.series,
  BookKindSchema.releaseDate,
  BookKindSchema.price,
];

final bookLibraryGroupDefinitions = [
  groupFromField(
    BookKindSchema.author,
    sidebarTitle: 'Authors',
    icon: Icons.person_outline,
  ),
  groupFromField(
    BookKindSchema.publisher,
    sidebarTitle: 'Publishers',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
  ),
  groupFromField(
    BookKindSchema.series,
    sidebarTitle: 'Series',
    icon: Icons.collections_bookmark_outlined,
  ),
  groupFromField(
    BookKindSchema.condition,
    sidebarTitle: 'Conditions',
    icon: Icons.grade_outlined,
  ),
  groupFromField(
    BookKindSchema.location,
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
];

final bookLibrarySortDefinitions = [
  sortFromField(BookKindSchema.series),
  sortFromField(BookKindSchema.publisher),
  LibrarySortDefinition<BookWorkspaceDto>(
    id: const LibrarySortId('status'),
    compare: (left, right) {
      int rank(BookWorkspaceDto dto) {
        if (dto.isOwned) return 0;
        if (dto.isWishlisted) return 1;
        return 2;
      }

      final res = rank(left).compareTo(rank(right));
      return res != 0 ? res : left.title.compareTo(right.title);
    },
    label: 'Status',
  ),
  sortFromField(BookKindSchema.title),
  sortFromField(BookKindSchema.releaseDate, defaultAscending: false),
  sortFromField(BookKindSchema.pageCount, group: 'Edition'),
  sortFromField(BookKindSchema.author),
];

const booksLibraryDefaultVisibleColumnIds = {
  'status',
  'cover',
  'book.author',
  'book.title',
  'book.publisher',
  'book.release_date',
  'book.isbn',
  'read_status',
  'rating',
  'book.condition',
  'book.price',
  'book.location',
  'wishlist',
  'updated',
};

final bookLibraryColumnDefinitions = [
  LibraryColumnDefinition<BookWorkspaceDto, Object?>(
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
  LibraryColumnDefinition<BookWorkspaceDto, Object?>(
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
  columnFromField(BookKindSchema.title, defaultWidth: 260, maxWidth: 520),
  columnFromField(BookKindSchema.publisher, defaultWidth: 140),
  columnFromField(
    BookKindSchema.releaseDate,
    cellValue: (dto) => Text(_formatDate(dto.releaseDate)),
    defaultWidth: 118,
  ),
  LibraryColumnDefinition<BookWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('wishlist'),
    label: 'Wishlist',
    getValue: (dto) => dto.isWishlisted,
    cellValue: (dto) => Text(dto.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<BookWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('updated'),
    label: 'Updated',
    getValue: (dto) => dto.updatedAt,
    cellValue: (dto) => Text(_formatDate(dto.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<BookWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('added'),
    label: 'Added',
    getValue: (dto) => dto.addedAt,
    cellValue: (dto) => Text(_formatDate(dto.addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  columnFromField(BookKindSchema.location,
      group: 'Personal', defaultWidth: 118),
  columnFromField(BookKindSchema.condition, group: 'Value', defaultWidth: 124),
  columnFromField(
    BookKindSchema.price,
    cellValue: (dto) => Text(_formatCents(dto.pricePaidCents, dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  LibraryColumnDefinition<BookWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('format'),
    label: 'Format',
    getValue: (dto) => dto.referenceFormatLabel,
    cellValue: (dto) => Text(dto.referenceFormatLabel ?? ''),
    defaultWidth: 100,
  ),
  LibraryColumnDefinition<BookWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('variant'),
    label: 'Edition / Binding',
    getValue: (dto) => dto.variant,
    cellValue: (dto) => Text(dto.variant ?? ''),
    defaultWidth: 170,
    maxWidth: 420,
  ),
  columnFromField(BookKindSchema.isbn,
      group: 'Edition', defaultWidth: 160, maxWidth: 260),
  columnFromField(BookKindSchema.author, defaultWidth: 160),
  LibraryColumnDefinition<BookWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('read_status'),
    label: 'Read Status',
    getValue: (dto) => dto.collectionStatus,
    cellValue: (dto) => Text(dto.collectionStatus ?? ''),
    defaultWidth: 100,
  ),
  LibraryColumnDefinition<BookWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('rating'),
    label: 'Rating',
    getValue: (dto) => dto.rating,
    cellValue: (dto) => Text(dto.rating?.toString() ?? ''),
    defaultWidth: 80,
  ),
];

final bookKindSchema = LibraryKindSchema<BookWorkspaceDto>(
  fields: bookLibraryFieldDefinitions,
  columns: bookLibraryColumnDefinitions,
  sorts: bookLibrarySortDefinitions,
  groups: bookLibraryGroupDefinitions,
  defaultVisibleColumnIds: booksLibraryDefaultVisibleColumnIds,
  defaultSortId: 'book.title',
  defaultGroupId: 'book.series',
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
