import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_contents.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_structure_tabs.dart';
import 'package:collectarr_app/features/library/kinds/music/entries/music_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_managed_vocabulary_field.dart';
import 'package:flutter/material.dart';

/// Manual Add reuses the complete Music disc/track editor, including headers and bulk actions.
class MusicAddManualTracksTab extends StatefulWidget {
  const MusicAddManualTracksTab(
      {super.key,
      required this.draft,
      required this.accent,
      required this.request});
  final MusicAddManualDraft draft;
  final Color accent;
  final LibraryAddManualPaneRequest request;
  @override
  State<MusicAddManualTracksTab> createState() =>
      _MusicAddManualTracksTabState();
}

class _MusicAddManualTracksTabState extends State<MusicAddManualTracksTab> {
  late final MusicAlbumEditDraft _editor;
  @override
  void initState() {
    super.initState();
    _editor = MusicAlbumEditDraft.fromAlbum(MusicAlbum(
      id: const CatalogItemRef(
        kind: CatalogMediaKind.music,
        id: 'manual-music',
      ),
      title: widget.draft.catalogTitle,
      discs: [
        for (final (index, disc) in widget.draft.discs.indexed)
          MusicDisc(
              id: MusicDiscId(disc.id),
              discNumber: index + 1,
              title: disc.title,
              matrixNumberSideA: disc.matrixNumberSideA,
              matrixNumberSideB: disc.matrixNumberSideB,
              tracks: [
                for (final (trackIndex, track) in disc.tracks.indexed)
                  MusicTrack(
                    id: MusicTrackId(track.id),
                    position: track.isHeader
                        ? ''
                        : track.position.isEmpty
                            ? '${trackIndex + 1}'
                            : track.position,
                    title: track.title,
                    artist: track.artist,
                    durationMs: track.durationMs,
                    isHeader: track.isHeader,
                    indentLevel: track.indentLevel,
                    parentHeaderId: track.parentHeaderId,
                  )
              ])
      ],
    ));
    for (final disc in widget.draft.discs) {
      for (var index = 0; index < disc.tracks.length; index++) {
        _editor.setTrackDurationText(
            MusicDiscId(disc.id), index, disc.tracks[index].duration);
      }
    }
  }

  void _sync() {
    widget.draft.discs
      ..clear()
      ..addAll([
        for (final disc in _editor.discs)
          MusicAddManualDisc(
              id: disc.id.value,
              title: disc.title ?? '',
              matrixNumberSideA: disc.matrixNumberSideA ?? '',
              matrixNumberSideB: disc.matrixNumberSideB ?? '',
              tracks: [
                for (final track in disc.tracks)
                  MusicAddManualTrack(
                      id: track.id.value,
                      position: track.position,
                      title: track.title,
                      artist: track.artist ?? '',
                      duration: _editor.trackDurationText(track),
                      isHeader: track.isHeader,
                      indentLevel: track.indentLevel,
                      parentHeaderId: track.parentHeaderId)
              ]),
      ]);
    widget.request.onManualDraftChanged?.call();
  }

  Widget _personalField(MusicDisc disc, String label, String key) {
    final personal = widget.request.kindDraft as MusicAddDraft;
    final details =
        personal.media.where((row) => row.discId == disc.id.value).firstOrNull;
    final value =
        key == 'storage_device' ? details?.storageDevice : details?.storageSlot;
    void save(String? value) {
      final next = MusicEntryDiscDetails(
          discId: disc.id.value,
          storageDevice:
              key == 'storage_device' ? value : details?.storageDevice,
          storageSlot: key == 'storage_slot' ? value : details?.storageSlot);
      widget.request.onKindDraftChanged?.call(personal.copyWith(media: [
        for (final row in personal.media)
          if (row.discId != disc.id.value) row,
        if (!next.isEmpty) next,
      ]));
      if (key == 'storage_device') {
        widget.request.onVocabularyValueChanged?.call(
            fieldId: '${disc.id.value}:$key',
            listName: MusicVocabularies.storageDevice.key,
            value: value);
      }
    }

    return key == 'storage_device'
        ? LibraryManagedVocabularyField(
            label: label,
            listName: MusicVocabularies.storageDevice.key,
            mediaKind: 'music',
            value: value,
            onChanged: save)
        : LibraryFormField(
            label: label,
            child: LibraryTextFormControl(
                key: ValueKey('${disc.id.value}:$key'),
                initialValue: value ?? '',
                onChanged: save));
  }

  @override
  Widget build(BuildContext context) => MusicAlbumStructureTab(
      draft: _editor,
      accent: widget.accent,
      onChanged: _sync,
      discPersonalFieldBuilder: _personalField,
      onDiscRemoved: (id) {
        final personal = widget.request.kindDraft as MusicAddDraft;
        widget.request.onKindDraftChanged?.call(personal.copyWith(media: [
          for (final row in personal.media)
            if (row.discId != id) row
        ]));
      });
}
