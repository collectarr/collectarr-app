import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:flutter/material.dart';

enum MusicReleaseStructureSection { media, tracks, credits }

/// Read-only typed projections for release-owned graph data.
///
/// Media, tracks and credits are currently hydrated from Core/provider data.
/// Keeping them as explicit Release tabs makes their ownership visible while
/// leaving mutations to the typed graph boundaries that own those records.
final class MusicReleaseStructureTab extends StatelessWidget {
  const MusicReleaseStructureTab({
    super.key,
    required this.release,
    required this.section,
    required this.accent,
  });

  final MusicRelease release;
  final MusicReleaseStructureSection section;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return EditTabShell(
      children: switch (section) {
        MusicReleaseStructureSection.media => _mediaSections(),
        MusicReleaseStructureSection.tracks => _trackSections(),
        MusicReleaseStructureSection.credits => [_creditsSection()],
      },
    );
  }

  List<Widget> _mediaSections() {
    if (release.mediums.isEmpty) {
      return [const Text('No media is available for this release.')];
    }
    return [
      for (final medium in release.mediums)
        EditSection(
          title: 'Disc ${medium.mediumNumber}',
          accent: accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _value('Format', medium.mediumType),
              _value('Title', medium.title),
              _value('Tracks', medium.effectiveTrackCount.toString()),
              _value('Condition', medium.mediaCondition),
            ],
          ),
        ),
    ];
  }

  List<Widget> _trackSections() {
    if (release.mediums.every((medium) => medium.tracks.isEmpty)) {
      return [const Text('No tracks are available for this release.')];
    }
    return [
      for (final medium in release.mediums)
        if (medium.tracks.isNotEmpty)
          EditSection(
            title: 'Disc ${medium.mediumNumber}',
            accent: accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final track in medium.tracks)
                  ListTile(
                    contentPadding: EdgeInsets.only(
                      left: track.indentLevel * 18.0,
                    ),
                    dense: true,
                    leading: track.isHeader
                        ? Icon(Icons.folder_outlined, color: accent, size: 18)
                        : SizedBox(
                            width: 28,
                            child: Text(
                              track.position,
                              textAlign: TextAlign.right,
                            ),
                          ),
                    title: Text(
                      track.title,
                      style: TextStyle(
                        color: track.isHeader ? accent : null,
                        fontWeight:
                            track.isHeader ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                    subtitle: track.isHeader ||
                            track.artist?.trim().isNotEmpty != true
                        ? null
                        : Text(track.artist!.trim()),
                    trailing: track.isHeader || track.durationSeconds == null
                        ? null
                        : Text(_duration(track.durationSeconds!)),
                  ),
              ],
            ),
          ),
    ];
  }

  Widget _creditsSection() {
    if (release.contributions.isEmpty) {
      return const Text('No credits are available for this release.');
    }
    return EditSection(
      title: 'Release credits',
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final credit in release.contributions)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(credit.displayName ?? credit.personId),
              subtitle: Text(credit.role),
            ),
        ],
      ),
    );
  }

  Widget _value(String label, String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text('$label: $normalized'),
    );
  }

  String _duration(int seconds) {
    final minutes = seconds ~/ 60;
    return '$minutes:${(seconds % 60).toString().padLeft(2, '0')}';
  }
}
