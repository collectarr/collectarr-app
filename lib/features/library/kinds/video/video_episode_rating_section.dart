import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/core/models/season.dart';
import 'package:collectarr_app/features/library/providers/seasons_provider.dart';
import 'package:collectarr_app/features/library/widgets/episode_rating_grid.dart';
import 'package:collectarr_app/features/library/widgets/episode_rating_picker.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Inspector section showing a heatmap grid of per-episode ratings.
class VideoEpisodeRatingSection extends ConsumerWidget {
  const VideoEpisodeRatingSection({
    super.key,
    required this.itemId,
    required this.kind,
    required this.accent,
    required this.trackingEntry,
    required this.onEpisodeRatingsChanged,
  });

  final String itemId;
  final String kind;
  final Color accent;
  final TrackingEntry? trackingEntry;
  final ValueChanged<Map<String, int>> onEpisodeRatingsChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seasonsAsync = kind.trim().toLowerCase() == 'tv'
        ? ref.watch(tvSeasonsBySeriesRefProvider(itemId))
        : AsyncValue<List<Season>>.data(<Season>[]);
    final ratings = trackingEntry?.episodeRatings ?? const {};

    return seasonsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (seasons) {
        if (seasons.isEmpty) return const SizedBox.shrink();
        final hasEpisodes = seasons.any((s) => s.episodes.isNotEmpty);
        if (!hasEpisodes) return const SizedBox.shrink();

        return DecoratedBox(
          decoration: BoxDecoration(
            color: appPalette(context).surfaceSubtle,
            border: Border.all(color: accent.withValues(alpha: 0.33)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.grid_on, size: 16, color: accent),
                    const SizedBox(width: 6),
                    Text(
                      'Episode ratings',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                    ),
                    const Spacer(),
                    if (ratings.isNotEmpty)
                      Text(
                        '${ratings.length} rated',
                        style: TextStyle(
                          color: appPalette(context).textMuted,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                EpisodeRatingGrid(
                  seasons: seasons,
                  ratings: ratings,
                  compact: true,
                  onRatingTap: (season, episode, current) async {
                    final result = await showEpisodeRatingPicker(
                      context: context,
                      season: season,
                      episode: episode,
                      currentRating: current,
                    );
                    if (result == null) return; // dismissed
                    final updated = Map<String, int>.from(ratings);
                    final key = episodeRatingKey(season, episode);
                    if (result == 0) {
                      updated.remove(key);
                    } else {
                      updated[key] = result;
                    }
                    onEpisodeRatingsChanged(updated);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Read-only version for the inspector detail page.
class VideoEpisodeRatingDisplaySection extends ConsumerWidget {
  const VideoEpisodeRatingDisplaySection({
    super.key,
    required this.itemId,
    required this.kind,
    required this.accent,
  });

  final String itemId;
  final String kind;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seasonsAsync = kind.trim().toLowerCase() == 'tv'
        ? ref.watch(tvSeasonsBySeriesRefProvider(itemId))
        : AsyncValue<List<Season>>.data(<Season>[]);
    final trackingEntries =
        ref.watch(trackingEntriesByCatalogItemProvider)[itemId] ??
            const <TrackingEntry>[];
    final ratings = trackingEntries.isEmpty
        ? const <String, int>{}
        : trackingEntries.first.episodeRatings;

    if (ratings.isEmpty) return const SizedBox.shrink();

    return seasonsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (seasons) {
        if (seasons.isEmpty) return const SizedBox.shrink();
        return DecoratedBox(
          decoration: BoxDecoration(
            color: appPalette(context).surfaceSubtle.withValues(alpha: 0.92),
            border: Border.all(color: accent.withValues(alpha: 0.33)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.grid_on, size: 16, color: accent),
                    const SizedBox(width: 6),
                    Text(
                      'Episode ratings',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                EpisodeRatingGrid(
                  seasons: seasons,
                  ratings: ratings,
                  compact: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
