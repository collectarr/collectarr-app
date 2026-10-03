import 'package:collectarr_app/features/library/edit/draft/library_entry_edit_draft.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_draft.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Music-entry release structure editor.
///
/// The draft owns the mutable disc/track graph. This tab deliberately does
/// not route track edits through a generic catalog DTO, so headers, nesting,
/// artist credits and disc boundaries survive the save round-trip.
final class MusicAlbumStructureTab extends ConsumerStatefulWidget {
  const MusicAlbumStructureTab({
    super.key,
    required this.draft,
    required this.accent,
  });

  final MusicAlbumEditDraft draft;
  final Color accent;

  @override
  ConsumerState<MusicAlbumStructureTab> createState() =>
      _MusicAlbumStructureTabState();
}

final class _MusicAlbumStructureTabState
    extends ConsumerState<MusicAlbumStructureTab> {
  MusicDiscId? _activeDiscId;
  final Set<String> _selectedTrackIds = <String>{};

  MusicAlbumEditDraft get draft => widget.draft;

  @override
  Widget build(BuildContext context) {
    return EditTabShell(children: _trackSections());
  }

  List<Widget> _trackSections() {
    if (draft.discs.isEmpty) {
      return [
        const Text('This release does not have any discs yet.'),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => setState(() {
              draft.addDisc();
              _activeDiscId = draft.discs.last.id;
            }),
            icon: const Icon(Icons.add),
            label: const Text('Add Disc'),
          ),
        ),
      ];
    }
    final disc = _activeDisc();
    if (disc == null) return const [];
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
                itemCount: draft.discs.length,
                onReorderItem: (oldIndex, newIndex) => setState(() {
                  draft.reorderDisc(oldIndex, newIndex);
                  _selectedTrackIds.clear();
                }),
                itemBuilder: (context, index) {
                  final disc = draft.discs[index];
                  return Padding(
                    key: ValueKey('music-disc-${disc.id.value}'),
                    padding: const EdgeInsets.only(right: 6),
                    child: ReorderableDragStartListener(
                      index: index,
                      child: ChoiceChip(
                        label: Text(
                          'Disc ${disc.discNumber} - '
                          '${disc.effectiveTrackCount} tracks',
                        ),
                        selected: disc.id == disc.id,
                        onSelected: (_) => setState(() {
                          _activeDiscId = disc.id;
                          _selectedTrackIds.clear();
                        }),
                        selectedColor: widget.accent.withValues(alpha: 0.16),
                        side: BorderSide(
                          color: disc.id == disc.id
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
            tooltip: 'Remove disc ${disc.discNumber}',
            visualDensity: VisualDensity.compact,
            onPressed: () => _removeDisc(disc),
            icon: const Icon(Icons.delete_outline, size: 18),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () => setState(() {
              draft.addDisc();
              _activeDiscId = draft.discs.last.id;
              _selectedTrackIds.clear();
            }),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Disc'),
          ),
        ],
      ),
      const SizedBox(height: 8),
      EditSection(
        title: 'Disc ${disc.discNumber}',
        accent: widget.accent,
        child: _discTrackEditor(disc),
      ),
    ];
  }

  Future<void> _removeDisc(MusicDisc disc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AccentAlertDialog(
        title: Text('Remove Disc ${disc.discNumber}?'),
        content: Text(
          'This removes ${disc.tracks.length} track entries from the release. '
          'Storage, slot, and matrix details for this disc will also be removed when you save.',
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
      final entry = LibraryEntryEditScope.maybeOf(context);
      if (entry != null) {
        final details = _discDetails(entry);
        details.removeWhere((row) => row['disc_id'] == disc.id.value);
        entry.set('media', details);
      }
      draft.removeDisc(disc.id);
      _activeDiscId = draft.discs.isEmpty ? null : draft.discs.first.id;
      _selectedTrackIds.clear();
    });
  }

  MusicDisc? _activeDisc() {
    for (final disc in draft.discs) {
      if (disc.id == _activeDiscId) return disc;
    }
    if (draft.discs.isEmpty) return null;
    return draft.discs.first;
  }

  Widget _discTrackEditor(MusicDisc disc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _discFields(disc),
        const SizedBox(height: 12),
        if (_selectedTrackIds.isNotEmpty) _selectionToolbar(disc),
        _trackTable(disc),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => setState(
                  () => draft.addTrack(disc.id, header: true),
                ),
                icon: const Icon(Icons.folder_outlined, size: 16),
                label: const Text('Add Header'),
              ),
              OutlinedButton.icon(
                onPressed: () => setState(
                  () => draft.addTrack(disc.id, header: false),
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

  List<Map<String, dynamic>> _discDetails(LibraryEntryEditDraft entry) {
    final raw = entry.values['media'];
    return raw is List
        ? [
            for (final row in raw)
              if (row is Map && row['disc_id'] is String)
                Map<String, dynamic>.from(row),
          ]
        : <Map<String, dynamic>>[];
  }

  Widget _discPersonalField(MusicDisc disc, String label, String key) {
    final entry = LibraryEntryEditScope.maybeOf(context);
    final rows = entry == null ? <Map<String, dynamic>>[] : _discDetails(entry);
    final row =
        rows.where((row) => row['disc_id'] == disc.id.value).firstOrNull;
    return LibraryFormField(
        label: label,
        child: TextFormField(
          key: ValueKey('${disc.id.value}:$key'),
          initialValue: row?[key]?.toString() ?? '',
          enabled: entry != null,
          onChanged: (value) {
            final next = _discDetails(entry!);
            final details = next
                .where((row) => row['disc_id'] == disc.id.value)
                .firstOrNull;
            if (details != null) {
              details[key] = value.trim().isEmpty ? null : value.trim();
            } else {
              next.add({
                'disc_id': disc.id.value,
                key: value.trim().isEmpty ? null : value.trim(),
              });
            }
            entry.set('media', next);
          },
        ));
  }

  Widget _discFields(MusicDisc disc) =>
      LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth >= 680;
        final half =
            wide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;
        final quarter = wide ? (half - 12) / 2 : constraints.maxWidth;
        return Wrap(spacing: 12, runSpacing: 12, children: [
          SizedBox(
              width: half,
              child: LibraryFormField(
                  label: 'Disc Title',
                  child: TextFormField(
                    key: ValueKey('music-disc-title-${disc.id.value}'),
                    initialValue: disc.title ?? '',
                    onChanged: (value) =>
                        draft.updateDiscTitle(disc.id, value),
                  ))),
          SizedBox(
              width: quarter,
              child: _discPersonalField(
                  disc, 'Storage Device', 'storage_device')),
          SizedBox(
              width: quarter,
              child: _discPersonalField(disc, 'Slot', 'storage_slot')),
          SizedBox(
              width: half,
              child: LibraryFormField(
                  label: 'Matrix Nr Side A',
                  child: TextFormField(
                    key: ValueKey('music-disc-matrix-a-${disc.id.value}'),
                    initialValue: disc.matrixNumberSideA ?? '',
                    onChanged: (value) => draft.updateDiscTechnicalDetails(
                        disc.id,
                        matrixNumberSideA: value,
                        replaceMatrixNumberSideA: true),
                  ))),
          SizedBox(
              width: half,
              child: LibraryFormField(
                  label: 'Matrix Nr Side B',
                  child: TextFormField(
                    key: ValueKey('music-disc-matrix-b-${disc.id.value}'),
                    initialValue: disc.matrixNumberSideB ?? '',
                    onChanged: (value) => draft.updateDiscTechnicalDetails(
                        disc.id,
                        matrixNumberSideB: value,
                        replaceMatrixNumberSideB: true),
                  ))),
        ]);
      });

  Widget _selectionToolbar(MusicDisc disc) {
    final destinations = draft.discs
        .where((candidate) => candidate.id != disc.id)
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
            '${_selectedTrackIds.length} of ${disc.tracks.length} selected',
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
                ..addAll(disc.tracks.map((track) => track.id.value));
            }),
            icon: const Icon(Icons.check_box_outlined, size: 16),
            label: const Text('All'),
          ),
          TextButton.icon(
            onPressed: () => setState(
              () => draft.autocapTracks(
                disc.id,
                Set.of(_selectedTrackIds),
              ),
            ),
            icon: const Icon(Icons.text_fields, size: 16),
            label: const Text('Autocap'),
          ),
          if (destinations.isNotEmpty)
            PopupMenuButton<MusicDiscId>(
              tooltip: 'Move selected tracks to another disc',
              onSelected: (destinationId) {
                setState(() {
                  draft.moveTracksToDisc(
                    sourceId: disc.id,
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
                    child: Text('Disc ${destination.discNumber}'),
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
              draft.removeTracks(disc.id, Set.of(_selectedTrackIds));
              _selectedTrackIds.clear();
            }),
            icon: const Icon(Icons.delete_outline, size: 16),
            label: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Widget _trackTable(MusicDisc disc) {
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
                _trackTableHeader(disc),
                if (disc.tracks.isEmpty)
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
                    itemCount: disc.tracks.length,
                    onReorderItem: (oldIndex, newIndex) => setState(
                      () => draft.reorderTrack(
                        disc.id,
                        oldIndex,
                        newIndex,
                      ),
                    ),
                    itemBuilder: (context, index) => _trackEditorRow(
                      disc,
                      disc.tracks[index],
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

  Widget _trackTableHeader(MusicDisc disc) {
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
              value: _headerSelectionValue(disc),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: disc.tracks.isEmpty
                  ? null
                  : (_) => setState(() => _toggleAllTracks(disc)),
            ),
          ),
          const SizedBox(width: 30),
          SizedBox(width: 48, child: Text('#', style: style)),
          Expanded(flex: 5, child: Text('Title', style: style)),
          const SizedBox(width: 8),
          Expanded(flex: 3, child: Text('Artist', style: style)),
          const SizedBox(width: 8),
          SizedBox(width: 92, child: Text('Length', style: style)),
          const SizedBox(width: 84),
        ],
      ),
    );
  }

  bool? _headerSelectionValue(MusicDisc disc) {
    if (disc.tracks.isEmpty) return false;
    final selectedCount = disc.tracks
        .where((track) => _selectedTrackIds.contains(track.id.value))
        .length;
    if (selectedCount == 0) return false;
    if (selectedCount == disc.tracks.length) return true;
    return null;
  }

  void _toggleAllTracks(MusicDisc disc) {
    final allSelected = _headerSelectionValue(disc) == true;
    _selectedTrackIds.clear();
    if (!allSelected) {
      _selectedTrackIds.addAll(disc.tracks.map((track) => track.id.value));
    }
  }

  Widget _trackEditorRow(MusicDisc disc, MusicTrack track, int index) {
    final isHeader = track.isHeader;
    final rowColor = isHeader
        ? widget.accent.withValues(alpha: 0.07)
        : (index.isEven
            ? Theme.of(context).colorScheme.surface
            : Theme.of(context).colorScheme.surface.withValues(alpha: 0.55));
    final row = Container(
      key: ValueKey('music-track-row-${track.id.value}'),
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
                    disc,
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
                        disc,
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
                          disc,
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
              width: 84,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!isHeader)
                    Draggable<String>(
                      data: track.id.value,
                      feedback: Material(
                        elevation: 5,
                        child: Chip(
                          avatar: const Icon(Icons.drag_indicator, size: 16),
                          label: Text(track.title),
                        ),
                      ),
                      childWhenDragging: Icon(
                        Icons.drive_file_move_outline,
                        size: 18,
                        color: Theme.of(context).disabledColor,
                      ),
                      child: Tooltip(
                        message: 'Drag this track onto a header',
                        child: Icon(
                          Icons.drive_file_move_outline,
                          size: 18,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ),
                  if (!isHeader) const SizedBox(width: 4),
                  IconButton(
                    tooltip: isHeader ? 'Remove header' : 'Remove track',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => setState(() {
                      draft.removeTrack(disc.id, index);
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
    if (!isHeader) return row;
    return DragTarget<String>(
      key: ValueKey('music-track-header-drop-${track.id.value}'),
      onWillAcceptWithDetails: (details) => details.data != track.id.value,
      onAcceptWithDetails: (details) => setState(
        () => draft.assignTrackToHeader(
          disc.id,
          trackId: details.data,
          headerId: track.id.value,
        ),
      ),
      builder: (context, candidates, rejected) => DecoratedBox(
        decoration: candidates.isEmpty
            ? const BoxDecoration()
            : BoxDecoration(
                border: Border.all(color: widget.accent, width: 2),
              ),
        child: row,
      ),
    );
  }

  void _replaceTrack(
    MusicDisc disc,
    int index,
    MusicTrack updatedTrack, {
    required MusicTrack previousTrack,
    bool rebuild = true,
  }) {
    if (index < 0 || index >= disc.tracks.length) return;
    final currentTrack = disc.tracks[index];
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
    draft.replaceTrack(disc.id, index, mergedTrack);
    if (rebuild) setState(() {});
  }
}

String? _durationLabel(int? durationMs) {
  if (durationMs == null || durationMs < 0) return null;
  final totalSeconds = (durationMs / 1000).round();
  final minutes = totalSeconds ~/ 60;
  final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
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
