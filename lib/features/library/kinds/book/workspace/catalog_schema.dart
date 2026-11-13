import 'package:collectarr_app/features/library/kinds/book/workspace/ids.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/additional_fields.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/dto.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/catalog_item_fields.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/catalog_item_details_fields.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/facets.dart';
import 'package:collectarr_app/features/library/workspace/config/typed_field_definition.dart';
import 'package:collectarr_app/features/library/config/kind_field_metadata.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/schema.dart';
import 'package:flutter/material.dart';

/// The reference's List columns, in its order; Added Date follows them for
/// collection items.
const bookWorkspaceDefaultColumnOrder = <LibraryFieldIdRuntime>[
  BookFieldIds.author,
  BookFieldIds.title,
  BookFieldIds.isbn,
  BookFieldIds.format,
  BookFieldIds.pageCount,
  BookFieldIds.publisher,
  BookFieldIds.releaseDate,
  BookFieldIds.genre,
];

/// Catalog columns with the reference's defaults first, in its order.
final bookCatalogWorkspaceColumns = () {
  int rank(LibraryColumnDefinition<BookKind, BookWorkspaceDto, dynamic> c) {
    final index = bookWorkspaceDefaultColumnOrder
        .indexWhere((id) => id.sameIdentityAs(c.id));
    return index < 0 ? bookWorkspaceDefaultColumnOrder.length : index;
  }

  final columns = [
    ...bookCatalogItemWorkspaceColumnDefinitions,
    ...bookCatalogItemDetailsWorkspaceColumnDefinitions,
    for (final extra in _catalogExtras) extra.column,
  ];
  return [
    for (var r = 0; r <= bookWorkspaceDefaultColumnOrder.length; r++)
      for (final column in columns)
        if (rank(column) == r) column,
  ];
}();

/// The additional fields read from the catalog; the rest belong to the copy.
final _catalogExtras = [
  for (final extra in bookAdditionalWorkspaceFields)
    if (extra.field.metadata.source == LibraryFieldSource.catalog) extra,
];

final bookCatalogWorkspaceFields = [
  ...bookCatalogItemWorkspaceFieldDefinitions,
  ...bookCatalogItemDetailsWorkspaceFieldDefinitions,
  for (final extra in _catalogExtras) extra.field,
];

final bookCatalogWorkspaceSorts = [
  ...bookCatalogItemWorkspaceSortDefinitions,
  ...bookCatalogItemDetailsWorkspaceSortDefinitions,
  for (final extra in _catalogExtras) extra.sort,
];

final bookCatalogWorkspaceGroups = bookWorkspaceGroupsWith([
  ...bookCatalogItemWorkspaceGroupDefinitions,
  ...bookCatalogItemDetailsWorkspaceGroupDefinitions,
], _catalogExtras);

/// [groups] followed by a folder for each text field of [extras] that has
/// none yet.
List<LibraryGroupDefinition<BookKind, BookWorkspaceDto, dynamic>>
    bookWorkspaceGroupsWith(
  List<LibraryGroupDefinition<BookKind, BookWorkspaceDto, dynamic>> groups,
  Iterable<BookAdditionalWorkspaceField> extras,
) {
  final taken = {for (final group in groups) group.id.value};
  return [
    ...groups,
    for (final extra in extras)
      if (extra.field.metadata.groupable && taken.add(extra.field.id.value))
        groupFromField<BookKind, BookWorkspaceDto, String?>(
          extra.field
              as LibraryFieldDefinition<BookKind, BookWorkspaceDto, String?>,
          sidebarTitle: extra.field.label,
          icon: Icons.folder_outlined,
        ),
  ];
}

/// One Book Catalog Item combines the catalog fields formerly split across
/// the Work and Edition workspace levels.
final bookCatalogItemWorkspaceSchema =
    LibraryWorkspaceSchema<BookKind, BookWorkspaceDto>(
  kindNamespace: 'book',
  fields: [
    ...bookCatalogWorkspaceFields,
    ...bookSmartListFacetFields,
  ],
  columns: bookCatalogWorkspaceColumns,
  sorts: bookCatalogWorkspaceSorts,
  groups: bookCatalogWorkspaceGroups,
  primaryColumn: BookFieldIds.title,
  defaultVisibleColumns: {...bookWorkspaceDefaultColumnOrder},
  // Reference defaults: Author folders, sorted by Author then Title.
  defaultSort: BookSortIds.author,
  defaultThenSort: BookSortIds.title,
  defaultGroup: BookGroupIds.author,
);
