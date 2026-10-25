import 'package:collectarr_app/features/library/kinds/game/workspace/columns/game_catalog_workspace_columns.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_catalog_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_ids.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_facets.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_groups.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/sorts/game_workspace_sorts.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_schema.dart';

final gameCatalogItemWorkspaceSchema =
    LibraryWorkspaceSchema<GameKind, GameWorkspaceDto>(
  kindNamespace: 'game',
  fields: [
    ...GameCatalogWorkspaceFields.all,
    ...gameSmartListFacetFields,
  ],
  columns: gameCatalogWorkspaceColumns,
  sorts: [
    ...gameCatalogWorkspaceSorts,
    ...gameCatalogExtraSortDefinitions,
  ],
  groups: gameWorkspaceGroupDefinitions(includePersonal: false),
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
  defaultSort: GameSortIds.platform,
  defaultThenSort: GameSortIds.title,
  defaultGroup: GameGroupIds.platform,
);
