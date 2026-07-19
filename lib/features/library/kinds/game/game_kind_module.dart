import 'package:collectarr_app/features/library/kinds/game/config.dart';
import 'package:collectarr_app/features/library/kinds/game/game_media_adapter.dart';
import 'package:collectarr_app/features/library/kinds/game/provider/game_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_card_presentation.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/config/library_kind_workspace_behavior.dart';

import 'package:collectarr_app/features/library/kinds/game/workspace/game_fields.dart';


final gameKindModule = LibraryKindModule(
  type: gamesLibraryConfig,
  mediaAdapter: gamesMediaAdapter,
  workspaceDtoFactory: GameWorkspaceDto.fromEntry,
  fields: AnyLibraryFieldRegistry(
    groups: gameLibraryGroupDefinitions,
    sorts: gameLibrarySortDefinitions,
    columns: gameLibraryColumnDefinitions,
    defaultVisibleColumnIds: gamesLibraryDefaultVisibleColumnIds,
    defaultSortId: 'title',
    defaultGroupId: 'series',
    customLinkedMetadataCandidates: (entry) sync* {
      if (entry.game?.platforms case final platforms?) {
        yield* AnyLibraryFieldRegistry.nonEmptyStrings(platforms);
      } else {
        yield* AnyLibraryFieldRegistry.nonEmptyStrings(entry.rawPlatforms);
      }
    },
  ),
  workspaceBehavior: const LibraryKindWorkspaceBehavior(  ),
  providerMapper: const GameLibraryKindProviderMapper(),
  facets: const LibraryFacetModule(
    loadRows: LibraryPageUtilities.libraryFacetRowsForId,
  ),
  buildCardPresentation: buildGameCardPresentation,
);
