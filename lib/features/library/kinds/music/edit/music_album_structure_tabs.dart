import 'package:collectarr_app/features/library/kinds/music/forms/music_disc_tab_button.dart';
import 'package:collectarr_app/features/library/edit/draft/library_entry_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_track_list_editor.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/theme/app_typography.dart';
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
          child: _addDiscButton(),
        ),
      ];
    }
    final activeDisc = _activeDisc();
    if (activeDisc == null) return const [];
    return [
      _discTabsRow(activeDisc),
      const SizedBox(height: 12),
      _discTitleField(activeDisc),
      _tracksLabel(),
      _discTrackEditor(activeDisc),
    ];
  }

  Widget _discTabsRow(MusicDisc activeDisc) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 32,
            child: ReorderableListView.builder(
              scrollDirection: Axis.horizontal,
              buildDefaultDragHandles: false,
              itemCount: draft.discs.length,
              onReorderItem: (oldIndex, newIndex) => _change(() {
                draft.discList.reorderDisc(oldIndex, newIndex);
                _selectedTrackIds.clear();
              }),
              itemBuilder: (context, index) {
                final candidate = draft.discs[index];
                return Padding(
                  key: ValueKey('music-disc-${candidate.id.value}'),
                  padding: const EdgeInsets.only(right: 4),
                  child: ReorderableDragStartListener(
                    index: index,
                    child: MusicDiscTabButton(
                      number: candidate.discNumber,
                      title: candidate.title,
                      format: candidate.format,
                      selected: candidate.id == activeDisc.id,
                      onPressed: () => _change(() {
                        _activeDiscId = candidate.id;
                        _selectedTrackIds.clear();
                      }),
                      onRemove: () => _removeDisc(candidate),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        _addDiscButton(),
      ],
    );
  }

  Widget _addDiscButton() {
    return InkWell(
      mouseCursor: SystemMouseCursors.click,
      borderRadius: BorderRadius.circular(4),
      onTap: () => _change(() {
        draft.discList.addDisc();
        _activeDiscId = draft.discs.last.id;
        _selectedTrackIds.clear();
      }),
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF383838),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFF484848)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 14, color: Colors.white),
            SizedBox(width: 4),
            Text(
              'Add Disc',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _discTitleField(MusicDisc disc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Disc Title',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFFAAAAAA),
          ),
        ),
        const SizedBox(height: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 470),
          child: SizedBox(
            height: 32,
            child: TextFormField(
              key: ValueKey('music-disc-title-${disc.id.value}'),
              initialValue: disc.title ?? '',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Disc #${disc.discNumber}',
                hintStyle: const TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 13,
                ),
                filled: true,
                fillColor: const Color(0xFF444444),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFF383838)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFF383838)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  borderSide: BorderSide(color: Color(0xFF5EB1DE)),
                ),
              ),
              onChanged: (value) {
                _change(() => draft.discList.updateDiscTitle(disc.id, value));
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _tracksLabel() {
    return const Padding(
      padding: EdgeInsets.only(top: 14, bottom: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Tracks',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
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
      draft.discList.removeDisc(disc.id);
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
        _trackTable(disc),
        const SizedBox(height: 10),
        _bottomActions(disc),
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

  Widget _selectionToolbar(MusicDisc disc) {
    final destinations = draft.discs
        .where((candidate) => candidate.id != disc.id)
        .toList(growable: false);
    final allSelected = disc.tracks.isNotEmpty &&
        disc.tracks.every((t) => _selectedTrackIds.contains(t.id.value));

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF5EB1DE),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
        border: Border.all(color: const Color(0xFF7CBFE4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Cancel, Divider, All
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                mouseCursor: SystemMouseCursors.click,
                borderRadius: BorderRadius.circular(3),
                onTap: () => _change(_selectedTrackIds.clear),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.close, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 18,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: Colors.white.withValues(alpha: 0.35),
              ),
              InkWell(
                mouseCursor: SystemMouseCursors.click,
                borderRadius: BorderRadius.circular(3),
                onTap: () => _change(() => _toggleAllTracks(disc)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 1.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        alignment: Alignment.center,
                        child: allSelected
                            ? const Icon(Icons.check,
                                size: 12, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'All',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Center: Item count badge
          Container(
            height: 24,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF40A3D8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF7CBFE4)),
            ),
            alignment: Alignment.center,
            child: Text(
              '${_selectedTrackIds.length} of ${disc.tracks.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),

          // Right: Aa Autocap, (Move to other disc), Remove
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                mouseCursor: SystemMouseCursors.click,
                borderRadius: BorderRadius.circular(3),
                onTap: () => _change(
                  () => draft.trackList.autocapTracks(
                    disc.id,
                    Set.of(_selectedTrackIds),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Aa',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFamily: kAppFontFamily,
                          fontFamilyFallback: kAppFontFamilyFallback,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Autocap',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (destinations.isNotEmpty) ...[
                Container(
                  width: 1,
                  height: 18,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  color: Colors.white.withValues(alpha: 0.35),
                ),
                PopupMenuButton<MusicDiscId>(
                  tooltip: 'Move selected tracks to another disc',
                  onSelected: (destinationId) {
                    _change(() {
                      draft.trackList.moveTracksToDisc(
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
                  child: const MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.album_outlined,
                              size: 15, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Move to other disc',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              Container(
                width: 1,
                height: 18,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: Colors.white.withValues(alpha: 0.35),
              ),
              InkWell(
                mouseCursor: SystemMouseCursors.click,
                borderRadius: BorderRadius.circular(3),
                onTap: () => _change(() {
                  draft.trackList
                      .removeTracks(disc.id, Set.of(_selectedTrackIds));
                  _selectedTrackIds.clear();
                }),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete_outline, size: 15, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Remove',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _trackTable(MusicDisc disc) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth =
            constraints.hasBoundedWidth && constraints.maxWidth > 650
                ? constraints.maxWidth
                : 650.0;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tableWidth,
            child: Column(
              children: [
                if (_selectedTrackIds.isNotEmpty)
                  _selectionToolbar(disc)
                else
                  _trackTableHeader(disc),
                if (disc.tracks.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(18),
                    child: Center(
                      child: Text(
                        'No tracks on this disc yet.',
                        style: TextStyle(color: Color(0xFFAAAAAA)),
                      ),
                    ),
                  )
                else
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    primary: false,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    itemCount: disc.tracks.length,
                    onReorderItem: (oldIndex, newIndex) => _change(
                      () => draft.trackList.reorderTrack(
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
    const headerStyle = TextStyle(
      color: Colors.white,
      fontSize: 13,
      fontWeight: FontWeight.w700,
    );
    const borderSide = BorderSide(color: Color(0xFF484848));

    return Container(
      height: 36,
      decoration: const BoxDecoration(
        color: Color(0xFF383838),
        borderRadius: BorderRadius.vertical(top: Radius.circular(3)),
      ),
      child: Row(
        children: [
          // Select column (width 30px)
          InkWell(
            mouseCursor: SystemMouseCursors.click,
            onTap: disc.tracks.isEmpty
                ? null
                : () => _change(() => _toggleAllTracks(disc)),
            child: Container(
              width: 30,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                border: Border(right: borderSide),
              ),
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  border:
                      Border.all(color: const Color(0xFF888888), width: 1.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          // Drag column (width 30px)
          Container(
            width: 30,
            decoration: const BoxDecoration(
              border: Border(right: borderSide),
            ),
          ),
          // Rank column (width 30px)
          Container(
            width: 30,
            decoration: const BoxDecoration(
              border: Border(right: borderSide),
            ),
          ),
          // Title / Artist column (flex 1)
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                border: Border(right: borderSide),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: const Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text('Title', style: headerStyle),
                    ),
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text('Artist', style: headerStyle),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Length column (width 70px)
          const SizedBox(
            width: 70,
            child: Center(
              child: Text('Length', style: headerStyle),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleAllTracks(MusicDisc disc) {
    final allSelected = disc.tracks.isNotEmpty &&
        disc.tracks
            .every((track) => _selectedTrackIds.contains(track.id.value));
    _selectedTrackIds.clear();
    if (!allSelected) {
      _selectedTrackIds.addAll(disc.tracks.map((track) => track.id.value));
    }
  }

  Widget _trackEditorRow(MusicDisc disc, MusicTrack track, int index) {
    final isHeader = track.isHeader;
    final isSelected = _selectedTrackIds.contains(track.id.value);
    const cellDivider = BorderSide(color: Color(0xFF383838));

    final rowContent = Container(
      key: ValueKey('music-track-row-${track.id.value}'),
      height: 34,
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        color: isHeader
            ? widget.accent.withValues(alpha: 0.12)
            : const Color(0xFF262626),
        border: isHeader
            ? Border(left: BorderSide(color: widget.accent, width: 3))
            : null,
      ),
      child: Row(
        children: [
          // Select column (30px)
          InkWell(
            mouseCursor: SystemMouseCursors.click,
            onTap: () => _change(() {
              if (isSelected) {
                _selectedTrackIds.remove(track.id.value);
              } else {
                _selectedTrackIds.add(track.id.value);
              }
            }),
            child: Container(
              width: 30,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                border: Border(right: cellDivider),
              ),
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? Colors.white : const Color(0xFF888888),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
                alignment: Alignment.center,
                child: isSelected
                    ? const Icon(Icons.check,
                        size: 12, color: Color(0xFF262626))
                    : null,
              ),
            ),
          ),
          // Drag column (30px)
          Container(
            width: 30,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border(right: cellDivider),
            ),
            child: ReorderableDragStartListener(
              index: index,
              child: const MouseRegion(
                cursor: SystemMouseCursors.grab,
                child: Icon(
                  Icons.menu,
                  size: 15,
                  color: Color(0xFF888888),
                ),
              ),
            ),
          ),
          // Rank column (30px)
          Container(
            width: 30,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border(right: cellDivider),
            ),
            child: isHeader
                ? Icon(
                    Icons.folder,
                    size: 16,
                    color: widget.accent,
                  )
                : Draggable<String>(
                    data: track.id.value,
                    feedback: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(4),
                      color: const Color(0xFF383838),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        child: Text(
                          track.title.isEmpty
                              ? 'Track ${track.position}'
                              : track.title,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ),
                    child: Text(
                      track.position,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
          ),
          // Title / Artist column
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                border: Border(right: cellDivider),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: isHeader
                  ? Padding(
                      padding: EdgeInsets.only(left: track.indentLevel * 14.0),
                      child: _trackCellInput(
                        id: 'music-track-title-${track.id.value}',
                        initialValue: track.title,
                        hint: 'Section title',
                        isHeader: true,
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
                    )
                  : Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: Padding(
                            padding:
                                EdgeInsets.only(left: track.indentLevel * 14.0),
                            child: _trackCellInput(
                              id: 'music-track-title-${track.id.value}',
                              initialValue: track.title,
                              hint: 'Title',
                              isHeader: false,
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
                        const SizedBox(width: 4),
                        Expanded(
                          flex: 4,
                          child: _trackCellInput(
                            id: 'music-track-artist-${track.id.value}',
                            initialValue: track.artist ?? '',
                            hint: 'Artist',
                            isHeader: false,
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
                      ],
                    ),
            ),
          ),
          // Length column (70px)
          SizedBox(
            width: 70,
            child: isHeader
                ? const SizedBox.shrink()
                : Center(
                    child: SizedBox(
                      width: 62,
                      child: _trackCellInput(
                        id: 'music-track-duration-${track.id.value}',
                        initialValue:
                            widget.draft.trackList.trackDurationText(track),
                        hint: '0:00',
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.datetime,
                        isHeader: false,
                        onChanged: (value) {
                          widget.draft.trackList
                              .setTrackDurationText(disc.id, index, value);
                          widget.onChanged?.call();
                        },
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );

    if (!isHeader) return rowContent;
    return DragTarget<String>(
      key: ValueKey('music-track-header-drop-${track.id.value}'),
      onWillAcceptWithDetails: (details) => details.data != track.id.value,
      onAcceptWithDetails: (details) => _change(
        () => draft.trackList.assignTrackToHeader(
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
        child: rowContent,
      ),
    );
  }

  Widget _trackCellInput({
    required String id,
    required String initialValue,
    required String hint,
    required ValueChanged<String> onChanged,
    bool isHeader = false,
    TextAlign textAlign = TextAlign.start,
    TextInputType? keyboardType,
  }) {
    return SizedBox(
      height: 28,
      child: TextFormField(
        key: ValueKey(id),
        initialValue: initialValue,
        textAlign: textAlign,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isHeader ? FontWeight.w700 : FontWeight.normal,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: const Color(0xFF444444),
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF888888),
            fontSize: 13,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xFF383838)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xFF383838)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            borderSide: BorderSide(color: Color(0xFF5EB1DE)),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _bottomActions(MusicDisc disc) {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _actionButton(
            icon: Icons.folder,
            label: 'Add Header',
            onTap: () =>
                _change(() => draft.trackList.addTrack(disc.id, header: true)),
          ),
          const SizedBox(width: 8),
          _actionButton(
            icon: Icons.add,
            label: 'Add Track',
            onTap: () =>
                _change(() => draft.trackList.addTrack(disc.id, header: false)),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      mouseCursor: SystemMouseCursors.click,
      borderRadius: BorderRadius.circular(4),
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF444444),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFF555555)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
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
    draft.trackList.replaceTrack(disc.id, currentIndex, mergedTrack);
    if (rebuild) {
      _change(() {});
    } else {
      widget.onChanged?.call();
    }
  }
}
