import 'package:collectarr_app/features/library/kinds/book/workspace/ids.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/dto.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/catalog_item_fields.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/catalog_item_details_fields.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/facets.dart';
import 'package:collectarr_app/features/library/workspace/config/typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/schema.dart';

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
  ];
  return [
    for (var r = 0; r <= bookWorkspaceDefaultColumnOrder.length; r++)
      for (final column in columns)
        if (rank(column) == r) column,
  ];
}();

final bookCatalogWorkspaceFields = [
  ...bookCatalogItemWorkspaceFieldDefinitions,
  ...bookCatalogItemDetailsWorkspaceFieldDefinitions,
];

final bookCatalogWorkspaceSorts = [
  ...bookCatalogItemWorkspaceSortDefinitions,
  ...bookCatalogItemDetailsWorkspaceSortDefinitions,
];

final bookCatalogWorkspaceGroups = [
  ...bookCatalogItemWorkspaceGroupDefinitions,
  ...bookCatalogItemDetailsWorkspaceGroupDefinitions,
];

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
