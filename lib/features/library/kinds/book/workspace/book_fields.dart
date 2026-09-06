import 'package:collectarr_app/features/library/kinds/book/workspace/book_ids.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details.dart';
import 'package:collectarr_app/features/library/config/library_facet_types.dart';
import 'package:collectarr_app/features/library/config/library_group_bucket_mutation.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_kind_schema.dart';
import 'package:flutter/material.dart';

export 'package:collectarr_app/features/library/kinds/book/workspace/book_ids.dart';
export 'package:collectarr_app/features/library/kinds/book/workspace/book_preference_codec.dart';

/// Single source of truth schema for Book kind fields.
abstract final class BookKindSchema {
  static final title = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.title,
    label: 'Title',
    getValue: (dto) => dto.title,
  );

  static final author = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.author,
    label: 'Author',
    getValue: (dto) => dto.author,
  );

  static final publisher = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.publisher,
    label: 'Publisher',
    getValue: (dto) => dto.publisher,
  );

  static final pageCount = numberField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.pageCount,
    label: 'Page count',
    getValue: (dto) => dto.pageCount,
  );

  static final isbn = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.isbn,
    label: 'ISBN',
    getValue: (dto) => dto.isbn ?? dto.barcode,
    scope: LibraryFieldScope.release,
  );

  static final condition =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, String?>(
    id: BookFieldIds.condition,
    label: 'Condition',
    getValue: (context) => context.source.ownedItem?.condition,
    scope: LibraryFieldScope.copy,
  );

  static final location =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, String?>(
    id: BookFieldIds.location,
    label: 'Location',
    getValue: (context) => context.source.locationPath,
    scope: LibraryFieldScope.copy,
  );

  static final series = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.series,
    label: 'Series',
    getValue: (dto) => dto.seriesTitle,
  );

  static final releaseDate = dateField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.releaseDate,
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
  );

  static final pricePaid =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, int?>(
    id: BookFieldIds.pricePaid,
    label: 'Purchase Price',
    getValue: (context) => context.source.ownedItem?.pricePaidCents,
    scope: LibraryFieldScope.copy,
  );

  static final status =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, String?>(
    id: BookFieldIds.status,
    label: 'Status',
    getValue: (context) => context.source.isWishlisted
        ? 'wishlist'
        : (context.source.isOwned ? 'owned' : null),
    scope: LibraryFieldScope.copy,
  );

  static final cover =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, String?>(
    id: BookFieldIds.cover,
    label: 'Cover',
    getValue: (context) => context.dto.coverImageUrl,
    scope: LibraryFieldScope.media,
  );

  static final rating =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, int?>(
    id: BookFieldIds.rating,
    label: 'Rating',
    getValue: (context) => context.dto.personal.rating,
    scope: LibraryFieldScope.copy,
  );

  static final wishlist =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, bool>(
    id: BookFieldIds.wishlist,
    label: 'Wishlist',
    getValue: (context) => context.source.isWishlisted,
    scope: LibraryFieldScope.copy,
  );

  static final updatedAt =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, DateTime>(
    id: BookFieldIds.updatedAt,
    label: 'Updated',
    getValue: (context) => context.source.updatedAt,
    scope: LibraryFieldScope.copy,
  );

  static final addedAt =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, DateTime?>(
    id: BookFieldIds.addedAt,
    label: 'Added',
    getValue: (context) => context.source.addedAt,
    scope: LibraryFieldScope.copy,
  );

  static final readStatus =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, String?>(
    id: BookFieldIds.readStatus,
    label: 'Read Status',
    getValue: (context) => context.dto.personal.trackingStatus,
    scope: LibraryFieldScope.copy,
  );

  // Rich Book Metadata Fields
  static final subtitle = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.subtitle,
    label: 'Subtitle',
    getValue: (dto) => dto.subtitle,
  );

  static final format = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.format,
    label: 'Format',
    getValue: (dto) => dto.format,
  );

  static final translator = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.translator,
    label: 'Translator',
    getValue: (dto) => dto.translator,
  );

  static final editor = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.editor,
    label: 'Editor',
    getValue: (dto) => dto.editor,
  );

  static final illustrator = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.illustrator,
    label: 'Illustrator',
    getValue: (dto) => dto.illustrator,
  );

  static final coverArtist = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.coverArtist,
    label: 'Cover Artist',
    getValue: (dto) => dto.coverArtist,
  );

  static final printing = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.printing,
    label: 'Printing',
    getValue: (dto) => dto.printing,
  );

  static final numberLine = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.numberLine,
    label: 'Number Line',
    getValue: (dto) => dto.numberLine,
  );

  static final firstEdition =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, bool>(
    id: BookFieldIds.firstEdition,
    label: 'First Edition',
    getValue: (context) => context.dto.firstEdition,
    scope: LibraryFieldScope.release,
  );

  static final dewey = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.dewey,
    label: 'Dewey Decimal',
    getValue: (dto) => dto.dewey,
  );

  static final locClassification = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.locClassification,
    label: 'LoC Classification',
    getValue: (dto) => dto.locClassification,
  );

  static final signedBy =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, String?>(
    id: BookFieldIds.signedBy,
    label: 'Signed By',
    getValue: (context) =>
        (context.source.ownedItem?.details as BookOwnedDetails?)?.signedBy,
    scope: LibraryFieldScope.copy,
  );
}

final bookLibraryFacetDefinitions =
    <LibraryFacetDefinition<BookKind, BookWorkspaceDto, String>>[
  LibraryFacetDefinition<BookKind, BookWorkspaceDto, String>(
    id: BookFacetIds.author,
    label: 'Author',
    extractValues: (dto) =>
        dto.metadata?.authors ??
        [
          if (dto.author case final author?) author,
        ],
  ),
  LibraryFacetDefinition<BookKind, BookWorkspaceDto, String>(
    id: BookFacetIds.publisher,
    label: 'Publisher',
    extractValues: (dto) => [
      if (dto.publisher case final publisher?) publisher,
    ],
  ),
  LibraryFacetDefinition<BookKind, BookWorkspaceDto, String>(
    id: BookFacetIds.genre,
    label: 'Genre',
    extractValues: (dto) => dto.metadata?.genres ?? const <String>[],
  ),
  LibraryFacetDefinition<BookKind, BookWorkspaceDto, String>(
    id: BookFacetIds.format,
    label: 'Format',
    extractValues: (dto) => [
      if (dto.format case final format?) format,
    ],
  ),
  LibraryFacetDefinition<BookKind, BookWorkspaceDto, String>(
    id: BookFacetIds.subject,
    label: 'Subject',
    extractValues: (dto) => dto.metadata?.subjects ?? const <String>[],
  ),
  LibraryFacetDefinition<BookKind, BookWorkspaceDto, String>(
    id: BookFacetIds.translator,
    label: 'Translator',
    extractValues: (dto) => dto.metadata?.translators ?? const <String>[],
  ),
];

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
  BookKindSchema.pricePaid,
  BookKindSchema.rating,
  BookKindSchema.wishlist,
  BookKindSchema.updatedAt,
  BookKindSchema.addedAt,
  BookKindSchema.readStatus,
  BookKindSchema.subtitle,
  BookKindSchema.format,
  BookKindSchema.translator,
  BookKindSchema.editor,
  BookKindSchema.illustrator,
  BookKindSchema.coverArtist,
  BookKindSchema.printing,
  BookKindSchema.numberLine,
  BookKindSchema.firstEdition,
  BookKindSchema.dewey,
  BookKindSchema.locClassification,
  BookKindSchema.signedBy,
  BookKindSchema.status,
  BookKindSchema.cover,
];

final bookLibraryGroupDefinitions = [
  groupFromField<BookKind, BookWorkspaceDto, String?>(
    BookKindSchema.author,
    sidebarTitle: 'Authors',
    icon: Icons.person_outline,
  ),
  groupFromField<BookKind, BookWorkspaceDto, String?>(
    BookKindSchema.publisher,
    sidebarTitle: 'Publishers',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
    bucketValueMutator: libraryStringBucketValueMutator(
      'publisher',
      mirrorKeys: ['original_publisher'],
      nestedValueKey: 'original_publisher',
    ),
  ),
  groupFromField<BookKind, BookWorkspaceDto, String?>(
    BookKindSchema.series,
    sidebarTitle: 'Series',
    icon: Icons.collections_bookmark_outlined,
    sequenceValue: (context) => context.dto.itemNumber,
  ),
  groupFromField<BookKind, BookWorkspaceDto, String?>(
    BookKindSchema.format,
    sidebarTitle: 'Formats',
    icon: Icons.book_outlined,
  ),
  groupFromField<BookKind, BookWorkspaceDto, String?>(
    BookKindSchema.condition,
    sidebarTitle: 'Conditions',
    icon: Icons.verified_outlined,
  ),
  groupFromField<BookKind, BookWorkspaceDto, String?>(
    BookKindSchema.location,
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
];

final bookLibrarySortDefinitions = [
  LibrarySortDefinition<BookKind, BookWorkspaceDto>(
    id: BookSortIds.status,
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
  sortFromField<BookKind, BookWorkspaceDto, String>(BookKindSchema.title),
  sortFromField<BookKind, BookWorkspaceDto, DateTime>(
      BookKindSchema.releaseDate,
      defaultAscending: false),
  sortFromField<BookKind, BookWorkspaceDto, num>(BookKindSchema.pageCount,
      group: 'Edition'),
  sortFromField<BookKind, BookWorkspaceDto, String>(BookKindSchema.author),
];

final booksLibraryDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  BookFieldIds.status,
  BookFieldIds.cover,
  BookFieldIds.author,
  BookFieldIds.title,
  BookFieldIds.publisher,
  BookFieldIds.releaseDate,
  BookFieldIds.isbn,
  BookFieldIds.readStatus,
  BookFieldIds.rating,
  BookFieldIds.condition,
  BookFieldIds.pricePaid,
  BookFieldIds.location,
  BookFieldIds.wishlist,
  BookFieldIds.updatedAt,
};

final bookLibraryColumnDefinitions = [
  LibraryColumnDefinition<BookKind, BookWorkspaceDto, String?>(
    id: BookFieldIds.status,
    label: 'Status',
    getValue: BookKindSchema.status.getValue,
    cellValue: (context) => Text(context.source.isWishlisted
        ? 'Wishlist'
        : (context.source.isOwned ? 'Owned' : '')),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<BookKind, BookWorkspaceDto, String?>(
    id: BookFieldIds.cover,
    label: '',
    getValue: BookKindSchema.cover.getValue,
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
  columnFromField<BookKind, BookWorkspaceDto, String?>(BookKindSchema.author,
      defaultWidth: 150),
  columnFromField<BookKind, BookWorkspaceDto, String?>(BookKindSchema.title,
      defaultWidth: 260, maxWidth: 520),
  columnFromField<BookKind, BookWorkspaceDto, String?>(BookKindSchema.publisher,
      defaultWidth: 140),
  columnFromField<BookKind, BookWorkspaceDto, DateTime?>(
    BookKindSchema.releaseDate,
    cellValue: (context) => Text(_formatDate(context.dto.releaseDate)),
    defaultWidth: 118,
  ),
  columnFromField<BookKind, BookWorkspaceDto, String?>(
    BookKindSchema.isbn,
    group: 'Edition',
    defaultWidth: 150,
    maxWidth: 240,
  ),
  LibraryColumnDefinition<BookKind, BookWorkspaceDto, String?>(
    id: BookFieldIds.readStatus,
    label: 'Read Status',
    getValue: BookKindSchema.readStatus.getValue,
    cellValue: (context) => Text(context.dto.personal.trackingStatus ?? ''),
    group: 'Personal',
    defaultWidth: 100,
  ),
  LibraryColumnDefinition<BookKind, BookWorkspaceDto, int?>(
    id: BookFieldIds.rating,
    label: 'Rating',
    getValue: BookKindSchema.rating.getValue,
    cellValue: (context) => Text(context.dto.personal.rating?.toString() ?? ''),
    group: 'Personal',
    defaultWidth: 80,
  ),
  columnFromField<BookKind, BookWorkspaceDto, String?>(
    BookKindSchema.condition,
    group: 'Personal',
    defaultWidth: 118,
  ),
  columnFromField<BookKind, BookWorkspaceDto, int?>(
    BookKindSchema.pricePaid,
    cellValue: (context) => Text(_formatCents(
        context.source.ownedItem?.pricePaidCents, context.dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  columnFromField<BookKind, BookWorkspaceDto, String?>(
    BookKindSchema.location,
    group: 'Personal',
    defaultWidth: 118,
  ),
  LibraryColumnDefinition<BookKind, BookWorkspaceDto, bool>(
    id: BookFieldIds.wishlist,
    label: 'Wishlist',
    getValue: BookKindSchema.wishlist.getValue,
    cellValue: (context) => Text(context.source.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<BookKind, BookWorkspaceDto, DateTime>(
    id: BookFieldIds.updatedAt,
    label: 'Updated',
    getValue: BookKindSchema.updatedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  columnFromField<BookKind, BookWorkspaceDto, String?>(
    BookKindSchema.subtitle,
    group: 'Details',
    defaultWidth: 180,
  ),
  columnFromField<BookKind, BookWorkspaceDto, String?>(
    BookKindSchema.format,
    group: 'Edition',
    defaultWidth: 110,
  ),
  columnFromField<BookKind, BookWorkspaceDto, String?>(
    BookKindSchema.translator,
    group: 'Credits',
    defaultWidth: 130,
  ),
  columnFromField<BookKind, BookWorkspaceDto, String?>(
    BookKindSchema.editor,
    group: 'Credits',
    defaultWidth: 130,
  ),
  columnFromField<BookKind, BookWorkspaceDto, String?>(
    BookKindSchema.illustrator,
    group: 'Credits',
    defaultWidth: 130,
  ),
  columnFromField<BookKind, BookWorkspaceDto, String?>(
    BookKindSchema.printing,
    group: 'Edition',
    defaultWidth: 100,
  ),
  columnFromField<BookKind, BookWorkspaceDto, String?>(
    BookKindSchema.numberLine,
    group: 'Edition',
    defaultWidth: 100,
  ),
  LibraryColumnDefinition<BookKind, BookWorkspaceDto, bool>(
    id: BookFieldIds.firstEdition,
    label: '1st Edition',
    getValue: BookKindSchema.firstEdition.getValue,
    cellValue: (context) => Text(context.dto.firstEdition ? 'Yes' : 'No'),
    group: 'Edition',
    defaultWidth: 90,
  ),
  columnFromField<BookKind, BookWorkspaceDto, String?>(
    BookKindSchema.dewey,
    group: 'Classification',
    defaultWidth: 100,
  ),
];

final bookLibraryKindSchema = LibraryKindSchema<BookKind, BookWorkspaceDto>(
  kindNamespace: 'book',
  fields: bookLibraryFieldDefinitions,
  columns: bookLibraryColumnDefinitions,
  sorts: bookLibrarySortDefinitions,
  groups: bookLibraryGroupDefinitions,
  defaultVisibleColumns: booksLibraryDefaultVisibleColumns,
  defaultSort: BookSortIds.author,
  defaultGroup: BookGroupIds.author,
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
