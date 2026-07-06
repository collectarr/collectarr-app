import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/kinds/video/video_progress_presenter.dart';
import 'package:collectarr_app/features/library/kinds/video/video_progress_summary.dart';
import 'package:collectarr_app/features/library/providers/seasons_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VideoProgressSection extends ConsumerWidget {
  const VideoProgressSection({
    super.key,
    required this.seriesRef,
    required this.accent,
    this.title = 'TV progress',
  });

  final CatalogEntityRef seriesRef;
  final Color accent;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seasonsAsync = ref.watch(seasonsByCatalogRefProvider(seriesRef));
    final trackedUnits = ref.watch(trackingUnitsByCatalogRefProvider(seriesRef));
    final watchSessions = ref.watch(watchSessionsByCatalogRefProvider(seriesRef));
    return seasonsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (seasons) {
        final summary = const VideoProgressPresenter().build(
          seasons: seasons,
          trackedUnits: trackedUnits,
          watchSessions: watchSessions,
        );
        if (summary.totalEpisodes == 0) {
          return const SizedBox.shrink();
        }
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
                    Icon(Icons.play_circle_outline, size: 16, color: accent),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      summary.completionSummary,
                      style: TextStyle(
                        color: appPalette(context).textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _ProgressBar(
                  accent: accent,
                  value: summary.completionPercent,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    summary.watchedSummary,
                    summary.episodesLeftSummary,
                    summary.currentSeasonSummary,
                    summary.lastWatchedSummary,
                    summary.nextEpisodeSummary,
                  ]
                      .map(
                        (text) => Text(
                          text,
                          style: TextStyle(
                            color: appPalette(context).textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.accent,
    required this.value,
  });

  final Color accent;
  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: 8,
        backgroundColor: appPalette(context).divider.withValues(alpha: 0.35),
        color: accent,
      ),
    );
  }
}

class VideoProgressSummaryFields extends StatelessWidget {
  const VideoProgressSummaryFields({
    super.key,
    required this.summary,
    required this.accent,
  });

  final VideoProgressSummary summary;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return LibraryDetailSection(
      title: 'TV progress',
      fields: [
        LibraryDetailField(
          label: 'Status',
          value: summary.isFullyWatched ? 'Caught up' : 'In progress',
        ),
        LibraryDetailField(label: 'Watched', value: summary.watchedSummary),
        LibraryDetailField(
          label: 'Completion',
          value: summary.completionSummary,
        ),
        LibraryDetailField(
          label: 'Episodes left',
          value: summary.episodesLeft.toString(),
        ),
        LibraryDetailField(
          label: 'Current season',
          value: summary.currentSeasonNumber == null
              ? '-'
              : 'Season ${summary.currentSeasonNumber}',
        ),
        LibraryDetailField(
          label: 'Last watched',
          value: summary.lastWatched?.code ?? '-',
        ),
        LibraryDetailField(
          label: 'Next episode',
          value: summary.nextEpisode?.code ?? '-',
        ),
      ],
      accentColor: accent,
      collapsible: false,
    );
  }
}
