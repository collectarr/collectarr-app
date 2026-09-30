import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_ids.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_catalog_identity_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_catalog_edition_workspace_fields.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';

/// One field set for a concrete Movie catalog item.
///
/// Identity and edition details are projected together as one Catalog Item.
final movieCatalogItemWorkspaceSchema =
    LibraryEntityWorkspaceSchema<MovieKind, MovieWorkspaceDto>(
  kindNamespace: 'movie',
  entityScope: LibraryEntityScope.work,
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
  preferenceCodec: const MoviePreferenceCodec(),
);
