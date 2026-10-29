import 'package:collectarr_app/features/library/edit/fields/edit_layout_widgets.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_value_fields.dart';
import 'package:collectarr_app/features/library/edit/sections/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/generic/external_links.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/image_sections.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/host.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

extension ComicImagesTabs on ComicEditHost {
  List<ResolvedComicEditImage> _resolvedEditImages() {
    return resolveComicEditImages(
      images: comicItemImages,
      edits: comicItemImageEdits,
    );
  }

  String _buildComicMarketSearchQuery() {
    return [
      comicCatalogItem.title,
      if (emptyToNull(comicNumberController.text) case final issue?) '#$issue',
      if (emptyToNull(comicPhysicalFormatLabelController.text)
          case final format?)
        format,
      if (emptyToNull(comicVariantController.text) case final variant?) variant,
    ].join(' ').trim();
  }

  Widget buildComicCoverTab() {
    final coverUrl = emptyToNull(comicCoverController.text) ??
        emptyToNull(comicThumbnailController.text) ??
        comicCatalogItem.coverImageUrl;
    final resolvedImages = _resolvedEditImages();
    final backCover = firstResolvedComicEditImageOfType(
      resolvedImages,
      'back_cover',
    );
    final frontAlt = firstResolvedComicEditImageOfType(
      resolvedImages,
      'front_cover',
    );
    final auxiliaryCount =
        resolvedImages.where((image) => image.imageType == 'auxiliary').length;
    return EditTabShell(
      children: [
        EditSection(
          title: 'Covers',
          accent: comicAccent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LibraryEditTextField(
                  controller: comicCoverController, label: 'Front Cover URL'),
              const SizedBox(height: 12),
              ComicCoverPreviewRow(
                coverUrl: coverUrl,
                frontCoverOverride: frontAlt,
                backCover: backCover,
              ),
            ],
          ),
        ),
        EditSection(
          title: 'Cover workflow',
          accent: comicAccent,
          child: ComicCoverWorkflowContent(
            imageCount: resolvedImages.length,
            auxiliaryCount: auxiliaryCount,
            bodyStyle: TextStyle(color: appPalette(comicContext).textMuted),
            onManageImages: () => comicOpenEditTab('photos'),
            onFindBetterCover: () =>
                launchEbaySearch(_buildComicMarketSearchQuery()),
          ),
        ),
      ],
    );
  }

  Widget buildComicPhotosTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: 'My Images Workflow',
          accent: comicAccent,
          child: ComicPhotosWorkflowText(
            style: TextStyle(color: appPalette(comicContext).textMuted),
          ),
        ),
        ItemImagesEditSection(
          images: comicItemImages,
          accent: comicAccent,
          onChanged: (edits) => comicItemImageEdits = edits,
        ),
      ],
    );
  }
}
