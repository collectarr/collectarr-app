import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/config.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_media_adapter.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_dto.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';

import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_fields.dart';
import 'package:collectarr_app/features/library/kinds/manga/presentation.dart';

import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_projector.dart';

final mangaKindModule = LibraryKindSpec<MangaWorkspaceDto, ComicOwnedDetails>(
  type: mangaLibraryConfig,
  mediaAdapter: mangaMediaAdapter,
  projector: const MangaWorkspaceProjector(),
  ownedDetailsCodec: const ComicOwnedDetailsCodec(),
  fields: AnyLibraryFieldRegistry(
    groups: mangaLibraryGroupDefinitions,
    sorts: mangaLibrarySortDefinitions,
    columns: mangaLibraryColumnDefinitions,
    defaultVisibleColumnIds: mangaLibraryDefaultVisibleColumnIds,
    defaultSortId: 'title',
    defaultGroupId: 'series',
    customLinkedMetadataCandidates: (source) sync* {
      yield* AnyLibraryFieldRegistry.nonEmptyStrings(source.catalogItem?.characters);
      yield* AnyLibraryFieldRegistry.nonEmptyStrings(source.catalogItem?.storyArcs);
    },
  ),
  facets: const LibraryFacetModule(
    loadRows: LibraryPageUtilities.libraryFacetRowsForId,
    getFacetValues: _getFacetValues,
  ),
);

Iterable<String> _getFacetValues(LibraryProjectionRuntime item, String facetId) {
  final catalog = item.source.catalogItem;
  if (facetId == 'comic.character' || facetId == 'media.character') {
    return catalog?.characters ?? const [];
  }
  if (facetId == 'comic.story_arc') {
    return catalog?.storyArcs ?? const [];
  }
  return const [];
}
