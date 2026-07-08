import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/details/library_inspector_title_card.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_panel_scaffold.dart';
import 'package:collectarr_app/features/library/details/library_detail_section_builder.dart';
import 'package:collectarr_app/features/library/detail/library_detail_user_links_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/contributors_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/episode_grid_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/metadata_fact_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/releases_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/session_history_section.dart';
import 'package:collectarr_app/features/library/media/video/video_external_links_section.dart';
import 'package:collectarr_app/features/library/media/video/video_progress_section.dart';
import 'package:collectarr_app/features/library/media/video/video_upcoming_episodes_section.dart';
import 'package:collectarr_app/features/library/media/video/watch_history_section.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_chrome.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_inspector.dart';
import 'package:flutter/material.dart';

List<Widget> buildTvInspectorSections(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  return buildLibraryDetailSectionWidgets(
    _buildTvInspectorSectionSpecs(context, request),
    accentColor: request.accent,
  );
}

List<LibraryDetailSectionSpec> _buildTvInspectorSectionSpecs(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  final seriesRef = CatalogEntityRef(
    kind: request.type.workspace.kind.apiValue,
    entityType: CatalogEntityType.work,
    id: request.entry.id,
  );
  final releaseOptions = [
    for (final edition in request.entry.editions)
      WatchHistoryTargetOption(
        ref: CatalogEntityRef(
          kind: seriesRef.kind,
          entityType: CatalogEntityType.release,
          id: '${seriesRef.id}:release:${edition.id}',
        ),
        label: edition.title,
        subtitle: [
          if (edition.format?.trim().isNotEmpty == true) edition.format!,
          if (edition.releaseDate != null)
            edition.releaseDate!.toLocal().toIso8601String().split('T').first,
        ].join(' • '),
      ),
  ];

  final entry = request.entry;
  final ownedItem = request.ownedItem;
  final trackingEntry = request.trackingEntry;
  final aliases = <String>{
    if (entry.originalTitle?.trim().isNotEmpty == true) entry.originalTitle!.trim(),
    if (entry.localizedTitle?.trim().isNotEmpty == true &&
        entry.localizedTitle!.trim() != entry.resolvedTitle.trim())
      entry.localizedTitle!.trim(),
    ...?entry.searchAliases,
  }.toList(growable: false);
  final genreValues = entry.genres ?? const <String>[];
  final creatorNames = <String>[
    for (final credit in entry.creators ?? const <Map<String, dynamic>>[])
      if (credit['name']?.toString().trim().isNotEmpty == true)
        credit['name'].toString().trim(),
  ];
  final facts = <LibraryInspectorFactData>[
    LibraryInspectorFactData('Display title', entry.resolvedTitle),
    if (entry.originalTitle?.trim().isNotEmpty == true)
      LibraryInspectorFactData('Original title', entry.originalTitle!),
    if (entry.publisher?.trim().isNotEmpty == true)
      LibraryInspectorFactData('Studio', entry.publisher!),
    LibraryInspectorFactData('Releases', entry.editions.length.toString()),
    if (entry.video?.nrDiscs != null)
      LibraryInspectorFactData('Discs', entry.video!.nrDiscs.toString()),
    if (entry.video?.runtimeMinutes != null)
      LibraryInspectorFactData('Runtime', '${entry.video!.runtimeMinutes} min'),
    if (entry.video?.color?.trim().isNotEmpty == true)
      LibraryInspectorFactData('HDR / color', entry.video!.color!),
    if (entry.video?.screenRatio?.trim().isNotEmpty == true)
      LibraryInspectorFactData('Screen ratio', entry.video!.screenRatio!),
    if (entry.video?.audioTracks?.trim().isNotEmpty == true)
      LibraryInspectorFactData('Audio', entry.video!.audioTracks!),
    if (entry.video?.subtitles?.trim().isNotEmpty == true)
      LibraryInspectorFactData('Subtitles', entry.video!.subtitles!),
    if (entry.video?.layers?.trim().isNotEmpty == true)
      LibraryInspectorFactData('Layers', entry.video!.layers!),
    if (ownedItem?.condition?.trim().isNotEmpty == true)
      LibraryInspectorFactData('Condition', ownedItem!.condition!),
    if (trackingEntry?.episodeRatings.isNotEmpty == true)
      LibraryInspectorFactData(
        'Rated episodes',
        trackingEntry!.episodeRatings.length.toString(),
      ),
    if (request.entry.trailerUrls.isNotEmpty)
      LibraryInspectorFactData(
        'Trailers',
        request.entry.trailerUrls.length.toString(),
      ),
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
          children: [
            if (genreValues.isNotEmpty) ...[
              LibraryInspectorChipWrap(
                label: 'Genres',
                values: genreValues,
                onValueTap: request.onFilterByValue,
              ),
            ],
            if (creatorNames.isNotEmpty) ...[
              const SizedBox(height: 8),
              LibraryInspectorChipWrap(
                label: 'Cast / credits',
                values: creatorNames,
                onValueTap: request.onFilterByValue,
              ),
            ],
            if (aliases.isNotEmpty) ...[
              const SizedBox(height: 8),
              LibraryInspectorChipWrap(
                label: 'Search aliases',
                values: aliases,
                onValueTap: request.onFilterByValue,
              ),
            ],
          ],
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
          itemId: request.entry.id,
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
          links: request.entry.trailerUrls,
          accent: request.accent,
        ),
        const SizedBox(height: 8),
        LibraryDetailUserLinksSection(
          itemId: request.entry.id,
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
  final entry = request.inspector.entry;
  final accent = request.inspector.accent;

  return LibraryDetailPanelScaffold(
    accent: accent,
    toolbar: InspectorUnifiedToolbar(
      entry: entry,
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
    hero: LibraryInspectorTitleCard(
      entry: entry,
      eyebrow: entry.series?.seriesTitle?.trim(),
      accent: accent,
    ),
    sections: _buildTvInspectorSectionSpecs(context, request.inspector),
  );
}
