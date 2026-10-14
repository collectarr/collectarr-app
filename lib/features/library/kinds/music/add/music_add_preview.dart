import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_preview_pane.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_catalog_candidate_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track_list_entry.dart';
import 'package:collectarr_app/features/library/kinds/music/inspector/music_inspector_track_list.dart';
import 'package:flutter/material.dart';

Widget buildMusicAddPreview(
    BuildContext context, LibraryAddPreviewPaneRequest request) {
  final item = request.item;
  final album = item == null ? null : musicCatalogItemFromCandidate(item);
  return LibraryAddPreviewPane(
    type: request.type,
    accent: request.accent,
    isWideLayout: true,
    previewPaneBuilder: null,
    item: item,
    isFetchingPreview: request.isFetchingPreview,
    searched: request.searched,
    coverAspectRatio: 1,
    additionalDetails: album == null
        ? null
        : MusicInspectorTrackList(
            accent: request.accent,
            tracks: [
              for (final disc in album.discs)
                for (final track in disc.tracks)
                  MusicTrackListEntry(
                      discNumber: disc.discNumber, track: track),
            ],
          ),
  );
}
