import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track_list_entry.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Music-owned track presentation.
///
/// The shared inspector track widget intentionally accepts only generic
/// catalog tracks. Music must render its own ordered medium entries so header
/// rows, hierarchy and track-level artist credits survive the projection.
final class MusicInspectorTrackList extends StatelessWidget {
  const MusicInspectorTrackList({
    super.key,
    required this.tracks,
    required this.accent,
    this.onFilterByValue,
  });

  final List<MusicTrackListEntry> tracks;
  final Color accent;
  final ValueChanged<String>? onFilterByValue;

  @override
  Widget build(BuildContext context) {
    if (tracks.isEmpty) return const SizedBox.shrink();
    final groups = _groupByDisc(tracks);
    final playableCount = tracks.where((entry) => !entry.isHeader).length;
    final palette = appPalette(context);

    return LibraryDetailSection(
      title: 'Track List',
      accentColor: accent,
      children: [
        Text(
          '$playableCount ${playableCount == 1 ? 'track' : 'tracks'}',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: palette.textPrimary,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        for (var index = 0; index < groups.length; index++) ...[
          _MusicInspectorDisc(
            discNumber: groups[index].discNumber,
            tracks: groups[index].tracks,
            accent: accent,
            onFilterByValue: onFilterByValue,
          ),
          if (index < groups.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

final class MusicInspectorTrackListUnavailable extends StatelessWidget {
  const MusicInspectorTrackListUnavailable({
    super.key,
    required this.trackCount,
    required this.accent,
  });

  final int trackCount;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return LibraryDetailSection(
      title: 'Track List',
      accentColor: accent,
      children: [
        Text(
          '$trackCount tracks found, but the cached metadata does not include the full track list yet.',
        ),
      ],
    );
  }
}

final class _MusicInspectorDisc extends StatelessWidget {
  const _MusicInspectorDisc({
    required this.discNumber,
    required this.tracks,
    required this.accent,
    this.onFilterByValue,
  });

  final int discNumber;
  final List<MusicTrackListEntry> tracks;
  final Color accent;
  final ValueChanged<String>? onFilterByValue;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final duration = _formatDuration(tracks);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Disc #$discNumber',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            if (duration != null) ...[
              const SizedBox(width: 8),
              Text(
                duration,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 5),
        for (final track in tracks)
          _MusicInspectorTrackRow(
            track: track,
            accent: accent,
            onFilterByValue: onFilterByValue,
          ),
      ],
    );
  }
}

final class _MusicInspectorTrackRow extends StatelessWidget {
  const _MusicInspectorTrackRow({
    required this.track,
    required this.accent,
    this.onFilterByValue,
  });

  final MusicTrackListEntry track;
  final Color accent;
  final ValueChanged<String>? onFilterByValue;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final artist = track.artist?.trim();
    return Padding(
      padding: EdgeInsets.fromLTRB(
        track.indentLevel * 14.0,
        track.isHeader ? 5 : 2,
        0,
        track.isHeader ? 5 : 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: track.isHeader ? 20 : 28,
            child: track.isHeader
                ? Icon(
                    Icons.folder_outlined,
                    size: 16,
                    color: accent.withValues(alpha: 0.9),
                  )
                : Text(
                    track.position,
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: palette.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: track.isHeader ? accent : palette.textPrimary,
                        fontWeight:
                            track.isHeader ? FontWeight.w800 : FontWeight.w600,
                      ),
                ),
                if (!track.isHeader && artist != null && artist.isNotEmpty)
                  InkWell(
                    mouseCursor: WidgetStateMouseCursor.clickable,
                    onTap: onFilterByValue == null
                        ? null
                        : () => onFilterByValue!(artist),
                    borderRadius: BorderRadius.circular(3),
                    child: Text(
                      artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: onFilterByValue == null
                                ? palette.textMuted
                                : inspectorActionColor(context),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
              ],
            ),
          ),
          if (!track.isHeader && track.durationSeconds != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                _formatTrackDuration(track.durationSeconds!),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.textMuted,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}

final class _MusicInspectorDiscGroup {
  const _MusicInspectorDiscGroup({
    required this.discNumber,
    required this.tracks,
  });

  final int discNumber;
  final List<MusicTrackListEntry> tracks;
}

List<_MusicInspectorDiscGroup> _groupByDisc(
  List<MusicTrackListEntry> tracks,
) {
  final grouped = <int, List<MusicTrackListEntry>>{};
  for (final track in tracks) {
    grouped.putIfAbsent(track.discNumber, () => <MusicTrackListEntry>[]).add(
          track,
        );
  }
  final discs = grouped.keys.toList()..sort();
  return [
    for (final disc in discs)
      _MusicInspectorDiscGroup(
        discNumber: disc,
        tracks: List<MusicTrackListEntry>.unmodifiable(grouped[disc]!),
      ),
  ];
}

String? _formatDuration(List<MusicTrackListEntry> tracks) {
  var seconds = 0;
  for (final track in tracks) {
    if (track.isHeader) continue;
    final value = track.durationSeconds;
    if (value != null) seconds += value;
  }
  return seconds == 0 ? null : _formatTrackDuration(seconds);
}

String _formatTrackDuration(int seconds) {
  final minutes = seconds ~/ 60;
  return '$minutes:${(seconds % 60).toString().padLeft(2, '0')}';
}

Color inspectorActionColor(BuildContext context) => appPalette(context).accent;
