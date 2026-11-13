import 'package:collectarr_app/core/utils/text_utils.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/ids.dart';
import 'package:collectarr_app/features/library/kinds/book/config/field_identities.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_bucket_mutators.dart';
import 'package:collectarr_app/features/library/workspace/config/typed_field_definition.dart';
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
  for (final (id, label, value)
      in <(String, String, Object? Function(BookWorkspaceDto))>[
    ('book.genre', 'Genre', (dto) => dto.metadata.genres),
    ('book.subject', 'Subject', (dto) => dto.metadata.subjects),
    ('book.country', 'Country', (dto) => dto.country),
    ('book.language', 'Language', (dto) => dto.language),
  ])
    LibraryGroupDefinition<BookKind, BookWorkspaceDto, Object?>(
      id: LibraryGroupId<BookKind, Object?>(id),
      label: label,
      sidebarTitle: label,
      icon: Icons.folder_outlined,
      getValue: (context) => value(context.dto),
    ),
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
  for (final field in [
    BookCatalogItemDetailsWorkspaceFields.publisher,
    BookCatalogItemDetailsWorkspaceFields.format,
    BookCatalogItemDetailsWorkspaceFields.isbn
  ])
    sortFromField<BookKind, BookWorkspaceDto, String>(field),
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
    cellValue: (context) => Text(formatIsoDate(context.dto.releaseDate)),
    defaultWidth: 118,
  ),
  columnFromField<BookKind, BookWorkspaceDto, String?>(
    BookCatalogItemDetailsWorkspaceFields.isbn,
    group: 'Details',
    defaultWidth: 150,
    maxWidth: 240,
  ),
  columnFromField<BookKind, BookWorkspaceDto, num?>(
    BookCatalogItemDetailsWorkspaceFields.pageCount,
    group: 'Details',
    isNumeric: true,
    defaultWidth: 90,
  ),
  columnFromField<BookKind, BookWorkspaceDto, String?>(
    BookCatalogItemDetailsWorkspaceFields.format,
    group: 'Details',
    defaultWidth: 110,
  ),
];
