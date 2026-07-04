import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/providers/seasons_provider.dart';
import 'package:collectarr_app/features/library/kinds/video/video_episode_rating_section.dart';
import 'package:collectarr_app/features/library/kinds/video/video_inspector_panel.dart';
import 'package:collectarr_app/features/library/kinds/video/video_inspector_sections.dart'
    as video_sections;
import 'package:collectarr_app/features/library/kinds/video/video_season_tracking_section.dart';
import 'package:collectarr_app/features/library/kinds/video/watch_history_section.dart';
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
  return [
    ...video_sections.buildVideoInspectorSections(context, request),
    VideoSeasonTrackingSection(
      seriesRef: seriesRef,
      kind: request.type.workspace.kind.apiValue,
      accent: request.accent,
    ),
    VideoEpisodeRatingDisplaySection(
      itemId: request.entry.id,
      kind: request.type.workspace.kind.apiValue,
      accent: request.accent,
    ),
    _TvWatchHistorySection(request: request, seriesRef: seriesRef),
    _TvReleaseDiscsSection(request: request),
    _TvCastCrewSection(request: request),
    _TvTrailersLinksSection(request: request),
    _TvPersonalCustomSection(request: request),
  ];
}

Widget buildTvInspectorPanel(
  BuildContext context,
  LibraryInspectorPanelRequest request,
) {
  return buildVideoInspectorPanel(context, request);
}

class _TvWatchHistorySection extends ConsumerWidget {
  const _TvWatchHistorySection({
    required this.request,
    required this.seriesRef,
  });

  final LibraryInspectorRequest request;
  final CatalogEntityRef seriesRef;

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
    ];

    return WatchHistorySection(
      itemId: request.entry.id,
      accent: request.accent,
      defaultTargetRef: seriesRef,
      targetOptions: targetOptions,
    );
  }
}

class _TvReleaseDiscsSection extends StatelessWidget {
  const _TvReleaseDiscsSection({required this.request});

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

class _TvCastCrewSection extends StatelessWidget {
  const _TvCastCrewSection({required this.request});

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

class _TvTrailersLinksSection extends StatelessWidget {
  const _TvTrailersLinksSection({required this.request});

  final LibraryInspectorRequest request;

  @override
  Widget build(BuildContext context) {
    final trailers = request.entry.trailerUrls;
    if (trailers.isEmpty) {
      return const SizedBox.shrink();
    }
    return LibraryInspectorSection(
      title: 'Trailers / links',
      accentColor: request.accent,
      children: [
        LibraryInspectorChipWrap(
          label: 'Links',
          values: [
            for (final trailer in trailers)
              trailer.title?.trim().isNotEmpty == true
                  ? trailer.title!.trim()
                  : trailer.url,
          ],
        ),
      ],
    );
  }
}

class _TvPersonalCustomSection extends StatelessWidget {
  const _TvPersonalCustomSection({required this.request});

  final LibraryInspectorRequest request;

  @override
  Widget build(BuildContext context) {
    final entry = request.entry;
    final ownedItem = request.ownedItem;
    final trackingEntry = request.trackingEntry;
    final tags = entry.tags?.trim().isNotEmpty == true
        ? entry.tags!
            .split(RegExp(r'[,\n\r]+'))
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .toList(growable: false)
        : const <String>[];
    final facts = <LibraryInspectorFactData>[
      if (ownedItem?.condition?.trim().isNotEmpty == true)
        LibraryInspectorFactData('Condition', ownedItem!.condition!),
      if (ownedItem?.grade?.trim().isNotEmpty == true)
        LibraryInspectorFactData('Grade', ownedItem!.grade!),
      if (ownedItem?.collectionStatus?.trim().isNotEmpty == true)
        LibraryInspectorFactData('Status', ownedItem!.collectionStatus!),
      if (ownedItem?.personalNotes?.trim().isNotEmpty == true)
        LibraryInspectorFactData('Notes', ownedItem!.personalNotes!),
      if (trackingEntry?.notes?.trim().isNotEmpty == true)
        LibraryInspectorFactData('Tracking notes', trackingEntry!.notes!),
      if (entry.ageRating?.trim().isNotEmpty == true)
        LibraryInspectorFactData('Age rating', entry.ageRating!),
      if (entry.audienceRating?.trim().isNotEmpty == true)
        LibraryInspectorFactData('Audience rating', entry.audienceRating!),
    ];
    if (facts.isEmpty && tags.isEmpty) {
      return const SizedBox.shrink();
    }
    return LibraryInspectorSection(
      title: 'Personal / custom fields',
      accentColor: request.accent,
      children: [
        if (facts.isNotEmpty) LibraryInspectorFactGrid(facts: facts),
        if (tags.isNotEmpty) ...[
          if (facts.isNotEmpty) const SizedBox(height: 8),
          LibraryInspectorChipWrap(
            label: 'Tags',
            values: tags,
            onValueTap: request.onFilterByValue,
          ),
        ],
      ],
    );
  }
}
