import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
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

  final List<Map<String, dynamic>> tracks;
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
      final dur = track['duration_seconds'];
      if (dur is int) {
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
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                SizedBox(
                  width: 22,
                  child: Text(
                    '${track['position'] ?? '-'}',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.white54,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    track['title'] as String? ?? 'Untitled',
                    style: textTheme.bodySmall?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (track['duration_seconds'] != null &&
                    track['duration_seconds'] is int)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      _formatDuration(track['duration_seconds'] as int),
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.white54,
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
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: 140,
                  height: 140,
                  child: LibraryCoverImage(
                    title: title ?? '',
                    imageUrl: coverUrl,
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
                color: Colors.white70,
              ),
        ),
      ],
    );
  }
}