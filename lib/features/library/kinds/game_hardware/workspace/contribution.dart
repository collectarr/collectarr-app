import 'package:collectarr_app/features/library/config/library_facet_module.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/workspace/catalog_schema.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/workspace/entry_schema.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/workspace/dto.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/workspace/projector.dart';
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
