import 'package:collectarr_app/features/library/kinds/book/workspace/book_ids.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_bucket_mutators.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:flutter/material.dart';

abstract final class BookReleaseWorkspaceFields {
  static final publisher = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.publisher,
    label: 'Publisher',
    getValue: (dto) => dto.publisher,
    entityScope: LibraryEntityScope.release,
  );

  static final pageCount = numberField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.pageCount,
    label: 'Page count',
    getValue: (dto) => dto.pageCount,
    entityScope: LibraryEntityScope.release,
  );

  static final isbn = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.isbn,
    label: 'ISBN',
    getValue: (dto) => dto.isbn ?? dto.barcode,
    entityScope: LibraryEntityScope.release,
  );

  static final releaseDate = dateField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.releaseDate,
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
    entityScope: LibraryEntityScope.release,
  );

  static final format = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.format,
    label: 'Format',
    getValue: (dto) => dto.format,
    entityScope: LibraryEntityScope.release,
  );

  static final firstEdition =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, bool>(
    id: BookFieldIds.firstEdition,
    label: 'First Edition',
    getValue: (context) => context.dto.firstEdition,
    entityScope: LibraryEntityScope.release,
  );

  static final dewey = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.dewey,
    label: 'Dewey Decimal',
    getValue: (dto) => dto.dewey,
    entityScope: LibraryEntityScope.release,
  );

  static final locClassification = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.locClassification,
    label: 'LoC Classification',
    getValue: (dto) => dto.locClassification,
    entityScope: LibraryEntityScope.release,
  );
}

final bookReleaseWorkspaceFieldDefinitions = [
  BookReleaseWorkspaceFields.publisher,
  BookReleaseWorkspaceFields.pageCount,
  BookReleaseWorkspaceFields.isbn,
  BookReleaseWorkspaceFields.releaseDate,
  BookReleaseWorkspaceFields.format,
  BookReleaseWorkspaceFields.firstEdition,
  BookReleaseWorkspaceFields.dewey,
  BookReleaseWorkspaceFields.locClassification,
];

final bookReleaseWorkspaceGroupDefinitions = [
  groupFromField<BookKind, BookWorkspaceDto, String?>(
    BookReleaseWorkspaceFields.publisher,
    sidebarTitle: 'Publishers',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
    bucketValueMutator: catalogTransportStringBucketValueMutator(
      ['publisher', 'original_publisher'],
      nestedContainerKey: 'publishing',
      nestedValueKey: 'original_publisher',
    ),
  ),
  groupFromField<BookKind, BookWorkspaceDto, String?>(
    BookReleaseWorkspaceFields.format,
    sidebarTitle: 'Formats',
    icon: Icons.book_outlined,
  ),
];

final bookReleaseWorkspaceSortDefinitions = [
  sortFromField<BookKind, BookWorkspaceDto, DateTime>(
      BookReleaseWorkspaceFields.releaseDate,
      defaultAscending: false),
  sortFromField<BookKind, BookWorkspaceDto, num>(
      BookReleaseWorkspaceFields.pageCount,
      group: 'Edition'),
];

final bookReleaseWorkspaceDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  BookFieldIds.publisher,
  BookFieldIds.releaseDate,
  BookFieldIds.isbn,
};

final bookReleaseWorkspaceColumnDefinitions = [
  columnFromField<BookKind, BookWorkspaceDto, String?>(
      BookReleaseWorkspaceFields.publisher,
      defaultWidth: 140),
  columnFromField<BookKind, BookWorkspaceDto, DateTime?>(
    BookReleaseWorkspaceFields.releaseDate,
    cellValue: (context) => Text(_formatDate(context.dto.releaseDate)),
    defaultWidth: 118,
  ),
  columnFromField<BookKind, BookWorkspaceDto, String?>(
    BookReleaseWorkspaceFields.isbn,
    group: 'Edition',
    defaultWidth: 150,
    maxWidth: 240,
  ),
  columnFromField<BookKind, BookWorkspaceDto, String?>(
    BookReleaseWorkspaceFields.format,
    group: 'Edition',
    defaultWidth: 110,
  ),
  LibraryColumnDefinition<BookKind, BookWorkspaceDto, bool>(
    id: BookFieldIds.firstEdition,
    label: '1st Edition',
    getValue: BookReleaseWorkspaceFields.firstEdition.getValue,
    cellValue: (context) => Text(context.dto.firstEdition ? 'Yes' : 'No'),
    group: 'Edition',
    defaultWidth: 90,
  ),
  columnFromField<BookKind, BookWorkspaceDto, String?>(
    BookReleaseWorkspaceFields.dewey,
    group: 'Classification',
    defaultWidth: 100,
  ),
];

final bookReleaseWorkspaceSchema =
    LibraryEntityWorkspaceSchema<BookKind, BookWorkspaceDto>(
  kindNamespace: 'book',
  entityScope: LibraryEntityScope.release,
  fields: bookReleaseWorkspaceFieldDefinitions,
  columns: bookReleaseWorkspaceColumnDefinitions,
  sorts: bookReleaseWorkspaceSortDefinitions,
  groups: bookReleaseWorkspaceGroupDefinitions,
  primaryColumn: BookFieldIds.publisher,
  defaultVisibleColumns: bookReleaseWorkspaceDefaultVisibleColumns,
  defaultSort: BookSortIds.releaseDate,
  defaultGroup: BookGroupIds.publisher,
  preferenceCodec: const BookPreferenceCodec(),
);

String _formatDate(DateTime? value) {
  if (value == null) return '';
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
