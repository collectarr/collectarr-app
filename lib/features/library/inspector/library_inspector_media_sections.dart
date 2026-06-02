import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_inspector.dart';
import 'package:flutter/material.dart';

class InspectorTrackList extends StatelessWidget {
  const InspectorTrackList({
    super.key,
    required this.tracks,
    required this.accent,
    this.trackCount,
    this.coverUrl,
    this.title,
  });

  final List<CatalogTrack> tracks;
  final int? trackCount;
  final Color accent;
  final String? coverUrl;
  final String? title;

  static String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String? get _totalDuration {
    var total = 0;
    for (final track in tracks) {
      final dur = track.durationSeconds;
      if (dur != null) {
        total += dur;
      }
    }
    if (total == 0) {
      return null;
    }
    final hours = total ~/ 3600;
    final minutes = (total % 3600) ~/ 60;
    final seconds = total % 60;
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final textTheme = Theme.of(context).textTheme;
    final count = trackCount ?? tracks.length;
    final duration = _totalDuration;
    final headerLabel = duration != null
        ? '$count tracks ($duration)'
        : '$count tracks';

    final trackColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final track in tracks)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 22,
                  child: Text(
                    '${track.position ?? '-'}',
                    style: textTheme.bodySmall?.copyWith(
                      color: palette.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    track.title,
                    style: textTheme.bodySmall?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (track.durationSeconds != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      _formatDuration(track.durationSeconds!),
                      style: textTheme.bodySmall?.copyWith(
                        color: palette.textMuted,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );

    return LibraryInspectorSection(
      title: headerLabel,
      accentColor: accent,
      children: [
        if (coverUrl != null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: trackColumn),
              const SizedBox(width: 14),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: palette.surfaceSubtle.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: palette.divider),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 140,
                      height: 140,
                      child: LibraryInteractiveCover(
                        title: title ?? '',
                        imageUrl: coverUrl,
                        accentColor: accent,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        else
          trackColumn,
      ],
    );
  }
}

class InspectorTrackListUnavailable extends StatelessWidget {
  const InspectorTrackListUnavailable({
    super.key,
    required this.trackCount,
    required this.accent,
  });

  final int trackCount;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return LibraryInspectorSection(
      title: 'Track List',
      accentColor: accent,
      children: [
        Text(
          '$trackCount tracks found, but the cached metadata does not include the full track list yet.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Refresh metadata after re-matching the album to load individual tracks.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: appPalette(context).textMuted,
              ),
        ),
      ],
    );
  }
}