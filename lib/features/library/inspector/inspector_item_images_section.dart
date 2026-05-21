import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/collection/repositories/item_image_repository.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
import 'package:flutter/material.dart';

class InspectorItemImagesSection extends StatelessWidget {
  const InspectorItemImagesSection({
    super.key,
    required this.ownedItemId,
    required this.db,
    required this.accent,
  });

  final String ownedItemId;
  final LocalDatabase db;
  final Color accent;

  static const _typeLabels = {
    'front_cover': 'Front Cover',
    'back_cover': 'Back Cover',
    'auxiliary': 'Photos',
  };

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ItemImage>>(
      future: ItemImageRepository(db).listForItem(ownedItemId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final images = snapshot.data!;
        if (images.isEmpty) return const SizedBox.shrink();

        // Group by image type.
        final groups = <String, List<ItemImage>>{};
        for (final img in images) {
          (groups[img.imageType] ??= []).add(img);
        }

        final label = groups.length == 1
            ? '${_typeLabels[groups.keys.first] ?? groups.keys.first} (${images.length})'
            : 'Images (${images.length})';

        return LibraryInspectorSection(
          title: label,
          accentColor: accent,
          children: [
            for (final entry in groups.entries) ...[
              if (groups.length > 1) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    _typeLabels[entry.key] ?? entry.key,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: accent.withValues(alpha: 0.8),
                        ),
                  ),
                ),
              ],
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: entry.value.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    final img = entry.value[index];
                    return _InspectorThumbnail(image: img);
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
        );
      },
    );
  }
}

class _InspectorThumbnail extends StatelessWidget {
  const _InspectorThumbnail({required this.image});

  final ItemImage image;

  @override
  Widget build(BuildContext context) {
    final bytes = base64Decode(image.imageData);
    return GestureDetector(
      onTap: () => _showFullImage(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.memory(
          bytes,
          width: 80,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 80,
            height: 100,
            color: const Color(0xFF2A2A2A),
            child: const Icon(Icons.broken_image, color: Colors.white38),
          ),
        ),
      ),
    );
  }

  void _showFullImage(BuildContext context) {
    final bytes = base64Decode(image.imageData);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 600,
                  maxHeight: 500,
                ),
                child: Image.memory(bytes, fit: BoxFit.contain),
              ),
            ),
            if (image.caption != null && image.caption!.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  image.caption!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
