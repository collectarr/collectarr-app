import 'package:collectarr_app/features/library/kinds/game/workspace/columns/catalog_columns.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/columns/columns.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/catalog_fields.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/ids.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/personal_fields.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/dto.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/facets.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/groups.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/sorts/sorts.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_schema.dart';

final gameLibraryEntryWorkspaceSchema =
    LibraryWorkspaceSchema<GameKind, GameWorkspaceDto>(
  kindNamespace: 'game',
  // Collection items carry their catalog fields, as in Music: the table
  // resolves columns from this registry alone.
  fields: [
    ...GameCatalogWorkspaceFields.all,
    ...GamePersonalWorkspaceFields.all,
    ...gameSmartListFacetFields,
  ],
  columns: [
    ...gameCatalogWorkspaceColumns,
    ...gamePersonalWorkspaceColumns,
    ...gameLoanWorkspaceColumns,
  ],
  sorts: [
    ...gameCatalogWorkspaceSorts,
    ...gameCatalogExtraSortDefinitions,
    ...gamePersonalWorkspaceSorts,
    ...gamePersonalSortDefinitions,
  ],
  groups: gameWorkspaceGroupDefinitions(includePersonal: true),
  primaryColumn: GameFieldIds.title,
  defaultVisibleColumns: {
    GameFieldIds.platformIcon,
    GameFieldIds.platform,
    GameFieldIds.title,
    GameFieldIds.releaseDate,
    GameFieldIds.publisher,
    GameFieldIds.developer,
    GameFieldIds.genre,
    GameFieldIds.addedAt,
  },
  // Reference defaults: Platform folders, sorted by Platform then Title.
  defaultSort: GameSortIds.platform,
  defaultThenSort: GameSortIds.title,
  defaultGroup: GameGroupIds.platform,
);
