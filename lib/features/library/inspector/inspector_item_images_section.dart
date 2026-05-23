import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/collection/repositories/item_image_repository.dart';
import 'package:collectarr_app/features/collection/repositories/item_images_cache_repository.dart';
import 'package:collectarr_app/features/library/inspector/item_image_picker.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
import 'package:flutter/material.dart';

class InspectorItemImagesSection extends StatefulWidget {
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
  State<InspectorItemImagesSection> createState() =>
      _InspectorItemImagesSectionState();
}

class _InspectorItemImagesSectionState
    extends State<InspectorItemImagesSection> {
  late Future<List<ItemImage>> _imagesFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _imagesFuture =
        ItemImageRepository(widget.db).listForItem(widget.ownedItemId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ItemImage>>(
      future: _imagesFuture,
      builder: (context, snapshot) {
        final images = snapshot.data ?? [];

        // Group by image type.
        final groups = <String, List<ItemImage>>{};
        for (final img in images) {
          (groups[img.imageType] ??= []).add(img);
        }

        final label = images.isEmpty
            ? 'Images'
            : groups.length == 1
            ? '${itemImageTypeLabels[groups.keys.first] ?? groups.keys.first} (${images.length})'
                : 'Images (${images.length})';

        return LibraryInspectorSection(
          title: label,
          accentColor: widget.accent,
          children: [
            for (final entry in groups.entries) ...[
              if (groups.length > 1) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    itemImageTypeLabels[entry.key] ?? entry.key,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: widget.accent.withValues(alpha: 0.8),
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
                    return _InspectorThumbnail(
                      image: img,
                      onDelete: () => _deleteImage(img.id),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
            _AddImageButton(
              accent: widget.accent,
              onPick: _pickAndAddImage,
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickAndAddImage() async {
    final savedType = await pickAndStoreOwnedItemImage(
      context: context,
      db: widget.db,
      ownedItemId: widget.ownedItemId,
    );
    if (savedType != null && mounted) {
      setState(_reload);
    }
  }

  Future<void> _deleteImage(String imageId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete image?'),
        content: const Text('This image will be removed from your collection.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final repo = ItemImagesCacheRepository(widget.db);
    await repo.deleteById(imageId);
    if (mounted) setState(_reload);
  }
}

class _AddImageButton extends StatelessWidget {
  const _AddImageButton({required this.accent, required this.onPick});

  final Color accent;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPick,
        icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
        label: const Text('Add image'),
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: BorderSide(color: accent.withValues(alpha: 0.3)),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }
}

class _InspectorThumbnail extends StatelessWidget {
  const _InspectorThumbnail({
    required this.image,
    required this.onDelete,
  });

  final ItemImage image;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final bytes = base64Decode(image.imageData);
    return GestureDetector(
      onTap: () => _showFullImage(context),
      onLongPress: onDelete,
      child: Stack(
        children: [
          ClipRRect(
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
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
        ],
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
