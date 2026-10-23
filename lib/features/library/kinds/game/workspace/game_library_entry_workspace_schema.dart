import 'package:collectarr_app/features/library/kinds/game/workspace/columns/game_catalog_workspace_columns.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/columns/game_workspace_columns.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_catalog_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_ids.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_personal_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_facets.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_groups.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/sorts/game_workspace_sorts.dart';
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
    GameFieldIds.status,
  },
  // Reference defaults: Platform folders, sorted by Platform then Title.
  defaultSort: GameSortIds.platform,
  defaultGroup: GameGroupIds.platform,
);
