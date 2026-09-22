import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_medium.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
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
  MusicMediumId? _activeMediumId;
  final Set<String> _selectedTrackIds = <String>{};

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
        const Text('This release does not have any discs yet.'),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => setState(() {
              draft.addMedium();
              _activeMediumId = draft.mediums.last.id;
            }),
            icon: const Icon(Icons.add),
            label: const Text('Add Disc'),
          ),
        ),
      ];
    }
    final medium = _activeMedium();
    if (medium == null) return const [];
    return [
      Row(
        children: [
          Text('Discs', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 38,
              child: ReorderableListView.builder(
                scrollDirection: Axis.horizontal,
                buildDefaultDragHandles: false,
                itemCount: draft.mediums.length,
                onReorder: (oldIndex, newIndex) => setState(() {
                  draft.reorderMedium(oldIndex, newIndex);
                  _selectedTrackIds.clear();
                }),
                itemBuilder: (context, index) {
                  final disc = draft.mediums[index];
                  return Padding(
                    key: ValueKey('music-medium-${disc.id.value}'),
                    padding: const EdgeInsets.only(right: 6),
                    child: ReorderableDragStartListener(
                      index: index,
                      child: ChoiceChip(
                        label: Text(
                          'Disc ${disc.mediumNumber} - '
                          '${disc.effectiveTrackCount} tracks',
                        ),
                        selected: disc.id == medium.id,
                        onSelected: (_) => setState(() {
                          _activeMediumId = disc.id;
                          _selectedTrackIds.clear();
                        }),
                        selectedColor: widget.accent.withValues(alpha: 0.16),
                        side: BorderSide(
                          color: disc.id == medium.id
                              ? widget.accent
                              : Theme.of(context).dividerColor,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          IconButton(
            tooltip: 'Remove disc ${medium.mediumNumber}',
            visualDensity: VisualDensity.compact,
            onPressed: () => _removeMedium(medium),
            icon: const Icon(Icons.delete_outline, size: 18),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () => setState(() {
              draft.addMedium();
              _activeMediumId = draft.mediums.last.id;
              _selectedTrackIds.clear();
            }),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Disc'),
          ),
        ],
      ),
      const SizedBox(height: 8),
      EditSection(
        title: 'Disc ${medium.mediumNumber}',
        accent: widget.accent,
        child: _mediumTrackEditor(medium),
      ),
    ];
  }

  Future<void> _removeMedium(MusicMedium medium) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Remove Disc ${medium.mediumNumber}?'),
        content: Text(
          'This removes ${medium.tracks.length} track entries from the release. '
          'Storage, slot, and matrix details for this disc will also be '
          'removed from its owned copies when you save.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remove disc'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      draft.removeMedium(medium.id);
      _activeMediumId = draft.mediums.isEmpty ? null : draft.mediums.first.id;
      _selectedTrackIds.clear();
    });
  }

  MusicMedium? _activeMedium() {
    for (final medium in draft.mediums) {
      if (medium.id == _activeMediumId) return medium;
    }
    if (draft.mediums.isEmpty) return null;
    return draft.mediums.first;
  }

  Widget _mediumTrackEditor(MusicMedium medium) {
    final durationLabel = _mediumDurationLabel(medium);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                key: ValueKey('music-medium-title-${medium.id.value}'),
                initialValue: medium.title ?? '',
                decoration: const InputDecoration(labelText: 'Disc title'),
                onChanged: (value) => draft.updateMediumTitle(medium.id, value),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextFormField(
                key: ValueKey('music-medium-type-${medium.id.value}'),
                initialValue: medium.mediumType ?? '',
                decoration: const InputDecoration(labelText: 'Medium type'),
                onChanged: (value) => draft.updateMediumType(medium.id, value),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                '${medium.effectiveTrackCount} tracks'
                '${durationLabel == null ? '' : ' - $durationLabel'}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_selectedTrackIds.isNotEmpty) _selectionToolbar(medium),
        _trackTable(medium),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Wrap(
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
        ),
      ],
    );
  }

  Widget _selectionToolbar(MusicMedium medium) {
    final destinations = draft.mediums
        .where((candidate) => candidate.id != medium.id)
        .toList(growable: false);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        runSpacing: 4,
        children: [
          Text(
            '${_selectedTrackIds.length} of ${medium.tracks.length} selected',
          ),
          TextButton.icon(
            onPressed: () => setState(_selectedTrackIds.clear),
            icon: const Icon(Icons.close, size: 16),
            label: const Text('Cancel'),
          ),
          TextButton.icon(
            onPressed: () => setState(() {
              _selectedTrackIds
                ..clear()
                ..addAll(medium.tracks.map((track) => track.id.value));
            }),
            icon: const Icon(Icons.check_box_outlined, size: 16),
            label: const Text('All'),
          ),
          TextButton.icon(
            onPressed: () => setState(
              () => draft.autocapTracks(
                medium.id,
                Set.of(_selectedTrackIds),
              ),
            ),
            icon: const Icon(Icons.text_fields, size: 16),
            label: const Text('Autocap'),
          ),
          if (destinations.isNotEmpty)
            PopupMenuButton<MusicMediumId>(
              tooltip: 'Move selected tracks to another disc',
              onSelected: (destinationId) {
                setState(() {
                  draft.moveTracksToMedium(
                    sourceId: medium.id,
                    destinationId: destinationId,
                    trackIds: Set.of(_selectedTrackIds),
                  );
                  _selectedTrackIds.clear();
                });
              },
              itemBuilder: (context) => [
                for (final destination in destinations)
                  PopupMenuItem(
                    value: destination.id,
                    child: Text('Disc ${destination.mediumNumber}'),
                  ),
              ],
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.album_outlined, size: 16),
                    const SizedBox(width: 6),
                    const Text('Move to other disc'),
                  ],
                ),
              ),
            ),
          TextButton.icon(
            onPressed: () => setState(() {
              draft.removeTracks(medium.id, Set.of(_selectedTrackIds));
              _selectedTrackIds.clear();
            }),
            icon: const Icon(Icons.delete_outline, size: 16),
            label: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Widget _trackTable(MusicMedium medium) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth =
            constraints.hasBoundedWidth && constraints.maxWidth > 760
                ? constraints.maxWidth
                : 760.0;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tableWidth,
            child: Column(
              children: [
                _trackTableHeader(medium),
                if (medium.tracks.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(18),
                    child: Text('No tracks on this disc yet.'),
                  )
                else
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    primary: false,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    itemCount: medium.tracks.length,
                    onReorder: (oldIndex, newIndex) => setState(
                      () => draft.reorderTrack(
                        medium.id,
                        oldIndex,
                        newIndex,
                      ),
                    ),
                    itemBuilder: (context, index) => _trackEditorRow(
                      medium,
                      medium.tracks[index],
                      index,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _trackTableHeader(MusicMedium medium) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).hintColor,
          fontWeight: FontWeight.w700,
        );
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Checkbox(
              tristate: true,
              value: _headerSelectionValue(medium),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: medium.tracks.isEmpty
                  ? null
                  : (_) => setState(() => _toggleAllTracks(medium)),
            ),
          ),
          const SizedBox(width: 30),
          SizedBox(width: 48, child: Text('#', style: style)),
          Expanded(flex: 5, child: Text('Title', style: style)),
          const SizedBox(width: 8),
          Expanded(flex: 3, child: Text('Artist', style: style)),
          const SizedBox(width: 8),
          SizedBox(width: 92, child: Text('Length', style: style)),
          const SizedBox(width: 132),
        ],
      ),
    );
  }

  bool? _headerSelectionValue(MusicMedium medium) {
    if (medium.tracks.isEmpty) return false;
    final selectedCount = medium.tracks
        .where((track) => _selectedTrackIds.contains(track.id.value))
        .length;
    if (selectedCount == 0) return false;
    if (selectedCount == medium.tracks.length) return true;
    return null;
  }

  void _toggleAllTracks(MusicMedium medium) {
    final allSelected = _headerSelectionValue(medium) == true;
    _selectedTrackIds.clear();
    if (!allSelected) {
      _selectedTrackIds.addAll(medium.tracks.map((track) => track.id.value));
    }
  }

  Widget _trackEditorRow(MusicMedium medium, MusicTrack track, int index) {
    final isHeader = track.isHeader;
    final rowColor = isHeader
        ? widget.accent.withValues(alpha: 0.07)
        : (index.isEven
            ? Theme.of(context).colorScheme.surface
            : Theme.of(context).colorScheme.surface.withValues(alpha: 0.55));
    return Container(
      key: ValueKey('music-track-${track.id.value}'),
      decoration: BoxDecoration(
        color: rowColor,
        border: Border(
          left: BorderSide(
            color: isHeader ? widget.accent : Colors.transparent,
            width: 3,
          ),
          right: BorderSide(color: Theme.of(context).dividerColor),
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 34,
              child: Checkbox(
                value: _selectedTrackIds.contains(track.id.value),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (selected) => setState(() {
                  if (selected == true) {
                    _selectedTrackIds.add(track.id.value);
                  } else {
                    _selectedTrackIds.remove(track.id.value);
                  }
                }),
              ),
            ),
            SizedBox(
              width: 30,
              child: ReorderableDragStartListener(
                index: index,
                child: Icon(
                  Icons.drag_handle,
                  size: 18,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ),
            SizedBox(
              width: 48,
              child: isHeader
                  ? Icon(
                      Icons.folder_outlined,
                      size: 17,
                      color: widget.accent,
                    )
                  : Text(
                      track.position,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: EdgeInsets.only(left: track.indentLevel * 14.0),
                child: TextFormField(
                  key: ValueKey('music-track-title-${track.id.value}'),
                  initialValue: track.title,
                  decoration: InputDecoration(
                    hintText: isHeader ? 'Section title' : 'Track title',
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                  ),
                  style: TextStyle(
                    fontWeight: isHeader ? FontWeight.w700 : FontWeight.normal,
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
                    previousTrack: track,
                    rebuild: false,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: isHeader
                  ? const SizedBox.shrink()
                  : TextFormField(
                      key: ValueKey('music-track-artist-${track.id.value}'),
                      initialValue: track.artist ?? '',
                      decoration: const InputDecoration(
                        hintText: 'Artist',
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                      ),
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
                        previousTrack: track,
                        rebuild: false,
                      ),
                    ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 92,
              child: isHeader
                  ? const SizedBox.shrink()
                  : TextFormField(
                      key: ValueKey('music-track-duration-${track.id.value}'),
                      initialValue: _durationLabel(track.durationMs),
                      keyboardType: TextInputType.datetime,
                      decoration: const InputDecoration(
                        hintText: '0:00',
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                      ),
                      onChanged: (value) {
                        final parsed = _durationMs(value);
                        if (value.trim().isNotEmpty && parsed == null) return;
                        _replaceTrack(
                          medium,
                          index,
                          musicTrackWithEdits(
                            track,
                            title: track.title,
                            position: track.position,
                            artist: track.artist ?? '',
                            durationMs: parsed,
                          ),
                          previousTrack: track,
                          rebuild: false,
                        );
                      },
                    ),
            ),
            SizedBox(
              width: 132,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: 'Decrease indent',
                    visualDensity: VisualDensity.compact,
                    onPressed: track.indentLevel == 0
                        ? null
                        : () => setState(
                              () => draft.setTrackIndent(
                                medium.id,
                                index,
                                track.indentLevel - 1,
                              ),
                            ),
                    icon: const Icon(Icons.format_indent_decrease, size: 17),
                  ),
                  IconButton(
                    tooltip: 'Increase indent',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => setState(
                      () => draft.setTrackIndent(
                        medium.id,
                        index,
                        track.indentLevel + 1,
                      ),
                    ),
                    icon: const Icon(Icons.format_indent_increase, size: 17),
                  ),
                  IconButton(
                    tooltip: 'Remove track',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => setState(() {
                      draft.removeTrack(medium.id, index);
                      _selectedTrackIds.remove(track.id.value);
                    }),
                    icon: const Icon(Icons.delete_outline, size: 17),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _replaceTrack(
    MusicMedium medium,
    int index,
    MusicTrack updatedTrack, {
    required MusicTrack previousTrack,
    bool rebuild = true,
  }) {
    if (index < 0 || index >= medium.tracks.length) return;
    final currentTrack = medium.tracks[index];
    final mergedTrack = musicTrackWithEdits(
      currentTrack,
      title: updatedTrack.title != previousTrack.title
          ? updatedTrack.title
          : currentTrack.title,
      position: updatedTrack.position != previousTrack.position
          ? updatedTrack.position
          : currentTrack.position,
      artist: updatedTrack.artist != previousTrack.artist
          ? updatedTrack.artist ?? ''
          : currentTrack.artist ?? '',
      durationMs: updatedTrack.durationMs != previousTrack.durationMs
          ? updatedTrack.durationMs
          : currentTrack.durationMs,
      indentLevel: updatedTrack.indentLevel != previousTrack.indentLevel
          ? updatedTrack.indentLevel
          : currentTrack.indentLevel,
    );
    draft.replaceTrack(medium.id, index, mergedTrack);
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

String? _durationLabel(int? durationMs) {
  if (durationMs == null || durationMs < 0) return null;
  final totalSeconds = (durationMs / 1000).round();
  final minutes = totalSeconds ~/ 60;
  final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

String? _mediumDurationLabel(MusicMedium medium) {
  final durations = medium.tracks
      .where((track) => !track.isHeader && track.durationMs != null)
      .map((track) => track.durationMs!);
  var total = 0;
  var hasDuration = false;
  for (final duration in durations) {
    total += duration;
    hasDuration = true;
  }
  return hasDuration ? _durationLabel(total) : null;
}

int? _durationMs(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) return null;
  final parts = normalized.split(':');
  if (parts.length == 1) {
    final seconds = double.tryParse(parts.single);
    return seconds == null || seconds < 0 ? null : (seconds * 1000).round();
  }
  if (parts.length == 2) {
    final minutes = int.tryParse(parts[0]);
    final seconds = int.tryParse(parts[1]);
    if (minutes == null ||
        seconds == null ||
        minutes < 0 ||
        seconds < 0 ||
        seconds >= 60) {
      return null;
    }
    return (minutes * 60 + seconds) * 1000;
  }
  if (parts.length == 3) {
    final hours = int.tryParse(parts[0]);
    final minutes = int.tryParse(parts[1]);
    final seconds = int.tryParse(parts[2]);
    if (hours == null ||
        minutes == null ||
        seconds == null ||
        hours < 0 ||
        minutes < 0 ||
        minutes >= 60 ||
        seconds < 0 ||
        seconds >= 60) {
      return null;
    }
    return (hours * 3600 + minutes * 60 + seconds) * 1000;
  }
  return null;
}
