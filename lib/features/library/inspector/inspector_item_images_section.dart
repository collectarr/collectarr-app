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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ItemImage>>(
      future: ItemImageRepository(db).listForItem(ownedItemId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final images = snapshot.data!;
        if (images.isEmpty) return const SizedBox.shrink();
        return LibraryInspectorSection(
          title: 'Photos (${images.length})',
          accentColor: accent,
          children: [
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  final img = images[index];
                  return _InspectorThumbnail(image: img);
                },
              ),
            ),
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
