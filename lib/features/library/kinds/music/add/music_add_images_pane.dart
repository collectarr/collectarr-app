import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/edit/sections/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album_image.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_images_tabs.dart';
import 'package:flutter/material.dart';

List<MusicAlbumImage> musicAddImages(Iterable<ItemImageContent> images) => [
      for (final image in images)
        MusicAlbumImage(
            id: image.id,
            albumId: 'manual-music',
            purpose: image.imageType == 'front_cover' ||
                    image.imageType == 'back_cover'
                ? MusicAlbumImagePurpose.cover
                : MusicAlbumImagePurpose.personal,
            imageType: image.imageType.startsWith('personal:')
                ? image.imageType.substring(9)
                : image.imageType,
            imageData: image.imageData,
            description: image.caption,
            sortOrder: image.sortOrder,
            createdAt: image.createdAt),
    ];
void updateMusicAddImages(
        LibraryAddManualPaneRequest request, List<MusicAlbumImage> images) =>
    request.onItemImagesChanged?.call([
      for (final image in images)
        ItemImageEdit(
            id: image.id,
            imageData: image.imageData,
            caption: image.description,
            imageType: image.purpose == MusicAlbumImagePurpose.cover
                ? image.imageType
                : 'personal:${image.imageType}',
            sortOrder: image.sortOrder,
            createdAt: image.createdAt),
    ]);

class MusicAddImagesPane extends StatelessWidget {
  const MusicAddImagesPane({super.key, required this.request});
  final LibraryAddManualPaneRequest request;
  @override
  Widget build(BuildContext context) => MusicAlbumMyImagesTab(
      albumId: 'manual-music',
      images: musicAddImages(request.itemImages),
      accent: request.accent,
      onImagesChanged: (images) => updateMusicAddImages(request, images));
}
