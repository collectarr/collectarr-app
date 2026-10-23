import 'package:collectarr_app/features/library/config/library_facet_module.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/workspace/game_hardware_catalog_item_workspace_schema.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/workspace/game_hardware_library_entry_workspace_schema.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/workspace/game_hardware_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/workspace/game_hardware_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_workspace.dart';
import 'package:collectarr_app/features/library/tracking/library_tracking_topology.dart';

final gameHardwareKindWorkspace =
    TypedLibraryKindWorkspace<GameHardwareWorkspaceDto>(
        catalogItemWorkspace: TypedLibraryTargetWorkspace(
            fields: gameHardwareCatalogItemWorkspaceSchema.toRegistry(),
            projector: const GameHardwareWorkspaceProjector()),
        libraryEntryWorkspace: TypedLibraryTargetWorkspace(
            fields: gameHardwareLibraryEntryWorkspaceSchema.toRegistry(),
            projector: const GameHardwareWorkspaceProjector()),
        trackingTopology: const LibraryTrackingTopology());
final gameHardwareLibraryFacetModule =
    TypedLibraryFacetModule<GameHardwareWorkspaceDto>(
        getFacetValues: (dto, facetId) => const []);
