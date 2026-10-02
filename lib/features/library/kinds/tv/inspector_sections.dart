import 'package:collectarr_app/features/library/kinds/tv/data/tv_collection_item_projection.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/detail/library_detail_hero.dart';
import 'package:collectarr_app/features/library/detail/library_detail_user_links_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/contributors_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/metadata_fact_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/personal_status_section.dart';
import 'package:collectarr_app/features/library/detail/library_external_links_section.dart';
import 'package:collectarr_app/features/library/kinds/tv/inspector/episode_grid_section.dart';
import 'package:collectarr_app/features/library/kinds/tv/inspector/session_history_section.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_progress_section.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_episode_rating_section.dart';
import 'package:collectarr_app/features/library/kinds/tv/hierarchy/tv_upcoming_episodes_section.dart';
import 'package:collectarr_app/features/library/tracking/session_history_section.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_chrome.dart';
import 'package:collectarr_app/features/library/details/library_detail_panel_scaffold.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_catalog_data.dart';
import 'package:flutter/material.dart';

List<Widget> buildTvCatalogItemInspectorSections(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  return _buildTvEntitySections(
    context,
    request,
    includeSeriesSections: true,
    includePersonalStatus: false,
  );
}

List<Widget> buildTvCopyInspectorSections(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  return [
    ..._buildTvEntitySections(
      context,
      request,
      includeSeriesSections: false,
      includePersonalStatus: true,
    ),
  ];
}

List<Widget> _buildTvEntitySections(
  BuildContext context,
  LibraryInspectorRequest request, {
  required bool includeSeriesSections,
  required bool includePersonalStatus,
}) {
  final specs = _buildTvInspectorSectionSpecs(
    context,
    request,
    includeSeriesSections: includeSeriesSections,
    includePersonalStatus: includePersonalStatus,
  );
  return [
    for (final spec in specs) ...spec.children,
  ];
}

Widget buildTvCatalogItemInspectorHero(
  BuildContext context,
  LibraryInspectorRequest request,
) =>
    LibraryDetailHero(
      type: request.type,
      item: request.item,
      collectionItem: request.collectionItem,
      ownedCopies: request.ownedCopies,
      accent: request.accent,
    );

Widget buildTvCopyInspectorHero(
  BuildContext context,
  LibraryInspectorRequest request,
) =>
    LibraryDetailHero(
      type: request.type,
      item: request.item,
      collectionItem: request.collectionItem,
      ownedCopies: [
        if (request.collectionItem != null) request.collectionItem!,
      ],
      accent: request.accent,
    );

List<LibraryDetailSectionSpec> _buildTvInspectorSectionSpecs(
  BuildContext context,
  LibraryInspectorRequest request, {
  required bool includeSeriesSections,
  bool includePersonalStatus = false,
}) {
  final item = request.item;
  final dto = item.dto;
  final catalog = item.source.catalogData;
  final metadata = catalog is TvWorkspaceCatalogData ? catalog.metadata : null;
  final catalogRef = CatalogEntityRef(
    kind: request.type.kind,
    entityType: CatalogEntityTypeId.catalogItem,
    id: item.source.itemId,
  );

  final tvLinks = metadata?.links ?? const <TrailerLinkDto>[];

  final collectionItem =
      TvCollectionItemProjection.fromDispatch(request.collectionItemDispatch);
  final tvDto = dto is TvWorkspaceDto ? dto : null;
  final facts = <LibraryDetailField>[
    LibraryDetailField(label: 'Display title', value: dto.primaryLabel),
    if (tvDto?.publisher?.trim().isNotEmpty == true)
      LibraryDetailField(label: 'Studio', value: tvDto!.publisher!),
    if (tvDto?.seasonCount != null)
      LibraryDetailField(
          label: 'Seasons', value: tvDto!.seasonCount.toString()),
    if (tvDto?.episodeCount != null)
      LibraryDetailField(
        label: 'Episodes',
        value: tvDto!.episodeCount.toString(),
      ),
    if (tvDto?.format?.trim().isNotEmpty == true)
      LibraryDetailField(label: 'Format', value: tvDto!.format!),
    if (collectionItem?.condition?.trim().isNotEmpty == true)
      LibraryDetailField(label: 'Condition', value: collectionItem!.condition!),
    if (tvLinks.isNotEmpty)
      LibraryDetailField(label: 'Trailers', value: tvLinks.length.toString()),
  ];

  return <LibraryDetailSectionSpec>[
    LibraryDetailSectionSpec(
      slot: LibraryDetailSectionSlot.identity,
      title: 'Catalog Item',
      children: [
        InspectorMetadataFactsSection(
          title: 'Catalog Item',
          accent: request.accent,
          facts: facts,
        ),
      ],
    ),
    if (includeSeriesSections)
      LibraryDetailSectionSpec(
        slot: LibraryDetailSectionSlot.metadata,
        title: 'Episodes',
        headerActions: [
          if (request.onEdit != null)
            _editSectionAction(
              request.onEdit!,
              tooltip: 'Edit TV Catalog Item',
            ),
        ],
        children: [
          InspectorEpisodeGridSection(
            seriesRef: catalogRef,
            kind: request.type.kind.apiValue,
            accent: request.accent,
            itemId: item.source.itemId,
          ),
        ],
      ),
    if (includeSeriesSections)
      LibraryDetailSectionSpec(
        slot: LibraryDetailSectionSlot.progress,
        title: 'TV progress',
        children: [
          VideoProgressSection(
            seriesRef: catalogRef,
            accent: request.accent,
          ),
          const SizedBox(height: 8),
          TvEpisodeRatingDisplaySection(
            itemId: item.source.itemId,
            accent: request.accent,
          ),
          const SizedBox(height: 8),
        ],
      ),
    LibraryDetailSectionSpec(
      slot: LibraryDetailSectionSlot.relations,
      title: 'Contributors',
      headerActions: [
        if (request.onEdit != null)
          _editSectionAction(
            request.onEdit!,
            tooltip: 'Edit cast and crew',
          ),
      ],
      children: [InspectorContributorsSection(request: request)],
    ),
    LibraryDetailSectionSpec(
      slot: LibraryDetailSectionSlot.links,
      title: 'Links / trailers',
      children: [
        LibraryExternalLinksSection(
          title: 'External links',
          links: tvLinks,
          accent: request.accent,
        ),
        const SizedBox(height: 8),
        LibraryDetailUserLinksSection(
          catalogRef: catalogRef,
          accent: request.accent,
        ),
        const SizedBox(height: 8),
        TvUpcomingEpisodesSection(
          seriesRef: catalogRef,
          accent: request.accent,
        ),
      ],
    ),
    LibraryDetailSectionSpec(
      slot: LibraryDetailSectionSlot.activity,
      title: 'History',
      children: [
        InspectorSessionHistorySection(
          request: request,
          catalogRef: catalogRef,
        ),
        if (includePersonalStatus &&
            (request.collectionItem != null || request.trackingSummary != null))
          InspectorPersonalStatusSection(
            type: request.type,
            item: request.item,
            collectionItem: request.collectionItem,
            collectionItemDispatch: request.collectionItemDispatch,
            trackingSummary: request.trackingSummary,
            accent: request.accent,
            onFilterByValue: request.onFilterByValue,
          ),
      ],
    ),
  ];
}

Widget _editSectionAction(
  VoidCallback onPressed, {
  required String tooltip,
}) {
  return Tooltip(
    message: tooltip,
    child: SizedBox(
      width: 30,
      height: 30,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
        onPressed: onPressed,
        child: const Icon(Icons.edit_outlined, size: 16),
      ),
    ),
  );
}

Widget buildTvInspectorPanel(
  BuildContext context,
  LibraryInspectorPanelRequest request,
) {
  final item = request.inspector.item;
  final accent = request.inspector.accent;

  return LibraryDetailPanelScaffold(
    accent: accent,
    toolbar: InspectorUnifiedToolbar(
      item: item,
      detailsLayout: request.inspector.detailsLayout,
      onEdit: request.onEdit,
      onShare: request.onShare,
      onDuplicate: request.onDuplicate,
      onToggleOwned: request.onToggleOwned,
      onLoan: request.onLoan,
      onRefreshMetadata: request.onRefreshMetadata,
      onUnlinkFromCore: request.onUnlinkFromCore,
      onDetailsLayoutChanged: request.onDetailsLayoutChanged,
    ),
    hero: const SizedBox.shrink(),
    sections: _buildTvInspectorSectionSpecs(
      context,
      request.inspector,
      includeSeriesSections: true,
      includePersonalStatus: true,
    ),
  );
}
