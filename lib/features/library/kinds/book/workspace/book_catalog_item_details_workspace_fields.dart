import 'package:collectarr_app/features/library/kinds/book/workspace/book_ids.dart';
import 'package:collectarr_app/features/library/kinds/book/config/book_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_bucket_mutators.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:flutter/material.dart';

abstract final class BookCatalogItemDetailsWorkspaceFields {
  static final publisher = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.publisher,
    metadata: BookFieldIdentities.publisher,
    getValue: (dto) => dto.publisher,
  );

  static final pageCount = numberField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.pageCount,
    metadata: BookFieldIdentities.pageCount,
    getValue: (dto) => dto.pageCount,
  );

  static final isbn = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.isbn,
    metadata: BookFieldIdentities.isbn,
    getValue: (dto) => dto.isbn ?? dto.barcode,
  );

  static final releaseDate = dateField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.releaseDate,
    metadata: BookFieldIdentities.releaseDate,
    getValue: (dto) => dto.releaseDate,
  );

  static final format = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.format,
    metadata: BookFieldIdentities.format,
    getValue: (dto) => dto.format,
  );
}

final bookCatalogItemDetailsWorkspaceFieldDefinitions = [
  BookCatalogItemDetailsWorkspaceFields.publisher,
  BookCatalogItemDetailsWorkspaceFields.pageCount,
  BookCatalogItemDetailsWorkspaceFields.isbn,
  BookCatalogItemDetailsWorkspaceFields.releaseDate,
  BookCatalogItemDetailsWorkspaceFields.format,
];

final bookCatalogItemDetailsWorkspaceGroupDefinitions = [
  if (BookFieldIdentities.publisher.groupable)
    groupFromField<BookKind, BookWorkspaceDto, String?>(
      BookCatalogItemDetailsWorkspaceFields.publisher,
      sidebarTitle: 'Publishers',
      icon: Icons.business_outlined,
      supportsBucketManagement: true,
      bucketValueMutator: catalogTransportStringBucketValueMutator(
        ['publisher'],
      ),
    ),
  if (BookFieldIdentities.format.groupable)
    groupFromField<BookKind, BookWorkspaceDto, String?>(
      BookCatalogItemDetailsWorkspaceFields.format,
      sidebarTitle: 'Formats',
      icon: Icons.book_outlined,
    ),
];

final bookCatalogItemDetailsWorkspaceSortDefinitions = [
  if (BookFieldIdentities.releaseDate.sortable)
    sortFromField<BookKind, BookWorkspaceDto, DateTime>(
      BookCatalogItemDetailsWorkspaceFields.releaseDate,
      defaultAscending: false,
    ),
  if (BookFieldIdentities.pageCount.sortable)
    sortFromField<BookKind, BookWorkspaceDto, num>(
      BookCatalogItemDetailsWorkspaceFields.pageCount,
      group: 'Details',
    ),
];

final bookCatalogItemDetailsWorkspaceDefaultVisibleColumns =
    <LibraryFieldIdRuntime>{
  BookFieldIds.publisher,
  BookFieldIds.releaseDate,
  BookFieldIds.isbn,
};

final bookCatalogItemDetailsWorkspaceColumnDefinitions = [
  columnFromField<BookKind, BookWorkspaceDto, String?>(
      BookCatalogItemDetailsWorkspaceFields.publisher,
      defaultWidth: 140),
  columnFromField<BookKind, BookWorkspaceDto, DateTime?>(
    BookCatalogItemDetailsWorkspaceFields.releaseDate,
    cellValue: (context) => Text(_formatDate(context.dto.releaseDate)),
    defaultWidth: 118,
  ),
  columnFromField<BookKind, BookWorkspaceDto, String?>(
    BookCatalogItemDetailsWorkspaceFields.isbn,
    group: 'Details',
    defaultWidth: 150,
    maxWidth: 240,
  ),
  columnFromField<BookKind, BookWorkspaceDto, String?>(
    BookCatalogItemDetailsWorkspaceFields.format,
    group: 'Details',
    defaultWidth: 110,
  ),
];

String _formatDate(DateTime? value) {
  if (value == null) return '';
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
