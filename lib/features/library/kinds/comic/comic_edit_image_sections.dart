import 'dart:typed_data';

import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/library/edit/item_images_edit_section.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ResolvedComicEditImage {
  const ResolvedComicEditImage({
    required this.id,
    required this.imageData,
    required this.imageType,
    required this.caption,
    required this.sortOrder,
  });

  final String id;
  final Uint8List imageData;
  final String imageType;
  final String? caption;
  final int sortOrder;
}

List<ResolvedComicEditImage> resolveComicEditImages({
  required List<ItemImage> images,
  required List<ItemImageEdit> edits,
}) {
  final existing = {
    for (final image in images) image.id: image,
  };
  final editsById = {
    for (final edit in edits) edit.id: edit,
  };
  final resolved = <ResolvedComicEditImage>[];

  for (final image in images) {
    final edit = editsById[image.id];
    if (edit?.deleted == true) {
      continue;
    }
    resolved.add(
      ResolvedComicEditImage(
        id: image.id,
        imageData: edit?.imageData ?? image.imageData,
        imageType: edit?.imageType ?? image.imageType,
        caption: edit?.caption ?? image.caption,
        sortOrder: edit?.sortOrder ?? image.sortOrder,
      ),
    );
  }

  for (final edit in edits) {
    if (existing.containsKey(edit.id) || edit.deleted || edit.imageData == null) {
      continue;
    }
    resolved.add(
      ResolvedComicEditImage(
        id: edit.id,
        imageData: edit.imageData!,
        imageType: edit.imageType,
        caption: edit.caption,
        sortOrder: edit.sortOrder,
      ),
    );
  }

  resolved.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  return resolved;
}

ResolvedComicEditImage? firstResolvedComicEditImageOfType(
  List<ResolvedComicEditImage> images,
  String type,
) {
  for (final image in images) {
    if (image.imageType == type) {
      return image;
    }
  }
  return null;
}

class ComicCoverPreviewRow extends StatelessWidget {
  const ComicCoverPreviewRow({
    super.key,
    required this.coverUrl,
    required this.frontCoverOverride,
    required this.backCover,
    this.titleStyle,
    this.backgroundColor,
    this.borderColor,
  });

  final String? coverUrl;
  final ResolvedComicEditImage? frontCoverOverride;
  final ResolvedComicEditImage? backCover;
  final TextStyle? titleStyle;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ComicImagePreviewCard(
          title: 'Front Cover',
          networkUrl: coverUrl,
          imageData: frontCoverOverride?.imageData,
          emptyLabel: 'No front cover',
          titleStyle: titleStyle,
          backgroundColor: backgroundColor,
          borderColor: borderColor,
        ),
        const SizedBox(width: 12),
        _ComicImagePreviewCard(
          title: 'Back Cover',
          imageData: backCover?.imageData,
          emptyLabel: 'No back cover',
          titleStyle: titleStyle,
          backgroundColor: backgroundColor,
          borderColor: borderColor,
        ),
      ],
    );
  }
}

class ComicCoverWorkflowContent extends StatelessWidget {
  const ComicCoverWorkflowContent({
    super.key,
    required this.imageCount,
    required this.auxiliaryCount,
    required this.onManageImages,
    required this.onFindBetterCover,
    this.bodyStyle,
    this.statsStyle,
  });

  final int imageCount;
  final int auxiliaryCount;
  final VoidCallback onManageImages;
  final VoidCallback onFindBetterCover;
  final TextStyle? bodyStyle;
  final TextStyle? statsStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Use the metadata cover for the main front cover. Use My Images for front overrides, back covers, slab shots, signatures, and detail photos.',
          style: bodyStyle,
        ),
        const SizedBox(height: 8),
        Text(
          'Attached personal images: $imageCount total, $auxiliaryCount auxiliary.',
          style: statsStyle,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: onManageImages,
              icon: const Icon(Icons.collections_outlined),
              label: const Text('Manage My Images'),
            ),
            FilledButton.icon(
              onPressed: onFindBetterCover,
              icon: const Icon(Icons.search),
              label: const Text('Find Better Cover'),
            ),
          ],
        ),
      ],
    );
  }
}

class ComicPhotosWorkflowText extends StatelessWidget {
  const ComicPhotosWorkflowText({super.key, this.style});

  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Add your own images, set a caption, and choose the image type for signatures, slab shots, and detail photos.',
      style: style,
    );
  }
}

class _ComicImagePreviewCard extends StatelessWidget {
  const _ComicImagePreviewCard({
    required this.title,
    this.networkUrl,
    this.imageData,
    required this.emptyLabel,
    this.titleStyle,
    this.backgroundColor,
    this.borderColor,
  });

  final String title;
  final String? networkUrl;
  final Uint8List? imageData;
  final String emptyLabel;
  final TextStyle? titleStyle;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    Widget child;
    if (imageData != null && imageData!.isNotEmpty) {
      child = Image.memory(
        imageData!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Center(child: Text(emptyLabel)),
      );
    } else if (networkUrl != null && networkUrl!.isNotEmpty) {
      child = Image.network(
        networkUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Center(child: Text(emptyLabel)),
      );
    } else {
      child = Center(child: Text(emptyLabel));
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: titleStyle ??
                Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: backgroundColor ?? palette.gridCanvas,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor ?? palette.divider),
            ),
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
        ],
      ),
    );
  }
}