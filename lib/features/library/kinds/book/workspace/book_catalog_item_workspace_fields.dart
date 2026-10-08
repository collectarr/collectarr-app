import 'package:collectarr_app/features/library/kinds/book/workspace/book_ids.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:flutter/material.dart';

abstract final class BookCatalogItemWorkspaceFields {
  static final title = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.title,
    label: 'Title',
    getValue: (dto) => dto.title,
  );

  static final author = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.author,
    label: 'Author',
    getValue: (dto) => dto.author,
    searchable: true,
  );

  static final series = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.series,
    label: 'Series',
    getValue: (dto) => dto.seriesTitle,
  );

  static final cover =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, String?>(
    id: BookFieldIds.cover,
    label: 'Cover',
    getValue: (context) => context.dto.coverImageUrl,
  );

  static final subtitle = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.subtitle,
    label: 'Subtitle',
    getValue: (dto) => dto.subtitle,
    searchable: true,
  );

  static final translator = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.translator,
    label: 'Translator',
    getValue: (dto) => dto.translator,
    searchable: true,
  );

  static final editor = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.editor,
    label: 'Editor',
    getValue: (dto) => dto.editor,
    searchable: true,
  );

  static final illustrator = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.illustrator,
    label: 'Illustrator',
    getValue: (dto) => dto.illustrator,
    searchable: true,
  );

  static final coverArtist = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.coverArtist,
    label: 'Cover Artist',
    getValue: (dto) => dto.coverArtist,
  );
}

final bookCatalogItemWorkspaceFieldDefinitions = [
  BookCatalogItemWorkspaceFields.title,
  BookCatalogItemWorkspaceFields.author,
  BookCatalogItemWorkspaceFields.series,
  BookCatalogItemWorkspaceFields.subtitle,
  BookCatalogItemWorkspaceFields.translator,
  BookCatalogItemWorkspaceFields.editor,
  BookCatalogItemWorkspaceFields.illustrator,
  BookCatalogItemWorkspaceFields.coverArtist,
  BookCatalogItemWorkspaceFields.cover,
];

final bookCatalogItemWorkspaceGroupDefinitions = [
  groupFromField<BookKind, BookWorkspaceDto, String?>(
    BookCatalogItemWorkspaceFields.author,
    sidebarTitle: 'Authors',
    icon: Icons.person_outline,
  ),
  groupFromField<BookKind, BookWorkspaceDto, String?>(
    BookCatalogItemWorkspaceFields.series,
    sidebarTitle: 'Series',
    icon: Icons.collections_bookmark_outlined,
    sequenceValue: (context) => context.dto.itemNumber,
  ),
];

final bookCatalogItemWorkspaceSortDefinitions = [
  sortFromField<BookKind, BookWorkspaceDto, String>(
      BookCatalogItemWorkspaceFields.title),
  sortFromField<BookKind, BookWorkspaceDto, String>(
      BookCatalogItemWorkspaceFields.author),
];

final bookCatalogItemWorkspaceDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  BookFieldIds.cover,
  BookFieldIds.author,
  BookFieldIds.title,
};

final bookCatalogItemWorkspaceColumnDefinitions = [
  LibraryColumnDefinition<BookKind, BookWorkspaceDto, String?>(
    id: BookFieldIds.cover,
    label: '',
    getValue: BookCatalogItemWorkspaceFields.cover.getValue,
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
  columnFromField<BookKind, BookWorkspaceDto, String?>(
      BookCatalogItemWorkspaceFields.author,
      defaultWidth: 150),
  columnFromField<BookKind, BookWorkspaceDto, String?>(
      BookCatalogItemWorkspaceFields.title,
      defaultWidth: 260,
      maxWidth: 520),
  columnFromField<BookKind, BookWorkspaceDto, String?>(
    BookCatalogItemWorkspaceFields.subtitle,
    group: 'Details',
    defaultWidth: 180,
  ),
  columnFromField<BookKind, BookWorkspaceDto, String?>(
    BookCatalogItemWorkspaceFields.translator,
    group: 'Credits',
    defaultWidth: 130,
  ),
  columnFromField<BookKind, BookWorkspaceDto, String?>(
    BookCatalogItemWorkspaceFields.editor,
    group: 'Credits',
    defaultWidth: 130,
  ),
  columnFromField<BookKind, BookWorkspaceDto, String?>(
    BookCatalogItemWorkspaceFields.illustrator,
    group: 'Credits',
    defaultWidth: 130,
  ),
];
