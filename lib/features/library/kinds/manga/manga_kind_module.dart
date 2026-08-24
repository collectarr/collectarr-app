import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/kinds/manga/add/manga_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/config.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/edit/manga_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_media_adapter.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/provider/manga_provider_mapper.dart';
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
  identity: const LibraryKindIdentity(
    kind: CatalogMediaKind.manga,
    singularLabel: 'Manga',
    pluralLabel: 'Manga',
    title: 'Manga',
    icon: Icons.import_contacts_outlined,
    accent: Color(0xFFFF6F91),
    preferencePrefix: 'manga',
  ),
  metadata: LibraryMetadataCapability(
    defaultProviderId: 'hardcover',
    providers: [
      hardcoverMetadataProvider,
      comicVineMetadataProvider,
      anilistMetadataProvider,
      mangadexMetadataProvider,
    ],
  ),
  hierarchy: const LibraryHierarchyCapability(
    contentHierarchy: LibraryContentHierarchy.volumes,
    childrenTitleBuilder: _mangaChildrenTitle,
    supportsSeriesSubgroups: true,
    supportsMediaReleaseSplit: true,
    supportsIndexReassignment: true,
    collectionExportTitleLabel: 'Series',
    mediaReleaseScopeLabel: 'Series',
  ),
  inspector: const LibraryInspectorCapability(
    showsDefaultPersonalSection: false,
  ),
  transfer: const LibraryTransferCapability(),
  add: const StandardLibraryAddCapability<MangaAddDraft>(
    kind: CatalogMediaKind.manga,
    initialDraftBuilder: MangaAddDraft.new,
  ),
  edit: LibraryEditCapability.fromTypeConfig(
    mangaLibraryConfig,
    createDraft: createMangaEditDraft,
  ),
  providerMapper: const MangaLibraryKindProviderMapper(),
  facets: const LibraryFacetModule(
    loadRows: LibraryPageUtilities.libraryFacetRowsForId,
    getFacetValues: _getFacetValues,
  ),
  buildCardPresentation: buildMangaCardPresentation,
);

Iterable<String> _getFacetValues(
    LibraryProjectionRuntime item, String facetId) {
  final kindMetadata = item.source.catalogItem?.kindMetadata;
  final metadata = kindMetadata is MangaMetadata ? kindMetadata : null;
  if (facetId == MangaFacetIds.character.value) {
    return const [];
  }
  if (facetId == MangaFacetIds.genre.value) {
    return metadata?.genres ?? const [];
  }
  if (facetId == MangaFacetIds.publisher.value) {
    final pub = metadata?.publisher;
    return pub != null ? [pub] : const [];
  }
  return const [];
}

String _mangaChildrenTitle(int count) => 'Volumes ($count)';
