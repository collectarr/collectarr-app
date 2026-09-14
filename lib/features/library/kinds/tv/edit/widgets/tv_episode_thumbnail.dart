import 'dart:io';

import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class TvEpisodeThumbnail extends StatelessWidget {
  const TvEpisodeThumbnail({
    super.key,
    this.imageUrl,
    this.fallbackImageUrl,
    this.localImagePath,
    this.thumbnailImageUrl,
    this.width = 52,
    this.height = 78,
  });

  final String? imageUrl;
  final String? fallbackImageUrl;
  final String? localImagePath;
  final String? thumbnailImageUrl;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final resolvedImage = imageUrl ?? thumbnailImageUrl ?? fallbackImageUrl;
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: resolvedImage == null
            ? ColoredBox(
                color: appPalette(context).surface,
                child: const Icon(Icons.image_outlined),
              )
            : localImagePath != null && localImagePath!.trim().isNotEmpty
                ? Image.file(
                    File(localImagePath!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.network(
                      resolvedImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const ColoredBox(
                        color: Colors.transparent,
                        child: Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  )
                : Image.network(
                    resolvedImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const ColoredBox(
                      color: Colors.transparent,
                      child: Icon(Icons.broken_image_outlined),
                    ),
                  ),
      ),
    );
  }
}
