import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/tv/add/tv_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/config.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit_presentation_builder.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/detail/video_detail_page.dart';
import 'package:collectarr_app/features/library/kinds/tv/inspector_sections.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/provider/tv_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_media_adapter.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_card_presentation.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_fields.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_projector.dart';
import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';

import 'package:collectarr_app/features/library/kinds/tv/stats/tv_stats_capability.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';

final tvKindModule = LibraryKindSpec<TvWorkspaceDto, TvOwnedDetails>(
  type: tvLibraryConfig,
  mediaAdapter: tvMediaAdapter,
  projector: const TvWorkspaceProjector(),
  ownedDetailsCodec: const TvOwnedDetailsCodec(),
  fields: tvLibraryKindSchema.toRegistry(),
  catalogCodec: const DefaultCatalogKindCodec<TvSeriesMetadata>(
    TvSeriesMetadata.fromJson,
    _encodeTvMetadata,
  ),
  identity: const LibraryKindIdentity(
    kind: CatalogMediaKind.tv,
    singularLabel: 'TV Show',
    pluralLabel: 'TV Shows',
    title: 'TV',
    icon: Icons.tv_outlined,
    accent: Color(0xFF00A7A0),
    preferencePrefix: 'tv',
  ),
  metadata: const LibraryMetadataCapability(
    defaultProviderId: 'tmdb',
    providers: [tmdbMetadataProvider],
  ),
  hierarchy: const LibraryHierarchyCapability(
    contentHierarchy: LibraryContentHierarchy.seasons,
    fetchChildrenCallback: _fetchTvSeasons,
    childrenTitleBuilder: _tvChildrenTitle,
    supportsMediaReleaseSplit: true,
    collectionExportTitleLabel: 'Title',
    mediaReleaseScopeLabel: 'Media',
  ),
  inspector: const LibraryInspectorCapability(
    sectionsBuilder: buildTvInspectorSections,
    detailPageBuilder: buildVideoLibraryDetailPage,
    showsDefaultPersonalSection: false,
  ),
  transfer: LibraryTransferCapability(
    kindFields: tvTransferableFields,
  ),
  stats: const TvStatsCapability(),
  add: const StandardLibraryAddCapability<TvAddDraft>(
    kind: CatalogMediaKind.tv,
    initialDraftBuilder: TvAddDraft.new,
  ),
  edit: LibraryEditCapability(
    editDialogBuilder: buildTvLibraryEditDialog,
    presentation: tvLibraryEditPresentation,
    mediaFields: const MediaEditFields(
      numberLabel: 'Edition no.',
      publisherLabel: 'Studio',
      releaseDateLabel: 'First aired',
    ),
    releaseFields: const ReleaseEditFields(
      variantLabel: 'Format / Edition',
      barcodeLabel: 'UPC / Barcode',
    ),
    createDraft: createTvEditDraft,
  ),
  providerMapper: const TvLibraryKindProviderMapper(),
  facets: const LibraryFacetModule(
    loadRows: LibraryPageUtilities.libraryFacetRowsForId,
  ),
  buildCardPresentation: buildTvCardPresentation,
);

String _tvChildrenTitle(int count) => 'Seasons ($count)';

Map<String, dynamic> _encodeTvMetadata(TvSeriesMetadata m) => m.toJson();


Future<List<LibraryHierarchyNode>> _fetchTvSeasons({
  required ApiClient api,
  required String itemId,
  String? provider,
  String? providerItemId,
}) async {
  final seasons = await api
      .getTvSeriesSeasonsDto(itemId)
      .timeout(const Duration(seconds: 60));
  return [
    for (final season in seasons)
      LibraryHierarchyNode(
        id: season.id,
        label: season.title,
        secondaryLabel: season.episodeCount != null
            ? '${season.episodeCount} episodes'
            : null,
        level: LibraryHierarchyLevel.container,
        imageUrl: season.coverImageUrlValue,
        totalCount: season.episodeCount,
        metadata: {
          'seasonNumber': season.seasonNumber,
          'airDate': season.airDateValue?.toIso8601String(),
        },
      ),
  ];
}
