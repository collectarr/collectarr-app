import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_medium.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_edit_draft.dart';
import 'package:flutter/material.dart';

enum MusicReleaseStructureSection { media, tracks, credits }

/// Music-owned release structure editor.
///
/// The draft owns the mutable medium/track graph. This tab deliberately does
/// not route track edits through a generic catalog DTO, so headers, nesting,
/// artist credits and medium boundaries survive the save round-trip.
final class MusicReleaseStructureTab extends StatefulWidget {
  const MusicReleaseStructureTab({
    super.key,
    required this.draft,
    required this.section,
    required this.accent,
  });

  final MusicReleaseEditDraft draft;
  final MusicReleaseStructureSection section;
  final Color accent;

  @override
  State<MusicReleaseStructureTab> createState() =>
      _MusicReleaseStructureTabState();
}

final class _MusicReleaseStructureTabState
    extends State<MusicReleaseStructureTab> {
  MusicReleaseEditDraft get draft => widget.draft;

  @override
  Widget build(BuildContext context) {
    return EditTabShell(
      children: switch (widget.section) {
        MusicReleaseStructureSection.media => _mediaSections(),
        MusicReleaseStructureSection.tracks => _trackSections(),
        MusicReleaseStructureSection.credits => [_creditsSection()],
      },
    );
  }

  List<Widget> _mediaSections() {
    if (draft.mediums.isEmpty) {
      return [const Text('No media is available for this release.')];
    }
    return [
      for (final medium in draft.mediums)
        EditSection(
          title: 'Disc ${medium.mediumNumber}',
          accent: widget.accent,
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
    if (draft.mediums.isEmpty) {
      return [
        const Text('No media is available for this release.'),
        const SizedBox(height: 10),
        const Text('Add a disc in the Media section before adding tracks.'),
      ];
    }
    return [
      for (final medium in draft.mediums)
        EditSection(
          title: 'Disc ${medium.mediumNumber}',
          accent: widget.accent,
          child: _mediumTrackEditor(medium),
        ),
    ];
  }

  Widget _mediumTrackEditor(MusicMedium medium) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          key: ValueKey('music-medium-title-${medium.id.value}'),
          initialValue: medium.title ?? '',
          decoration: const InputDecoration(labelText: 'Disc title'),
          onChanged: (value) => draft.updateMediumTitle(medium.id, value),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () => setState(
                () => draft.addTrack(medium.id, header: true),
              ),
              icon: const Icon(Icons.folder_outlined, size: 16),
              label: const Text('Add Header'),
            ),
            OutlinedButton.icon(
              onPressed: () => setState(
                () => draft.addTrack(medium.id, header: false),
              ),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Track'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (var index = 0; index < medium.tracks.length; index++)
          _trackEditorRow(medium, medium.tracks[index], index),
      ],
    );
  }

  Widget _trackEditorRow(MusicMedium medium, MusicTrack track, int index) {
    final isHeader = track.isHeader;
    return Padding(
      padding: EdgeInsets.only(
        left: track.indentLevel * 18.0,
        bottom: 8,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isHeader
              ? widget.accent.withValues(alpha: 0.06)
              : Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: isHeader
                ? widget.accent.withValues(alpha: 0.35)
                : Theme.of(context).dividerColor,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 30,
                child: Column(
                  children: [
                    Icon(
                      isHeader ? Icons.folder_outlined : Icons.drag_handle,
                      size: 18,
                      color: isHeader ? widget.accent : null,
                    ),
                    Text(
                      isHeader ? 'H' : '${index + 1}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    SizedBox(
                      width: 270,
                      child: TextFormField(
                        key: ValueKey('music-track-title-${track.id.value}'),
                        initialValue: track.title,
                        decoration: InputDecoration(
                          labelText: isHeader ? 'Header title' : 'Track title',
                        ),
                        onChanged: (value) => _replaceTrack(
                          medium,
                          index,
                          musicTrackWithEdits(
                            track,
                            title: value,
                            position: track.position,
                            artist: track.artist ?? '',
                            durationMs: track.durationMs,
                          ),
                          rebuild: false,
                        ),
                      ),
                    ),
                    if (!isHeader)
                      SizedBox(
                        width: 170,
                        child: TextFormField(
                          key: ValueKey('music-track-artist-${track.id.value}'),
                          initialValue: track.artist ?? '',
                          decoration:
                              const InputDecoration(labelText: 'Artist'),
                          onChanged: (value) => _replaceTrack(
                            medium,
                            index,
                            musicTrackWithEdits(
                              track,
                              title: track.title,
                              position: track.position,
                              artist: value,
                              durationMs: track.durationMs,
                            ),
                            rebuild: false,
                          ),
                        ),
                      ),
                    if (!isHeader)
                      SizedBox(
                        width: 100,
                        child: TextFormField(
                          key: ValueKey(
                              'music-track-duration-${track.id.value}'),
                          initialValue: track.durationSeconds?.toString() ?? '',
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Seconds',
                          ),
                          onChanged: (value) => _replaceTrack(
                            medium,
                            index,
                            musicTrackWithEdits(
                              track,
                              title: track.title,
                              position: track.position,
                              artist: track.artist ?? '',
                              durationMs: _durationMs(value),
                            ),
                            rebuild: false,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                width: 72,
                child: Column(
                  children: [
                    IconButton(
                      tooltip: 'Move up',
                      visualDensity: VisualDensity.compact,
                      onPressed: index == 0
                          ? null
                          : () => setState(
                                () => draft.moveTrack(medium.id, index, -1),
                              ),
                      icon: const Icon(Icons.keyboard_arrow_up),
                    ),
                    IconButton(
                      tooltip: 'Move down',
                      visualDensity: VisualDensity.compact,
                      onPressed: index == medium.tracks.length - 1
                          ? null
                          : () => setState(
                                () => draft.moveTrack(medium.id, index, 1),
                              ),
                      icon: const Icon(Icons.keyboard_arrow_down),
                    ),
                    IconButton(
                      tooltip: 'Decrease indent',
                      visualDensity: VisualDensity.compact,
                      onPressed: track.indentLevel == 0
                          ? null
                          : () => _replaceTrack(
                                medium,
                                index,
                                musicTrackWithEdits(
                                  track,
                                  title: track.title,
                                  position: track.position,
                                  artist: track.artist ?? '',
                                  durationMs: track.durationMs,
                                  indentLevel: track.indentLevel - 1,
                                ),
                              ),
                      icon: const Icon(Icons.format_indent_decrease),
                    ),
                    IconButton(
                      tooltip: 'Increase indent',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _replaceTrack(
                        medium,
                        index,
                        musicTrackWithEdits(
                          track,
                          title: track.title,
                          position: track.position,
                          artist: track.artist ?? '',
                          durationMs: track.durationMs,
                          indentLevel: track.indentLevel + 1,
                        ),
                      ),
                      icon: const Icon(Icons.format_indent_increase),
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => setState(
                        () => draft.removeTrack(medium.id, index),
                      ),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _replaceTrack(
    MusicMedium medium,
    int index,
    MusicTrack track, {
    bool rebuild = true,
  }) {
    draft.replaceTrack(medium.id, index, track);
    if (rebuild) setState(() {});
  }

  Widget _creditsSection() {
    final release = draft.original;
    if (release.contributions.isEmpty) {
      return const Text('No credits are available for this release.');
    }
    return EditSection(
      title: 'Release credits',
      accent: widget.accent,
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
}

int? _durationMs(String value) {
  final seconds = int.tryParse(value.trim());
  return seconds == null ? null : seconds * 1000;
}
