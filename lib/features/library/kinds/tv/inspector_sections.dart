import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/video/video_episode_rating_section.dart';
import 'package:collectarr_app/features/library/kinds/video/video_inspector_panel.dart';
import 'package:collectarr_app/features/library/kinds/video/video_season_tracking_section.dart';
import 'package:collectarr_app/features/library/kinds/video/watch_history_section.dart';
import 'package:collectarr_app/features/library/providers/seasons_provider.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_inspector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  return [
    TvSeriesMetadataSection(request: request),
    TvSeasonsEpisodesSection(
      seriesRef: seriesRef,
      kind: request.type.workspace.kind.apiValue,
      accent: request.accent,
    ),
    VideoEpisodeRatingDisplaySection(
      itemId: request.entry.id,
      kind: request.type.workspace.kind.apiValue,
      accent: request.accent,
    ),
    TvWatchHistorySection(
      request: request,
      seriesRef: seriesRef,
      releaseOptions: releaseOptions,
    ),
    TvReleasesDiscsSection(request: request),
    TvCastCrewSection(request: request),
  ];
}

Widget buildTvInspectorPanel(
  BuildContext context,
  LibraryInspectorPanelRequest request,
) {
  return buildVideoInspectorPanel(context, request);
}

class TvSeriesMetadataSection extends StatelessWidget {
  const TvSeriesMetadataSection({super.key, required this.request});

  final LibraryInspectorRequest request;

  @override
  Widget build(BuildContext context) {
    final entry = request.entry;
    final ownedItem = request.ownedItem;
    final trackingEntry = request.trackingEntry;
    final aliases = <String>{
      if (entry.originalTitle?.trim().isNotEmpty == true)
        entry.originalTitle!.trim(),
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
    return LibraryInspectorSection(
      title: 'Series metadata',
      accentColor: request.accent,
      children: [
        LibraryInspectorFactGrid(facts: facts),
        if (genreValues.isNotEmpty) ...[
          const SizedBox(height: 8),
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
    );
  }
}

class TvSeasonsEpisodesSection extends StatelessWidget {
  const TvSeasonsEpisodesSection({
    super.key,
    required this.seriesRef,
    required this.kind,
    required this.accent,
  });

  final CatalogEntityRef seriesRef;
  final String kind;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return VideoSeasonTrackingSection(
      seriesRef: seriesRef,
      kind: kind,
      accent: accent,
    );
  }
}

class TvWatchHistorySection extends ConsumerWidget {
  const TvWatchHistorySection({
    super.key,
    required this.request,
    required this.seriesRef,
    required this.releaseOptions,
  });

  final LibraryInspectorRequest request;
  final CatalogEntityRef seriesRef;
  final List<WatchHistoryTargetOption> releaseOptions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seasonsAsync = ref.watch(seasonsByCatalogRefProvider(seriesRef));
    final targetOptions = <WatchHistoryTargetOption>[
      WatchHistoryTargetOption(
        ref: seriesRef,
        label: 'Series',
        subtitle: request.entry.resolvedTitle,
      ),
      ...seasonsAsync.maybeWhen(
        data: (seasons) => [
          for (final season in seasons) ...[
            WatchHistoryTargetOption(
              ref: CatalogEntityRef(
                kind: seriesRef.kind,
                entityType: CatalogEntityType.season,
                id: '${seriesRef.id}:season:${season.seasonNumber}',
              ),
              label: season.title,
              subtitle: 'Season ${season.seasonNumber}',
              seasonNumber: season.seasonNumber,
            ),
            for (final episode in season.episodes)
              WatchHistoryTargetOption(
                ref: CatalogEntityRef(
                  kind: seriesRef.kind,
                  entityType: CatalogEntityType.episode,
                  id:
                      '${seriesRef.id}:season:${season.seasonNumber}:episode:${episode.episodeNumber}',
                ),
                label: episode.title,
                subtitle:
                    'Season ${season.seasonNumber} • Episode ${episode.episodeNumber}',
                seasonNumber: season.seasonNumber,
                episodeNumber: episode.episodeNumber,
              ),
          ],
        ],
        orElse: () => const <WatchHistoryTargetOption>[],
      ),
      ...releaseOptions,
    ];

    return WatchHistorySection(
      itemId: request.entry.id,
      accent: request.accent,
      catalogRef: seriesRef,
      defaultTargetRef: seriesRef,
      targetOptions: targetOptions,
    );
  }
}

class TvReleasesDiscsSection extends StatelessWidget {
  const TvReleasesDiscsSection({super.key, required this.request});

  final LibraryInspectorRequest request;

  @override
  Widget build(BuildContext context) {
    final entry = request.entry;
    final video = entry.video;
    final editions = entry.editions;
    final discCount = video?.nrDiscs ?? editions.fold<int>(
      0,
      (total, edition) => total + edition.discs.length,
    );
    if (discCount == 0 && editions.isEmpty) {
      return const SizedBox.shrink();
    }
    return LibraryInspectorSection(
      title: 'Releases / discs',
      accentColor: request.accent,
      children: [
        LibraryInspectorFactGrid(
          facts: [
            LibraryInspectorFactData('Releases', editions.length.toString()),
            LibraryInspectorFactData('Discs', discCount.toString()),
            if (video?.runtimeMinutes != null)
              LibraryInspectorFactData(
                'Runtime',
                '${video!.runtimeMinutes} min',
              ),
          ],
        ),
        if (editions.isNotEmpty) ...[
          const SizedBox(height: 8),
          for (final edition in editions)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surface
                      .withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Theme.of(context)
                        .dividerColor
                        .withValues(alpha: 0.65),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        edition.title,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      if (edition.format?.trim().isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          edition.format!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      if (edition.discs.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final disc in edition.discs)
                              Chip(
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                label: Text(
                                  disc.discName ?? 'Disc ${disc.discNumber}',
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class TvCastCrewSection extends StatelessWidget {
  const TvCastCrewSection({super.key, required this.request});

  final LibraryInspectorRequest request;

  @override
  Widget build(BuildContext context) {
    final creators = request.entry.creators ?? const <Map<String, dynamic>>[];
    if (creators.isEmpty) {
      return const SizedBox.shrink();
    }
    final byRole = <String, List<String>>{};
    for (final credit in creators) {
      final name = credit['name']?.toString().trim();
      if (name == null || name.isEmpty) continue;
      final role = credit['role']?.toString().trim();
      final key = (role == null || role.isEmpty) ? 'Cast & crew' : role;
      byRole.putIfAbsent(key, () => <String>[]).add(name);
    }
    final entries = byRole.entries.toList(growable: false);
    return LibraryInspectorSection(
      title: 'Cast & crew',
      accentColor: request.accent,
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          LibraryInspectorChipWrap(
            label: entries[i].key,
            values: entries[i].value,
            onValueTap: request.onFilterByValue,
          ),
          if (i != entries.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}
