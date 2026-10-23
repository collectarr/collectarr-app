import 'package:collectarr_app/features/library/kinds/game_toy/workspace/columns/game_toy_workspace_columns.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/workspace/game_toy_catalog_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/workspace/game_toy_ids.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/workspace/game_toy_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/workspace/game_toy_workspace_groups.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/workspace/sorts/game_toy_workspace_sorts.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_schema.dart';

typedef _Catalog = GameToyCatalogWorkspaceFields;

final gameToyCatalogItemWorkspaceSchema = LibraryWorkspaceSchema<GameToyKind,
        GameToyWorkspaceDto>(
    kindNamespace: 'game_toy',
    fields: _Catalog.all,
    columns: gameToyWorkspaceColumns(personal: false),
    sorts: gameToyWorkspaceSorts(personal: false),
    groups:
        gameToyWorkspaceGroupDefinitions<GameToyKind>(includePersonal: false),
    primaryColumn: _Catalog.title.id,
    defaultVisibleColumns: {
      _Catalog.title.id,
      _Catalog.releaseDate.id,
      _Catalog.series.id
    },
    defaultSort: const LibrarySortId('game_toy.series'),
    defaultGroup: const LibraryGroupId<GameToyKind, String>('game_toy.series'));
