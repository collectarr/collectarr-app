import 'package:collectarr_app/features/library/kinds/video/video_progress_summary.dart';
import 'package:collectarr_app/features/library/ui/library_chrome_tokens.dart';
import 'package:collectarr_app/features/library/ui/library_density_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class VideoEpisodeRow extends StatelessWidget {
  const VideoEpisodeRow({
    super.key,
    required this.episode,
    required this.accent,
    required this.watched,
    this.watchCount = 0,
    this.lastWatchedAt,
    this.rating,
    this.notes,
    this.seenWhere,
    this.busy = false,
    this.onToggleWatched,
    this.onEdit,
    this.onDuplicate,
    this.extraActions = const <Widget>[],
    this.density,
  });

  final VideoEpisodeProgressSummary episode;
  final Color accent;
  final bool watched;
  final int watchCount;
  final DateTime? lastWatchedAt;
  final int? rating;
  final String? notes;
  final String? seenWhere;
  final bool busy;
  final VoidCallback? onToggleWatched;
  final VoidCallback? onEdit;
  final VoidCallback? onDuplicate;
  final List<Widget> extraActions;
  final LibraryDensity? density;

  @override
  Widget build(BuildContext context) {
    final resolvedDensity = density ?? LibraryDensityScope.of(context);
    final resolvedOuterPadding = switch (resolvedDensity) {
      LibraryDensity.comfortable => const EdgeInsets.only(bottom: 8),
      LibraryDensity.compact => const EdgeInsets.only(bottom: 6),
      LibraryDensity.dense => const EdgeInsets.only(bottom: 4),
    };
    final resolvedInnerPadding = switch (resolvedDensity) {
      LibraryDensity.comfortable => const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      LibraryDensity.compact => const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      LibraryDensity.dense => const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    };
    final palette = appPalette(context);
    return Padding(
      padding: resolvedOuterPadding,
      child: Material(
        color: palette.surfaceSubtle.withValues(alpha: 0.82),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
          side: BorderSide(color: accent.withValues(alpha: 0.14)),
        ),
        child: InkWell(
          onTap: busy ? null : onToggleWatched,
          child: Padding(
            padding: resolvedInnerPadding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (busy)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    tooltip: watched ? 'Mark unwatched' : 'Mark watched',
                    onPressed: onToggleWatched,
                    icon: Icon(
                      watched ? Icons.check_box : Icons.check_box_outline_blank,
                      color: watched ? accent : palette.textMuted,
                    ),
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                    padding: EdgeInsets.zero,
                  ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${episode.episode.code} • ${episode.episode.title ?? 'Untitled'}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 3),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (episode.episode.runtimeMinutes != null)
                            _MetaPill(label: '${episode.episode.runtimeMinutes} min'),
                          if (episode.episode.airDate != null)
                            _MetaPill(label: _date(episode.episode.airDate!)),
                          if (watchCount > 0)
                            _MetaPill(label: '$watchCount watches'),
                          if (rating != null)
                            _MetaPill(label: 'Rating $rating'),
                          if (seenWhere != null && seenWhere!.trim().isNotEmpty)
                            _MetaPill(label: seenWhere!.trim()),
                          if (notes != null && notes!.trim().isNotEmpty)
                            const _MetaPill(label: 'Notes'),
                        ],
                      ),
                    ],
                  ),
                ),
                if (onEdit != null || onDuplicate != null || extraActions.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Wrap(
                    spacing: 0,
                    children: [
                      if (onEdit != null)
                        IconButton(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          tooltip: 'Edit',
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                        ),
                      if (onDuplicate != null)
                        IconButton(
                          onPressed: onDuplicate,
                          icon: const Icon(Icons.copy_outlined, size: 18),
                          tooltip: 'Duplicate',
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                        ),
                      ...extraActions,
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _date(DateTime value) {
    return value.toLocal().toIso8601String().split('T').first;
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.canvas.withValues(alpha: 0.55),
        border: Border.all(color: palette.divider.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(
          label,
          style: TextStyle(
            color: palette.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
