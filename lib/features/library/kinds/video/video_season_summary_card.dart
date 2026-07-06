import 'package:collectarr_app/features/library/kinds/video/video_progress_summary.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class VideoSeasonSummaryCard extends StatelessWidget {
  const VideoSeasonSummaryCard({
    super.key,
    required this.summary,
    required this.accent,
    this.onMarkWatched,
    this.onClear,
  });

  final VideoSeasonProgressSummary summary;
  final Color accent;
  final VoidCallback? onMarkWatched;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final canMarkWatched = onMarkWatched != null && summary.watchedEpisodes < summary.releasedEpisodes;
    final canClear = onClear != null && summary.watchedEpisodes > 0;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surfaceSubtle,
        border: Border.all(color: accent.withValues(alpha: 0.24)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              summary.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: accent,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              summary.statusLabel,
              style: TextStyle(
                color: palette.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              summary.progressSummary,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: summary.completionPercent.clamp(0, 1),
              minHeight: 6,
              backgroundColor: palette.divider.withValues(alpha: 0.35),
              color: accent,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (summary.lastWatched != null)
                  Text(
                    'Last ${summary.lastWatched!.code}',
                    style: TextStyle(color: palette.textMuted, fontSize: 11),
                  ),
                if (summary.nextEpisode != null)
                  Text(
                    'Next ${summary.nextEpisode!.code}',
                    style: TextStyle(color: palette.textMuted, fontSize: 11),
                  ),
                if (summary.startedAt != null)
                  Text(
                    'Started ${_date(summary.startedAt!)}',
                    style: TextStyle(color: palette.textMuted, fontSize: 11),
                  ),
                if (summary.finishedAt != null)
                  Text(
                    'Finished ${_date(summary.finishedAt!)}',
                    style: TextStyle(color: palette.textMuted, fontSize: 11),
                  ),
              ],
            ),
            if (onMarkWatched != null || onClear != null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (onMarkWatched != null)
                    OutlinedButton(
                      onPressed: canMarkWatched ? onMarkWatched : null,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                      ),
                      child: const Text('Mark watched'),
                    ),
                  if (onClear != null)
                    OutlinedButton(
                      onPressed: canClear ? onClear : null,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                      ),
                      child: const Text('Clear'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _date(DateTime value) {
    return value.toLocal().toIso8601String().split('T').first;
  }
}
