import 'package:collectarr_app/features/library/kinds/music/forms/music_disc_fields_layout.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_disc_tab_button.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_managed_vocabulary_field.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_vocabulary_edit_change.dart';
import 'package:collectarr_app/features/library/edit/draft/library_entry_edit_draft.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_disc_text_field.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_track_text_field.dart';
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
    this.onChanged,
    this.discPersonalFieldBuilder,
    this.onDiscRemoved,
  });

  final MusicAlbumEditDraft draft;
  final Color accent;
  final VoidCallback? onChanged;
  final Widget Function(MusicDisc disc, String label, String key)?
      discPersonalFieldBuilder;
  final ValueChanged<String>? onDiscRemoved;

  @override
  ConsumerState<MusicAlbumStructureTab> createState() =>
      _MusicAlbumStructureTabState();
}

final class _MusicAlbumStructureTabState
    extends ConsumerState<MusicAlbumStructureTab> {
  MusicDiscId? _activeDiscId;
  final Set<String> _selectedTrackIds = <String>{};

  MusicAlbumEditDraft get draft => widget.draft;
  void _change(VoidCallback change) {
    setState(change);
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _trackSections(),
    );
  }

  List<Widget> _trackSections() {
    if (draft.discs.isEmpty) {
      return [
        const Text('This release does not have any discs yet.'),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => _change(() {
              draft.addDisc();
              _activeDiscId = draft.discs.last.id;
            }),
            icon: const Icon(Icons.add),
            label: const Text('Add Disc'),
          ),
        ),
      ];
    }
    final activeDisc = _activeDisc();
    if (activeDisc == null) return const [];
    return [
      Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 38,
              child: ReorderableListView.builder(
                scrollDirection: Axis.horizontal,
                buildDefaultDragHandles: false,
                itemCount: draft.discs.length,
                onReorderItem: (oldIndex, newIndex) => _change(() {
                  draft.reorderDisc(oldIndex, newIndex);
                  _selectedTrackIds.clear();
                }),
                itemBuilder: (context, index) {
                  final candidate = draft.discs[index];
                  return Padding(
                    key: ValueKey('music-disc-${candidate.id.value}'),
                    padding: const EdgeInsets.only(right: 6),
                    child: ReorderableDragStartListener(
                      index: index,
                      child: MusicDiscTabButton(
                        number: candidate.discNumber,
                        selected: candidate.id == activeDisc.id,
                        onPressed: () => _change(() {
                          _activeDiscId = candidate.id;
                          _selectedTrackIds.clear();
                        }),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          IconButton(
            tooltip: 'Remove disc ${activeDisc.discNumber}',
            visualDensity: VisualDensity.compact,
            onPressed: () => _removeDisc(activeDisc),
            icon: const Icon(Icons.delete_outline, size: 18),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () => _change(() {
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
      _discTrackEditor(activeDisc),
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
    _change(() {
      final entry = LibraryEntryEditScope.maybeOf(context);
      if (entry != null) {
        final details = _discDetails(entry);
        details.removeWhere((row) => row['disc_id'] == disc.id.value);
        entry.set('media', details);
      }
      widget.onDiscRemoved?.call(disc.id.value);
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
                onPressed: () => _change(
                  () => draft.addTrack(disc.id, header: true),
                ),
                icon: const Icon(Icons.folder_outlined, size: 16),
                label: const Text('Add Header'),
              ),
              OutlinedButton.icon(
                onPressed: () => _change(
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
    if (widget.discPersonalFieldBuilder != null) {
      return widget.discPersonalFieldBuilder!(disc, label, key);
    }
    void save(String? value) {
      if (entry == null) return;
      final next = _discDetails(entry);
      final details =
          next.where((row) => row['disc_id'] == disc.id.value).firstOrNull;
      final normalized = value?.trim();
      if (details != null) {
        details[key] = normalized?.isEmpty == true ? null : normalized;
      } else {
        next.add({
          'disc_id': disc.id.value,
          key: normalized?.isEmpty == true ? null : normalized
        });
      }
      entry.set('media', next);
      if (key == 'storage_device') {
        final listName = MusicVocabularies.storageDevice.key;
        entry.pendingChanges['vocabulary:$listName'] =
            LibraryVocabularyEditChange([
          if (normalized?.isNotEmpty == true)
            (listName: listName, value: normalized!, mediaKind: 'music'),
        ]);
      }
      _change(() {});
    }

    if (key == 'storage_device') {
      return LibraryManagedVocabularyField(
          label: label,
          listName: MusicVocabularies.storageDevice.key,
          mediaKind: 'music',
          value: row?[key]?.toString(),
          enabled: entry != null,
          onChanged: save);
    }
    return LibraryFormField(
        label: label,
        child: LibraryTextFormControl(
            key: ValueKey('${disc.id.value}:$key'),
            initialValue: row?[key]?.toString() ?? '',
            enabled: entry != null,
            onChanged: save));
  }

  Widget _discFields(MusicDisc disc) => MusicDiscFieldsLayout(
        title: MusicDiscTextField(
            id: 'music-disc-title-${disc.id.value}',
            label: 'Disc Title',
            initialValue: disc.title ?? '',
            onChanged: (value) {
              draft.updateDiscTitle(disc.id, value);
              widget.onChanged?.call();
            }),
        storage: _discPersonalField(disc, 'Storage Device', 'storage_device'),
        slot: _discPersonalField(disc, 'Slot', 'storage_slot'),
        matrixA: MusicDiscTextField(
            id: 'music-disc-matrix-a-${disc.id.value}',
            label: 'Matrix No. Side A',
            initialValue: disc.matrixNumberSideA ?? '',
            onChanged: (value) {
              draft.updateDiscTechnicalDetails(disc.id,
                  matrixNumberSideA: value, replaceMatrixNumberSideA: true);
              widget.onChanged?.call();
            }),
        matrixB: MusicDiscTextField(
            id: 'music-disc-matrix-b-${disc.id.value}',
            label: 'Matrix No. Side B',
            initialValue: disc.matrixNumberSideB ?? '',
            onChanged: (value) {
              draft.updateDiscTechnicalDetails(disc.id,
                  matrixNumberSideB: value, replaceMatrixNumberSideB: true);
              widget.onChanged?.call();
            }),
      );

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
            onPressed: () => _change(_selectedTrackIds.clear),
            icon: const Icon(Icons.close, size: 16),
            label: const Text('Cancel'),
          ),
          TextButton.icon(
            onPressed: () => _change(() {
              _selectedTrackIds
                ..clear()
                ..addAll(disc.tracks.map((track) => track.id.value));
            }),
            icon: const Icon(Icons.check_box_outlined, size: 16),
            label: const Text('All'),
          ),
          TextButton.icon(
            onPressed: () => _change(
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
                _change(() {
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
            onPressed: () => _change(() {
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
                    onReorderItem: (oldIndex, newIndex) => _change(
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
    final style = Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).hintColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
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
                  : (_) => _change(() => _toggleAllTracks(disc)),
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
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        child: Row(
          children: [
            SizedBox(
              width: 34,
              child: Checkbox(
                value: _selectedTrackIds.contains(track.id.value),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (selected) => _change(() {
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
                child: MusicTrackTextField(
                  id: 'music-track-title-${track.id.value}',
                  initialValue: track.title,
                  hint: isHeader ? 'Section title' : 'Track title',
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
                  : MusicTrackTextField(
                      id: 'music-track-artist-${track.id.value}',
                      initialValue: track.artist ?? '',
                      hint: 'Artist',
                      maxLines: null,
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
                  : MusicTrackTextField(
                      id: 'music-track-duration-${track.id.value}',
                      initialValue: widget.draft.trackDurationText(track),
                      keyboardType: TextInputType.datetime,
                      hint: 'MM:SS',
                      onChanged: (value) {
                        widget.draft
                            .setTrackDurationText(disc.id, index, value);
                        widget.onChanged?.call();
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
                    onPressed: () => _change(() {
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
      onAcceptWithDetails: (details) => _change(
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
    final currentDisc =
        draft.discs.where((candidate) => candidate.id == disc.id).firstOrNull;
    if (currentDisc == null) return;
    final currentIndex =
        currentDisc.tracks.indexWhere((track) => track.id == previousTrack.id);
    if (currentIndex < 0) return;
    final currentTrack = currentDisc.tracks[currentIndex];
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
    draft.replaceTrack(disc.id, currentIndex, mergedTrack);
    if (rebuild) {
      _change(() {});
    } else {
      widget.onChanged?.call();
    }
  }
}
