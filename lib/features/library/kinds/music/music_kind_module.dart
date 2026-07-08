import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/features/library/kinds/music/music_media_adapter.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/config/library_kind_workspace_behavior.dart';

final musicKindModule = LibraryKindModule(
  type: musicLibraryConfig,
  mediaAdapter: musicMediaAdapter,
  workspaceDtoFactory: MusicWorkspaceDto.fromEntry,
  workspaceBehavior: const LibraryKindWorkspaceBehavior(
    supportsTrackSearch: true,
    usesTrackListCard: true,
  ),
  providerMapper: const MusicLibraryKindProviderMapper(),
  facets: const LibraryFacetModule(loadRows: _loadCharacterFacetRows),
);

Future<List<Map<String, dynamic>>> _loadCharacterFacetRows(
  LibraryFacetRequest request,
) {
  return request.api.characterFacets(request.itemIds);
}
