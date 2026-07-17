import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/features/library/kinds/music/music_media_adapter.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/config/library_kind_workspace_behavior.dart';

import 'package:collectarr_app/features/library/kinds/music/workspace/music_fields.dart';

final musicKindModule = LibraryKindModule(
  type: musicLibraryConfig,
  mediaAdapter: musicMediaAdapter,
  workspaceDtoFactory: MusicWorkspaceDto.fromEntry,
  fields: AnyLibraryFieldRegistry(
    groups: musicLibraryGroupDefinitions,
    sorts: musicLibrarySortDefinitions,
    columns: musicLibraryColumnDefinitions,
    defaultVisibleColumnIds: musicLibraryDefaultVisibleColumnIds,
    defaultSortId: 'title',
    defaultGroupId: 'series',
    customLinkedMetadataCandidates: (entry) sync* {
      yield* AnyLibraryFieldRegistry.nonEmptyStrings([
        entry.music?.catalogNumber,
        entry.music?.vinylColor,
        entry.music?.rpm?.toString(),
      ]);
    },
  ),
  workspaceBehavior: const LibraryKindWorkspaceBehavior(
    supportsTrackSearch: true,
    usesTrackListCard: true,
  ),
  providerMapper: const MusicLibraryKindProviderMapper(),
  facets: const LibraryFacetModule(
    loadRows: LibraryPageUtilities.libraryFacetRowsForId,
  ),
);
