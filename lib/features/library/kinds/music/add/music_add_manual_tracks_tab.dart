import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_contents.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_disc_text_field.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_track_text_field.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Manual Add editor for ordered Music discs and tracks.
final class MusicAddManualTracksTab extends StatefulWidget {
  const MusicAddManualTracksTab({
    super.key,
    required this.draft,
    required this.accent,
  });

  final MusicAddManualDraft draft;
  final Color accent;

  @override
  State<MusicAddManualTracksTab> createState() =>
      _MusicAddManualTracksTabState();
}

final class _MusicAddManualTracksTabState
    extends State<MusicAddManualTracksTab> {
  String? _activeDiscId;

  MusicAddManualDisc? get _activeDisc {
    for (final disc in widget.draft.discs) {
      if (disc.id == _activeDiscId) return disc;
    }
    return widget.draft.discs.firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final discs = widget.draft.discs;
    if (discs.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add the album discs and their tracklists.'),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _addDisc,
            icon: const Icon(Icons.add),
            label: const Text('Add Disc'),
          ),
        ],
      );
    }

    final activeDisc = _activeDisc;
    if (activeDisc == null) return const SizedBox.shrink();
    final activeIndex = discs.indexOf(activeDisc);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var index = 0; index < discs.length; index++) ...[
                      if (index > 0) const SizedBox(width: 6),
                      ChoiceChip(
                        label: Text('Disc ${index + 1}'),
                        selected: discs[index].id == activeDisc.id,
                        selectedColor: widget.accent.withValues(alpha: 0.16),
                        side: BorderSide(
                          color: discs[index].id == activeDisc.id
                              ? widget.accent
                              : Theme.of(context).dividerColor,
                        ),
                        onSelected: (_) => setState(
                          () => _activeDiscId = discs[index].id,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            IconButton(
              tooltip: 'Remove Disc ${activeIndex + 1}',
              onPressed: () => _removeDisc(activeDisc),
              icon: const Icon(Icons.delete_outline),
            ),
            OutlinedButton.icon(
              onPressed: _addDisc,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Disc'),
            ),
          ],
        ),
        _discDetails(activeDisc, activeIndex),
      ],
    );
  }

  Widget _discDetails(MusicAddManualDisc disc, int index) {
    final palette = appPalette(context);
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border.all(color: palette.divider),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Disc ${index + 1}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final fields = [
                MusicDiscTextField(
                  id: '${disc.id}-title',
                  label: 'Disc Title',
                  initialValue: disc.title,
                  onChanged: (value) => disc.title = value,
                ),
                MusicDiscTextField(
                  id: '${disc.id}-matrix-a',
                  label: 'Matrix No. Side A',
                  initialValue: disc.matrixNumberSideA,
                  onChanged: (value) => disc.matrixNumberSideA = value,
                ),
                MusicDiscTextField(
                  id: '${disc.id}-matrix-b',
                  label: 'Matrix No. Side B',
                  initialValue: disc.matrixNumberSideB,
                  onChanged: (value) => disc.matrixNumberSideB = value,
                ),
              ];
              if (constraints.maxWidth < 720) {
                return Column(
                  children: [
                    for (var fieldIndex = 0;
                        fieldIndex < fields.length;
                        fieldIndex++) ...[
                      if (fieldIndex > 0) const SizedBox(height: 8),
                      fields[fieldIndex],
                    ],
                  ],
                );
              }
              return Row(
                children: [
                  for (var fieldIndex = 0;
                      fieldIndex < fields.length;
                      fieldIndex++) ...[
                    if (fieldIndex > 0) const SizedBox(width: 8),
                    Expanded(child: fields[fieldIndex]),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Tracks',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text('${disc.tracks.length} entries'),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => setState(() {
                  disc.tracks.add(MusicAddManualTrack());
                }),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Track'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (disc.tracks.isEmpty)
            Text(
              'No tracks added',
              style: TextStyle(color: palette.textMuted),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: disc.tracks.length,
              onReorderItem: (oldIndex, newIndex) => setState(() {
                final track = disc.tracks.removeAt(oldIndex);
                disc.tracks.insert(newIndex, track);
              }),
              itemBuilder: (context, trackIndex) {
                final track = disc.tracks[trackIndex];
                return Padding(
                  key: ValueKey(track.id),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final titleField = MusicTrackTextField(
                        id: '${track.id}-title',
                        initialValue: track.title,
                        label: 'Title',
                        onChanged: (value) => track.title = value,
                      );
                      final artistField = MusicTrackTextField(
                        id: '${track.id}-artist',
                        initialValue: track.artist,
                        label: 'Artist',
                        onChanged: (value) => track.artist = value,
                      );
                      final durationField = MusicTrackTextField(
                        id: '${track.id}-duration',
                        initialValue: track.duration,
                        label: 'Length',
                        hint: 'MM:SS',
                        onChanged: (value) => track.duration = value,
                      );
                      final controls = Row(
                        children: [
                          ReorderableDragStartListener(
                            index: trackIndex,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: Icon(Icons.drag_handle, size: 18),
                            ),
                          ),
                          SizedBox(
                            width: 30,
                            child: Text('${trackIndex + 1}'),
                          ),
                          const Spacer(),
                          IconButton(
                            tooltip: 'Remove track',
                            onPressed: () => setState(
                              () => disc.tracks.removeAt(trackIndex),
                            ),
                            icon: const Icon(Icons.close, size: 18),
                          ),
                        ],
                      );
                      if (constraints.maxWidth < 680) {
                        return Column(
                          children: [
                            controls,
                            titleField,
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(child: artistField),
                                const SizedBox(width: 8),
                                SizedBox(width: 112, child: durationField),
                              ],
                            ),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          ReorderableDragStartListener(
                            index: trackIndex,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: Icon(Icons.drag_handle, size: 18),
                            ),
                          ),
                          SizedBox(
                            width: 30,
                            child: Text('${trackIndex + 1}'),
                          ),
                          Expanded(flex: 4, child: titleField),
                          const SizedBox(width: 8),
                          Expanded(flex: 3, child: artistField),
                          const SizedBox(width: 8),
                          SizedBox(width: 112, child: durationField),
                          IconButton(
                            tooltip: 'Remove track',
                            onPressed: () => setState(
                              () => disc.tracks.removeAt(trackIndex),
                            ),
                            icon: const Icon(Icons.close, size: 18),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _addDisc() {
    final disc = MusicAddManualDisc();
    setState(() {
      widget.draft.discs.add(disc);
      _activeDiscId = disc.id;
    });
  }

  void _removeDisc(MusicAddManualDisc disc) {
    final index = widget.draft.discs.indexOf(disc);
    setState(() {
      widget.draft.discs.remove(disc);
      _activeDiscId = widget.draft.discs.isEmpty
          ? null
          : widget.draft
              .discs[index.clamp(0, widget.draft.discs.length - 1).toInt()].id;
    });
  }
}
