import 'package:collectarr_app/features/library/kinds/book/workspace/book_ids.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_catalog_item_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_catalog_item_details_workspace_fields.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_schema.dart';

/// One Book Catalog Item combines the catalog fields formerly split across
/// the Work and Edition workspace levels.
final bookCatalogItemWorkspaceSchema =
    LibraryWorkspaceSchema<BookKind, BookWorkspaceDto>(
  kindNamespace: 'book',
  fields: [
    ...bookCatalogItemWorkspaceFieldDefinitions,
    ...bookCatalogItemDetailsWorkspaceFieldDefinitions,
  ],
  columns: [
    ...bookCatalogItemWorkspaceColumnDefinitions,
    ...bookCatalogItemDetailsWorkspaceColumnDefinitions,
  ],
  sorts: [
    ...bookCatalogItemWorkspaceSortDefinitions,
    ...bookCatalogItemDetailsWorkspaceSortDefinitions,
  ],
  groups: [
    ...bookCatalogItemWorkspaceGroupDefinitions,
    ...bookCatalogItemDetailsWorkspaceGroupDefinitions,
  ],
  primaryColumn: BookFieldIds.title,
  defaultVisibleColumns: {
    ...bookCatalogItemWorkspaceDefaultVisibleColumns,
    ...bookCatalogItemDetailsWorkspaceDefaultVisibleColumns,
  },
  defaultSort: BookSortIds.author,
  defaultGroup: BookGroupIds.author,
);
