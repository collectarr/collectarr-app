import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/features/library/kinds/music/music_media_adapter.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_card_presentation.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/config/library_kind_workspace_behavior.dart';

import 'package:collectarr_app/features/library/kinds/music/workspace/music_fields.dart';


import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_projector.dart';

final musicKindModule = LibraryKindSpec<MusicWorkspaceDto, MusicOwnedDetails>(
  type: musicLibraryConfig,

  mediaAdapter: musicMediaAdapter,
  projector: const MusicWorkspaceProjector(),
  ownedDetailsCodec: const MusicOwnedDetailsCodec(),
  fields: AnyLibraryFieldRegistry(
    groups: musicLibraryGroupDefinitions,
    sorts: musicLibrarySortDefinitions,
    columns: musicLibraryColumnDefinitions,
    defaultVisibleColumnIds: musicLibraryDefaultVisibleColumnIds,
    defaultSortId: 'title',
    defaultGroupId: 'series',
    customLinkedMetadataCandidates: (source) sync* {
      yield* AnyLibraryFieldRegistry.nonEmptyStrings([
        source.catalogItem?.publisher,
      ]);
    },
  ),
  workspaceBehavior: const LibraryKindWorkspaceBehavior(
    supportsTrackSearch: true,
  ),
  providerMapper: const MusicLibraryKindProviderMapper(),
  facets: const LibraryFacetModule(
    loadRows: LibraryPageUtilities.libraryFacetRowsForId,
  ),
  buildCardPresentation: buildMusicCardPresentation,
);
