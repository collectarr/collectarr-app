import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/providers/seasons_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VideoUpcomingEpisodesSection extends ConsumerWidget {
  const VideoUpcomingEpisodesSection({
    super.key,
    required this.seriesRef,
    required this.accent,
    this.title = 'Upcoming episodes',
    this.maxVisible = 5,
  });

  final CatalogEntityRef seriesRef;
  final Color accent;
  final String title;
  final int maxVisible;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seasonsAsync = ref.watch(seasonsByCatalogRefProvider(seriesRef));
    return seasonsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (seasons) {
        final now = DateTime.now().toUtc();
        final upcoming = <_UpcomingEpisodeItem>[];
        for (final season in seasons) {
          for (final episode in season.episodes) {
            final airDate = DateTime.tryParse(episode.airDate ?? '');
            if (airDate == null || !airDate.isAfter(now)) {
              continue;
            }
            upcoming.add(
              _UpcomingEpisodeItem(
                seasonNumber: season.seasonNumber,
                episodeNumber: episode.episodeNumber,
                title: episode.title,
                airDate: airDate,
              ),
            );
          }
        }
        upcoming.sort((a, b) {
          final compare = a.airDate.compareTo(b.airDate);
          if (compare != 0) return compare;
          final seasonCompare = a.seasonNumber.compareTo(b.seasonNumber);
          if (seasonCompare != 0) return seasonCompare;
          return a.episodeNumber.compareTo(b.episodeNumber);
        });
        if (upcoming.isEmpty) {
          return const SizedBox.shrink();
        }
        final visible = upcoming.take(maxVisible).toList(growable: false);
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
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                ),
                const SizedBox(height: 8),
                for (final episode in visible)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      'S${episode.seasonNumber.toString().padLeft(2, '0')}E${episode.episodeNumber.toString().padLeft(2, '0')}'
                      '${episode.title == null || episode.title!.trim().isEmpty ? '' : ' — ${episode.title!.trim()}'}'
                      ' — ${_date(episode.airDate)}',
                      style: TextStyle(
                        color: appPalette(context).textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _date(DateTime value) {
    return value.toLocal().toIso8601String().split('T').first;
  }
}

class _UpcomingEpisodeItem {
  const _UpcomingEpisodeItem({
    required this.seasonNumber,
    required this.episodeNumber,
    required this.title,
    required this.airDate,
  });

  final int seasonNumber;
  final int episodeNumber;
  final String? title;
  final DateTime airDate;
}
