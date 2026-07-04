import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/inspector/sections/contributors_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/episode_grid_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/links_trailers_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/metadata_fact_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/releases_section.dart';
import 'package:collectarr_app/features/library/inspector/sections/session_history_section.dart';
import 'package:collectarr_app/features/library/kinds/video/watch_history_section.dart';
import 'package:collectarr_app/features/library/kinds/video/video_inspector_panel.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_inspector.dart';
import 'package:flutter/material.dart';

List<Widget> buildTvInspectorSections(
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
    if (ownedItem?.condition?.trim().isNotEmpty == true)
      LibraryInspectorFactData('Condition', ownedItem!.condition!),
    if (trackingEntry?.episodeRatings.isNotEmpty == true)
      LibraryInspectorFactData(
        'Rated episodes',
        trackingEntry!.episodeRatings.length.toString(),
      ),
  ];

  return [
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
    InspectorEpisodeGridSection(
      seriesRef: seriesRef,
      kind: request.type.workspace.kind.apiValue,
      accent: request.accent,
      itemId: request.entry.id,
    ),
    InspectorSessionHistorySection(
      request: request,
      seriesRef: seriesRef,
      releaseOptions: releaseOptions,
    ),
    InspectorReleasesSection(request: request),
    InspectorContributorsSection(request: request),
    InspectorLinksTrailersSection(request: request),
  ];
}

Widget buildTvInspectorPanel(
  BuildContext context,
  LibraryInspectorPanelRequest request,
) {
  return buildVideoInspectorPanel(context, request);
}
