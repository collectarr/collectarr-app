import 'package:collectarr_app/features/library/kinds/game_hardware/workspace/columns/columns.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/workspace/catalog_fields.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/workspace/ids.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/workspace/dto.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/workspace/groups.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/workspace/sorts/sorts.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_schema.dart';

typedef _Catalog = GameHardwareCatalogWorkspaceFields;

final gameHardwareCatalogItemWorkspaceSchema =
    LibraryWorkspaceSchema<GameHardwareKind, GameHardwareWorkspaceDto>(
        kindNamespace: 'game_hardware',
        fields: [..._Catalog.all, _Catalog.frontImage, _Catalog.boxImage],
        columns: gameHardwareWorkspaceColumns(personal: false),
        sorts: gameHardwareWorkspaceSorts(personal: false),
        groups: gameHardwareWorkspaceGroupDefinitions<GameHardwareKind>(
            includePersonal: false),
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
