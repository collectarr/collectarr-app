import 'package:collectarr_app/features/library/kinds/manga/config.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_media_adapter.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_dto.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';

import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_fields.dart';
import 'package:collectarr_app/features/library/kinds/manga/presentation.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

final mangaKindModule = LibraryKindModule(
  type: mangaLibraryConfig,
  mediaAdapter: mangaMediaAdapter,
  workspaceDtoFactory: MangaWorkspaceDto.fromEntry,
  fields: AnyLibraryFieldRegistry(
    groups: mangaLibraryGroupDefinitions,
    sorts: mangaLibrarySortDefinitions,
    columns: mangaLibraryColumnDefinitions,
    defaultVisibleColumnIds: mangaLibraryDefaultVisibleColumnIds,
    defaultSortId: mangaDefaultSortId,
    defaultGroupId: mangaDefaultGroupId,
    customLinkedMetadataCandidates: (entry) sync* {
      yield* AnyLibraryFieldRegistry.nonEmptyStrings(entry.characters);
      yield* AnyLibraryFieldRegistry.nonEmptyStrings(entry.storyArcs);
    },
  ),
  facets: const LibraryFacetModule(
    loadRows: LibraryPageUtilities.libraryFacetRowsForId,
    getFacetValues: _getFacetValues,
  ),
);

Iterable<String> _getFacetValues(LibraryWorkspaceEntry entry, String facetId) {
  if (facetId == 'comic.character' || facetId == 'media.character') {
    return entry.characters ?? const [];
  }
  if (facetId == 'comic.story_arc') {
    return entry.storyArcs ?? const [];
  }
  return const [];
}
