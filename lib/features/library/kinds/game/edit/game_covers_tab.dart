import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/library/edit/covers/library_cover_images_tab.dart';
import 'package:collectarr_app/features/library/edit/sections/item_images_edit_section.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:flutter/material.dart';

final class GameCoversTab extends StatelessWidget {
  const GameCoversTab(
      {super.key,
      required this.images,
      required this.coverImageUrl,
      required this.originalCoverImageUrl,
      required this.onCoverImageUrlChanged,
      required this.onEdits});
  final List<ItemImageContent> images;
  final String coverImageUrl;
  final String originalCoverImageUrl;
  final ValueChanged<String> onCoverImageUrlChanged;
  final ValueChanged<List<ItemImageEdit>> onEdits;
  @override
  Widget build(BuildContext context) => LibraryCoverImagesTab(
      images: images,
      coverImageUrl: coverImageUrl,
      originalCoverImageUrl: originalCoverImageUrl,
      onCoverImageUrlChanged: onCoverImageUrlChanged,
      onEdits: onEdits,
      frontLabel: 'Front Cover',
      backLabel: 'Back Cover',
      placeholderIcon: AppIcons.gamepad);
}
