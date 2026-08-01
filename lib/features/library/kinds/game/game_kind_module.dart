import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/kinds/game/config.dart';
import 'package:collectarr_app/features/library/kinds/game/game_media_adapter.dart';
import 'package:collectarr_app/features/library/kinds/game/provider/game_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_card_presentation.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/config/library_kind_workspace_behavior.dart';

import 'package:collectarr_app/features/library/kinds/game/workspace/game_fields.dart';


import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_projector.dart';

final gameKindModule = LibraryKindSpec<GameWorkspaceDto, GameOwnedDetails>(
  type: gamesLibraryConfig,
  mediaAdapter: gamesMediaAdapter,
  projector: const GameWorkspaceProjector(),
  ownedDetailsCodec: const GameOwnedDetailsCodec(),
  fields: AnyLibraryFieldRegistry(
    groups: gameLibraryGroupDefinitions,
    sorts: gameLibrarySortDefinitions,
    columns: gameLibraryColumnDefinitions,
    defaultVisibleColumnIds: gamesLibraryDefaultVisibleColumnIds,
    defaultSortId: 'title',
    defaultGroupId: 'series',
    customLinkedMetadataCandidates: (source) sync* {
      yield* AnyLibraryFieldRegistry.nonEmptyStrings(source.catalogItem?.platforms);
    },
  ),
  workspaceBehavior: const LibraryKindWorkspaceBehavior(  ),
  providerMapper: const GameLibraryKindProviderMapper(),
  facets: const LibraryFacetModule(
    loadRows: LibraryPageUtilities.libraryFacetRowsForId,
  ),
  buildCardPresentation: buildGameCardPresentation,
);
