import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/detail/library_detail_user_links_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/contributors_section.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/kinds/tv/inspector/episode_grid_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/metadata_fact_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/releases_section.dart';
import 'package:collectarr_app/features/library/kinds/tv/inspector/session_history_section.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/video_external_links_section.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/video_progress_section.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/video_upcoming_episodes_section.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/watch_history_section.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_chrome.dart';
import 'package:collectarr_app/features/library/details/library_detail_panel_scaffold.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:flutter/material.dart';

List<Widget> buildTvInspectorSections(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  final specs = _buildTvInspectorSectionSpecs(context, request);
  final widgets = <Widget>[];
  for (final spec in specs) {
    widgets.addAll(spec.children);
  }
  return widgets;
}

List<LibraryDetailSectionSpec> _buildTvInspectorSectionSpecs(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  final item = request.item;
  final dto = item.dto;
  final catalogItem = item.source.catalogItem;
  final seriesRef = CatalogEntityRef(
    kind: request.type.workspace.kind.apiValue,
    entityType: CatalogEntityType.work,
    id: item.node.titleItemId,
  );
  final rawEditions = ((catalogItem?.kindMetadata.toSyncPayload()['editions'] as List?)
          ?.whereType<Map>()
          .map((e) => CatalogEdition.fromJson(Map<String, dynamic>.from(e)))
          .toList() ??
      const <CatalogEdition>[]);
  final releaseOptions = [
    for (final edition in rawEditions)
      WatchHistoryTargetOption(
        ref: CatalogEntityRef(
          kind: seriesRef.kind,
          entityType: CatalogEntityType.release,
          id: '${seriesRef.id}:release:${edition.id}',
        ),
        label: edition.title.isEmpty ? edition.id : edition.title,
        subtitle: [
          if (edition.format?.trim().isNotEmpty == true) edition.format!,
          if (edition.releaseDate != null)
            edition.releaseDate!.toLocal().toIso8601String().split('T').first,
        ].join(' • '),
      ),
  ];

  final tvLinks = (catalogItem?.kindMetadata is TvSeriesMetadata
          ? (catalogItem!.kindMetadata as TvSeriesMetadata).links
          : (catalogItem?.kindMetadata.toSyncPayload()['trailer_urls'] as List?)
              ?.whereType<Map>()
              .map((e) => TrailerLink.fromJson(Map<String, dynamic>.from(e)))
              .toList()) ??
      const <TrailerLink>[];

  final ownedItem = request.ownedItem;
  final trackingEntry = request.trackingEntry;
  final facts = <LibraryDetailField>[
    LibraryDetailField(label: 'Display title', value: dto.title),
    if (dto.publisher?.trim().isNotEmpty == true)
      LibraryDetailField(label: 'Studio', value: dto.publisher!),
    LibraryDetailField(
        label: 'Releases',
        value: rawEditions.length.toString()),
    if (ownedItem?.condition?.trim().isNotEmpty == true)
      LibraryDetailField(label: 'Condition', value: ownedItem!.condition!),
    if (trackingEntry?.episodeRatings.isNotEmpty == true)
      LibraryDetailField(
          label: 'Rated episodes',
          value: trackingEntry!.episodeRatings.length.toString()),
    if (tvLinks.isNotEmpty)
      LibraryDetailField(
          label: 'Trailers', value: tvLinks.length.toString()),
  ];

  return <LibraryDetailSectionSpec>[
    LibraryDetailSectionSpec(
      slot: LibraryDetailSectionSlot.identity,
      title: 'Series metadata',
      children: [
        InspectorMetadataFactsSection(
          title: 'Series metadata',
          accent: request.accent,
          facts: facts,
        ),
      ],
    ),
    LibraryDetailSectionSpec(
      slot: LibraryDetailSectionSlot.formatEditionRelease,
      title: 'Episodes',
      headerActions: [
        if (request.onEdit != null)
          _editSectionAction(
            request.onEdit!,
            tooltip: 'Edit TV series',
          ),
      ],
      children: [
        InspectorEpisodeGridSection(
          seriesRef: seriesRef,
          kind: request.type.workspace.kind.apiValue,
          accent: request.accent,
          itemId: item.node.titleItemId,
        ),
      ],
    ),
    LibraryDetailSectionSpec(
      slot: LibraryDetailSectionSlot.progressOwnership,
      title: 'TV progress',
      children: [
        VideoProgressSection(
          seriesRef: seriesRef,
          accent: request.accent,
        ),
        const SizedBox(height: 8),
        InspectorReleasesSection(request: request),
      ],
    ),
    LibraryDetailSectionSpec(
      slot: LibraryDetailSectionSlot.people,
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
      slot: LibraryDetailSectionSlot.seriesLinks,
      title: 'Links / trailers',
      children: [
        VideoExternalLinksSection(
          title: 'External links',
          links: tvLinks,
          accent: request.accent,
        ),
        const SizedBox(height: 8),
        LibraryDetailUserLinksSection(
          itemId: request.item.node.titleItemId,
          accent: request.accent,
        ),
        const SizedBox(height: 8),
        VideoUpcomingEpisodesSection(
          seriesRef: seriesRef,
          accent: request.accent,
        ),
      ],
    ),
    LibraryDetailSectionSpec(
      slot: LibraryDetailSectionSlot.activityHistory,
      title: 'History',
      children: [
        InspectorSessionHistorySection(
          request: request,
          seriesRef: seriesRef,
          releaseOptions: releaseOptions,
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
    sections: _buildTvInspectorSectionSpecs(context, request.inspector),
  );
}
