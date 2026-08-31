import 'package:collectarr_app/features/library/kinds/manga/add/manga_add_manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/manga/add/manga_add_manual_draft.dart';
import 'package:collectarr_app/core/api/api_client.dart';
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
import 'package:collectarr_app/features/library/kinds/manga/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/provider/manga_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_card_presentation.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_fields.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';
import 'package:collectarr_app/features/library/kinds/manga/stats/manga_stats_capability.dart';

final mangaKindModule = LibraryKindSpec<MangaWorkspaceDto, MangaOwnedDetails>(
  type: mangaLibraryConfig,
  projector: const MangaWorkspaceProjector(),
  ownedDetailsCodec: const MangaOwnedDetailsCodec(),
  fields: mangaLibraryKindSchema.toRegistry(),
  catalogCodec: const DefaultCatalogKindCodec<MangaMetadata>(
    MangaMetadata.fromJson,
    _encodeMangaMetadata,
  ),
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
    fetchChildrenCallback: _fetchMangaVolumes,
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
  transfer: LibraryTransferCapability(
    kindFields: mangaTransferableFields,
  ),
  stats: const MangaStatsCapability(),
  add: const StandardLibraryAddCapability<MangaAddDraft>(
    kind: CatalogMediaKind.manga,
    initialDraftBuilder: MangaAddDraft.new,
    manualDraftBuilder: MangaAddManualDraft.new,
    manualPaneBuilder: buildMangaAddManualPane,
  ),
  edit: LibraryEditCapability(
    editDialogBuilder: buildMangaLibraryEditDialog,
    editChrome: const LibraryEditChromeConfig(
      titleUsesItemTitle: true,
      synopsisLabel: 'Plot',
      showsIssueBadge: true,
      showsPhysicalFormatBadge: true,
    ),
    mediaFields: const MediaEditFields.print(
      numberLabel: 'Chapter / Vol.',
      publisherLabel: 'Publisher / Studio / Creator',
      releaseDateLabel: 'First published',
    ),
    manualAddUsesTitleAsSeries: true,
    editUsesTitleAsSeries: true,
    releaseFields: const ReleaseEditFields(
      variantLabel: 'Edition / Variant / Format',
      barcodeLabel: 'Barcode / UPC / ISBN',
      variantSeedsPhysicalFormatLabel: true,
    ),
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
    LibraryProjectionRuntime item, LibraryFacetIdRuntime facetId) {
  final kindMetadata = item.source.catalogItem?.kindMetadata;
  final metadata = kindMetadata is MangaMetadata ? kindMetadata : null;
  if (facetId == MangaFacetIds.character) {
    return const [];
  }
  if (facetId == MangaFacetIds.genre) {
    return metadata?.genres ?? const [];
  }
  if (facetId == MangaFacetIds.publisher) {
    final pub = metadata?.publisher;
    return pub != null ? [pub] : const [];
  }
  return const [];
}

Map<String, dynamic> _encodeMangaMetadata(MangaMetadata m) => m.toJson();

String _mangaChildrenTitle(int count) => 'Volumes ($count)';

Future<List<LibraryHierarchyNode>> _fetchMangaVolumes({
  required ApiClient api,
  required String itemId,
  String? provider,
  String? providerItemId,
}) async {
  final volumes = await api
      .getItemVolumes(itemId, kind: CatalogMediaKind.manga.apiValue)
      .timeout(const Duration(seconds: 60));
  return [
    for (final volume in volumes)
      LibraryHierarchyNode(
        id: 'volume_${volume.seasonNumber}',
        label: volume.title,
        secondaryLabel:
            volume.episodeCount != null ? '${volume.episodeCount} items' : null,
        level: LibraryHierarchyLevel.container,
        imageUrl: volume.posterUrl,
        totalCount: volume.episodeCount,
        metadata: {
          'number': volume.seasonNumber,
          'airDate': volume.airDate,
        },
      ),
  ];
}
