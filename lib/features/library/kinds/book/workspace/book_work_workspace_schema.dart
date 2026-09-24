import 'package:collectarr_app/features/library/kinds/book/workspace/book_ids.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:flutter/material.dart';

abstract final class BookWorkWorkspaceFields {
  static final title = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.title,
    label: 'Title',
    getValue: (dto) => dto.title,
    entityScope: LibraryEntityScope.work,
  );

  static final author = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.author,
    label: 'Author',
    getValue: (dto) => dto.author,
    entityScope: LibraryEntityScope.work,
  );

  static final series = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.series,
    label: 'Series',
    getValue: (dto) => dto.seriesTitle,
    entityScope: LibraryEntityScope.work,
  );

  static final cover =
      LibraryFieldDefinition<BookKind, BookWorkspaceDto, String?>(
    id: BookFieldIds.cover,
    label: 'Cover',
    getValue: (context) => context.dto.coverImageUrl,
    entityScope: LibraryEntityScope.work,
  );

  static final subtitle = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.subtitle,
    label: 'Subtitle',
    getValue: (dto) => dto.subtitle,
    entityScope: LibraryEntityScope.work,
  );

  static final translator = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.translator,
    label: 'Translator',
    getValue: (dto) => dto.translator,
    entityScope: LibraryEntityScope.work,
  );

  static final editor = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.editor,
    label: 'Editor',
    getValue: (dto) => dto.editor,
    entityScope: LibraryEntityScope.work,
  );

  static final illustrator = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.illustrator,
    label: 'Illustrator',
    getValue: (dto) => dto.illustrator,
    entityScope: LibraryEntityScope.work,
  );

  static final coverArtist = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.coverArtist,
    label: 'Cover Artist',
    getValue: (dto) => dto.coverArtist,
    entityScope: LibraryEntityScope.work,
  );

  static final printing = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.printing,
    label: 'Printing',
    getValue: (dto) => dto.printing,
    entityScope: LibraryEntityScope.work,
  );

  static final numberLine = textField<BookKind, BookWorkspaceDto>(
    id: BookFieldIds.numberLine,
    label: 'Number Line',
    getValue: (dto) => dto.numberLine,
    entityScope: LibraryEntityScope.work,
  );
}

final bookWorkWorkspaceFieldDefinitions = [
  BookWorkWorkspaceFields.title,
  BookWorkWorkspaceFields.author,
  BookWorkWorkspaceFields.series,
  BookWorkWorkspaceFields.subtitle,
  BookWorkWorkspaceFields.translator,
  BookWorkWorkspaceFields.editor,
  BookWorkWorkspaceFields.illustrator,
  BookWorkWorkspaceFields.coverArtist,
  BookWorkWorkspaceFields.printing,
  BookWorkWorkspaceFields.numberLine,
  BookWorkWorkspaceFields.cover,
];

final bookWorkWorkspaceGroupDefinitions = [
  groupFromField<BookKind, BookWorkspaceDto, String?>(
    BookWorkWorkspaceFields.author,
    sidebarTitle: 'Authors',
    icon: Icons.person_outline,
  ),
  groupFromField<BookKind, BookWorkspaceDto, String?>(
    BookWorkWorkspaceFields.series,
    sidebarTitle: 'Series',
    icon: Icons.collections_bookmark_outlined,
    sequenceValue: (context) => context.dto.itemNumber,
  ),
];

final bookWorkWorkspaceSortDefinitions = [
  sortFromField<BookKind, BookWorkspaceDto, String>(
      BookWorkWorkspaceFields.title),
  sortFromField<BookKind, BookWorkspaceDto, String>(
      BookWorkWorkspaceFields.author),
];

final bookWorkWorkspaceDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  BookFieldIds.cover,
  BookFieldIds.author,
  BookFieldIds.title,
};

final bookWorkWorkspaceColumnDefinitions = [
  LibraryColumnDefinition<BookKind, BookWorkspaceDto, String?>(
    id: BookFieldIds.cover,
    label: '',
    getValue: BookWorkWorkspaceFields.cover.getValue,
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
      BookWorkWorkspaceFields.author,
      defaultWidth: 150),
  columnFromField<BookKind, BookWorkspaceDto, String?>(
      BookWorkWorkspaceFields.title,
      defaultWidth: 260,
      maxWidth: 520),
  columnFromField<BookKind, BookWorkspaceDto, String?>(
    BookWorkWorkspaceFields.subtitle,
    group: 'Details',
    defaultWidth: 180,
  ),
  columnFromField<BookKind, BookWorkspaceDto, String?>(
    BookWorkWorkspaceFields.translator,
    group: 'Credits',
    defaultWidth: 130,
  ),
  columnFromField<BookKind, BookWorkspaceDto, String?>(
    BookWorkWorkspaceFields.editor,
    group: 'Credits',
    defaultWidth: 130,
  ),
  columnFromField<BookKind, BookWorkspaceDto, String?>(
    BookWorkWorkspaceFields.illustrator,
    group: 'Credits',
    defaultWidth: 130,
  ),
  columnFromField<BookKind, BookWorkspaceDto, String?>(
    BookWorkWorkspaceFields.printing,
    group: 'Edition',
    defaultWidth: 100,
  ),
  columnFromField<BookKind, BookWorkspaceDto, String?>(
    BookWorkWorkspaceFields.numberLine,
    group: 'Edition',
    defaultWidth: 100,
  ),
];

final bookWorkWorkspaceSchema =
    LibraryEntityWorkspaceSchema<BookKind, BookWorkspaceDto>(
  kindNamespace: 'book',
  entityScope: LibraryEntityScope.work,
  fields: bookWorkWorkspaceFieldDefinitions,
  columns: bookWorkWorkspaceColumnDefinitions,
  sorts: bookWorkWorkspaceSortDefinitions,
  groups: bookWorkWorkspaceGroupDefinitions,
  primaryColumn: BookFieldIds.title,
  defaultVisibleColumns: bookWorkWorkspaceDefaultVisibleColumns,
  defaultSort: BookSortIds.author,
  defaultGroup: BookGroupIds.author,
  preferenceCodec: const BookPreferenceCodec(),
);
