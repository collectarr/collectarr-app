import 'package:collectarr_app/features/library/kinds/game_toy/workspace/columns/columns.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/workspace/catalog_fields.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/workspace/ids.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/workspace/personal_fields.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/workspace/dto.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/workspace/groups.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/workspace/sorts/sorts.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_schema.dart';

typedef _Catalog = GameToyCatalogWorkspaceFields;
typedef _Personal = GameToyPersonalWorkspaceFields;

final gameToyLibraryEntryWorkspaceSchema = LibraryWorkspaceSchema<GameToyKind,
        GameToyWorkspaceDto>(
    kindNamespace: 'game_toy',
    fields: [..._Catalog.all, ..._Personal.all, ..._Personal.money],
    columns: gameToyWorkspaceColumns(personal: true),
    sorts: gameToyWorkspaceSorts(personal: true),
    groups:
        gameToyWorkspaceGroupDefinitions<GameToyKind>(includePersonal: true),
    primaryColumn: _Catalog.title.id,
    defaultVisibleColumns: {
      _Catalog.title.id,
      _Catalog.releaseDate.id,
      _Catalog.series.id
    },
    defaultSort: const LibrarySortId('game_toy.series'),
    defaultGroup: const LibraryGroupId<GameToyKind, String>('game_toy.series'));
