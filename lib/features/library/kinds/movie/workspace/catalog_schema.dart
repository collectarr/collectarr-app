import 'package:collectarr_app/features/library/kinds/movie/workspace/ids.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/dto.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/catalog_identity_fields.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/catalog_edition_fields.dart';
import 'package:collectarr_app/features/library/workspace/config/typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/schema.dart';

/// One field set for a concrete Movie catalog item.
///
/// Identity and edition details are projected together as one Catalog Item.
final movieCatalogItemWorkspaceSchema =
    LibraryWorkspaceSchema<MovieKind, MovieWorkspaceDto>(
  kindNamespace: 'movie',
  fields: [
    ...movieCatalogIdentityFieldDefinitions,
    ...movieCatalogEditionFieldDefinitions,
  ],
  columns: [
    ...movieCatalogIdentityColumnDefinitions,
    ...movieCatalogEditionColumnDefinitions,
  ],
  sorts: [
    ...movieCatalogIdentitySortDefinitions,
    ...movieCatalogEditionSortDefinitions,
  ],
  groups: [
    ...movieCatalogIdentityGroupDefinitions,
    ...movieCatalogEditionGroupDefinitions,
  ],
  primaryColumn: MovieFieldIds.title,
  defaultVisibleColumns: {
    ...movieCatalogIdentityDefaultVisibleColumns,
    ...movieCatalogEditionDefaultVisibleColumns,
  },
  defaultSort: MovieSortIds.director,
  defaultGroup: MovieGroupIds.director,
);
