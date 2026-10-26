import 'package:collectarr_app/features/library/kinds/game/workspace/columns/catalog_columns.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/catalog_fields.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/ids.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/dto.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/facets.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/groups.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/sorts/sorts.dart';
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
