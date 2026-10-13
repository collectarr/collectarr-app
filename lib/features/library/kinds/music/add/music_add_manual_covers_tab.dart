import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_images_pane.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album_image.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_images_tabs.dart';
import 'package:flutter/material.dart';

/// Both modes use the same upload, remove/restore, and crop/rotate cover controls.
class MusicAddManualCoversTab extends StatefulWidget {
  const MusicAddManualCoversTab(
      {super.key, required this.draft, required this.request});
  final MusicAddManualDraft draft;
  final LibraryAddManualPaneRequest request;
  @override
  State<MusicAddManualCoversTab> createState() =>
      _MusicAddManualCoversTabState();
}

class _MusicAddManualCoversTabState extends State<MusicAddManualCoversTab> {
  late final String _originalFront = widget.draft.coverImageUrl;
  late final String _originalBack = widget.draft.backCoverImageUrl;
  @override
  Widget build(BuildContext context) {
    final images = musicAddImages(widget.request.itemImages);
    Widget cover(bool back) {
      final type = back ? 'back_cover' : 'front_cover';
      return MusicCoverEditor(
          title: back ? 'Back Cover' : 'Front Cover',
          albumId: 'manual-music',
          searchArtist: widget.draft.artist,
          searchTitle: widget.draft.catalogTitle,
          searchBarcode: widget.draft.barcode,
          image: images
              .where((image) =>
                  image.purpose == MusicAlbumImagePurpose.cover &&
                  image.imageType == type)
              .firstOrNull,
          coreCoverUrl: back
              ? widget.draft.backCoverImageUrl
              : widget.draft.coverImageUrl,
          restoreCoreCoverUrl: back ? _originalBack : _originalFront,
          onRestoreCoreCover: () => setState(() {
                if (back) {
                  widget.draft.backCoverImageUrl = _originalBack;
                } else {
                  widget.draft.coverImageUrl = _originalFront;
                }
              }),
          onRemoveCoreCover: () => setState(() {
                if (back) {
                  widget.draft.backCoverImageUrl = '';
                } else {
                  widget.draft.coverImageUrl = '';
                }
              }),
          onChanged: (image) => updateMusicAddImages(widget.request, [
                ...images.where((image) =>
                    image.purpose != MusicAlbumImagePurpose.cover ||
                    image.imageType != type),
                if (image != null) image,
              ]));
    }

    return LayoutBuilder(
        builder: (context, constraints) => constraints.maxWidth >= 680
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: cover(false)),
                const SizedBox(width: 12),
                Expanded(child: cover(true))
              ])
            : Column(children: [
                cover(false),
                const SizedBox(height: 12),
                cover(true)
              ]));
  }
}
