import 'package:collectarr_app/features/library/kinds/game_hardware/workspace/columns/game_hardware_workspace_columns.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/workspace/game_hardware_catalog_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/workspace/game_hardware_ids.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/workspace/game_hardware_personal_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/workspace/game_hardware_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/workspace/game_hardware_workspace_groups.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/workspace/sorts/game_hardware_workspace_sorts.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_schema.dart';

typedef _Catalog = GameHardwareCatalogWorkspaceFields;
typedef _Personal = GameHardwarePersonalWorkspaceFields;

final gameHardwareLibraryEntryWorkspaceSchema =
    LibraryWorkspaceSchema<GameHardwareKind, GameHardwareWorkspaceDto>(
        kindNamespace: 'game_hardware',
        fields: [
          ..._Catalog.all,
          ..._Personal.all,
          _Catalog.frontImage,
          _Catalog.boxImage,
          ..._Personal.money,
        ],
        columns: gameHardwareWorkspaceColumns(personal: true),
        sorts: gameHardwareWorkspaceSorts(personal: true),
        groups: gameHardwareWorkspaceGroupDefinitions<GameHardwareKind>(
            includePersonal: true),
        primaryColumn: _Catalog.title.id,
        defaultVisibleColumns: {
          _Catalog.platformIcon.id,
          _Catalog.platform.id,
          _Catalog.title.id,
          _Catalog.releaseDate.id
        },
        defaultSort: const LibrarySortId('game_hardware.platform'),
        defaultThenSort: const LibrarySortId('game_hardware.title'),
        defaultGroup: const LibraryGroupId<GameHardwareKind, String>(
            'game_hardware.platform'));
