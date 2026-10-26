import 'package:collectarr_app/features/library/config/library_facet_module.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/workspace/catalog_schema.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/workspace/entry_schema.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/workspace/dto.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/workspace/projector.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_workspace.dart';
import 'package:collectarr_app/features/library/tracking/library_tracking_topology.dart';

final gameToyKindWorkspace = TypedLibraryKindWorkspace<GameToyWorkspaceDto>(
    catalogItemWorkspace: TypedLibraryTargetWorkspace(
        fields: gameToyCatalogItemWorkspaceSchema.toRegistry(),
        projector: const GameToyWorkspaceProjector()),
    libraryEntryWorkspace: TypedLibraryTargetWorkspace(
        fields: gameToyLibraryEntryWorkspaceSchema.toRegistry(),
        projector: const GameToyWorkspaceProjector()),
    trackingTopology: const LibraryTrackingTopology());
final gameToyLibraryFacetModule = TypedLibraryFacetModule<GameToyWorkspaceDto>(
    getFacetValues: (dto, facetId) => const []);
