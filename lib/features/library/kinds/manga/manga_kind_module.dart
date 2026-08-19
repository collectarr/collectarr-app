import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/manga/add/manga_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/config.dart';
import 'package:collectarr_app/features/library/kinds/manga/edit/manga_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_media_adapter.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_card_presentation.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_fields.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';

final mangaKindModule = LibraryKindSpec<MangaWorkspaceDto, MangaOwnedDetails>(
  type: mangaLibraryConfig,
  mediaAdapter: mangaMediaAdapter,
  projector: const MangaWorkspaceProjector(),
  ownedDetailsCodec: const MangaOwnedDetailsCodec(),
  fields: mangaLibraryKindSchema.toRegistry(),
  add: const StandardLibraryAddCapability<MangaAddDraft>(
    kind: CatalogMediaKind.manga,
    initialDraftBuilder: MangaAddDraft.new,
  ),
  edit: LibraryEditCapability.fromTypeConfig(
    mangaLibraryConfig,
    createDraft: createMangaEditDraft,
  ),
  facets: const LibraryFacetModule(
    loadRows: LibraryPageUtilities.libraryFacetRowsForId,
    getFacetValues: _getFacetValues,
  ),
  buildCardPresentation: buildMangaCardPresentation,
);

Iterable<String> _getFacetValues(
    LibraryProjectionRuntime item, String facetId) {
  final catalog = item.source.catalogItem;
  if (facetId == 'comic.character' || facetId == 'media.character') {
    return catalog?.characters ?? const [];
  }
  if (facetId == 'comic.story_arc') {
    return catalog?.storyArcs ?? const [];
  }
  return const [];
}
