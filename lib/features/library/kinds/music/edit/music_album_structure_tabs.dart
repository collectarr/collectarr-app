import 'package:collectarr_app/features/library/edit/draft/library_entry_edit_draft.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_dropdown_pick_field.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_medium.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_draft.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_select_dialog.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Music-entry release structure editor.
///
/// The draft owns the mutable medium/track graph. This tab deliberately does
/// not route track edits through a generic catalog DTO, so headers, nesting,
/// artist credits and medium boundaries survive the save round-trip.
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
  MusicMediumId? _activeMediumId;
  final Set<String> _selectedTrackIds = <String>{};

  MusicAlbumEditDraft get draft => widget.draft;

  @override
  Widget build(BuildContext context) {
    return EditTabShell(children: _trackSections());
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
                onReorderItem: (oldIndex, newIndex) => setState(() {
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
      builder: (dialogContext) => AccentAlertDialog(
        title: Text('Remove Disc ${medium.mediumNumber}?'),
        content: Text(
          'This removes ${medium.tracks.length} track entries from the release. '
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
        details.removeWhere((row) => row['medium_id'] == medium.id.value);
        entry.set('media', details);
      }
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _discFields(medium),
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

  List<Map<String, dynamic>> _discDetails(LibraryEntryEditDraft entry) {
    final raw = entry.values['media'];
    return raw is List
        ? [
            for (final row in raw)
              if (row is Map && row['medium_id'] is String)
                Map<String, dynamic>.from(row),
          ]
        : <Map<String, dynamic>>[];
  }

  Widget _discPersonalField(MusicMedium medium, String label, String key) {
    final entry = LibraryEntryEditScope.maybeOf(context);
    final rows = entry == null ? <Map<String, dynamic>>[] : _discDetails(entry);
    final row =
        rows.where((row) => row['medium_id'] == medium.id.value).firstOrNull;
    return LibraryFormField(
        label: label,
        child: TextFormField(
          key: ValueKey('${medium.id.value}:$key'),
          initialValue: row?[key]?.toString() ?? '',
          enabled: entry != null,
          onChanged: (value) {
            final next = _discDetails(entry!);
            final details = next
                .where((row) => row['medium_id'] == medium.id.value)
                .firstOrNull;
            if (details != null) {
              details[key] = value.trim().isEmpty ? null : value.trim();
            } else {
              next.add({
                'medium_id': medium.id.value,
                key: value.trim().isEmpty ? null : value.trim(),
              });
            }
            entry.set('media', next);
          },
        ));
  }

  Widget _discFields(MusicMedium medium) =>
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
                    key: ValueKey('music-medium-title-${medium.id.value}'),
                    initialValue: medium.title ?? '',
                    onChanged: (value) =>
                        draft.updateMediumTitle(medium.id, value),
                  ))),
          SizedBox(
              width: quarter,
              child: _discPersonalField(
                  medium, 'Storage Device', 'storage_device')),
          SizedBox(
              width: quarter,
              child: _discPersonalField(medium, 'Slot', 'storage_slot')),
          SizedBox(
              width: half,
              child: LibraryFormField(
                  label: 'Matrix Nr Side A',
                  child: TextFormField(
                    key: ValueKey('music-medium-matrix-a-${medium.id.value}'),
                    initialValue: medium.matrixNumberSideA ?? '',
                    onChanged: (value) => draft.updateMediumTechnicalDetails(
                        medium.id,
                        matrixNumberSideA: value,
                        replaceMatrixNumberSideA: true),
                  ))),
          SizedBox(
              width: half,
              child: LibraryFormField(
                  label: 'Matrix Nr Side B',
                  child: TextFormField(
                    key: ValueKey('music-medium-matrix-b-${medium.id.value}'),
                    initialValue: medium.matrixNumberSideB ?? '',
                    onChanged: (value) => draft.updateMediumTechnicalDetails(
                        medium.id,
                        matrixNumberSideB: value,
                        replaceMatrixNumberSideB: true),
                  ))),
        ]);
      });

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
                    onReorderItem: (oldIndex, newIndex) => setState(
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
          const SizedBox(width: 84),
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
    if (!isHeader) return row;
    return DragTarget<String>(
      key: ValueKey('music-track-header-drop-${track.id.value}'),
      onWillAcceptWithDetails: (details) => details.data != track.id.value,
      onAcceptWithDetails: (details) => setState(
        () => draft.assignTrackToHeader(
          medium.id,
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
