import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/collection/repositories/item_image_repository.dart';
import 'package:collectarr_app/features/collection/repositories/item_images_cache_repository.dart';
import 'package:collectarr_app/features/library/inspector/item_image_picker.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef _InspectorItemImagesRequest = ({
  LocalDatabase db,
  String ownedItemId,
});

final _inspectorItemImagesProvider =
    FutureProvider.autoDispose.family<List<ItemImage>, _InspectorItemImagesRequest>(
  (ref, request) async {
    return ItemImageRepository(request.db).listForItem(request.ownedItemId);
  },
);

class InspectorItemImagesSection extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final request = (db: db, ownedItemId: ownedItemId);
    final imagesAsync = ref.watch(_inspectorItemImagesProvider(request));
    final images = imagesAsync.value ?? const <ItemImage>[];
    final visibleImages = images
      .where(
        (image) =>
          image.imageType != 'front_cover' && image.imageType != 'back_cover',
      )
        .toList(growable: false);

    final groups = <String, List<ItemImage>>{};
    for (final img in visibleImages) {
      (groups[img.imageType] ??= []).add(img);
    }

    final label = visibleImages.isEmpty
        ? 'Images'
        : groups.length == 1
            ? '${itemImageTypeLabels[groups.keys.first] ?? groups.keys.first} (${visibleImages.length})'
            : 'Images (${visibleImages.length})';

    return LibraryDetailSection(
      title: label,
      accentColor: accent,
      children: [
        if (groups.isEmpty)
          Text(
            'No extra owned-item images yet. Add signatures, labels, or other supporting photos here.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: appPalette(context).textMuted,
                ),
          )
        else
          for (final entry in groups.entries) ...[
            if (groups.length > 1) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  itemImageTypeLabels[entry.key] ?? entry.key,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: accent.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                ),
              ),
            ],
            SizedBox(
              height: 106,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: entry.value.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final img = entry.value[index];
                  return _InspectorThumbnail(
                    image: img,
                    onDelete: () => _deleteImage(context, ref, img.id),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
        _AddImageButton(
          accent: accent,
          onPick: () => _pickAndAddImage(context, ref),
        ),
      ],
    );
  }

  Future<void> _pickAndAddImage(BuildContext context, WidgetRef ref) async {
    final savedType = await pickAndStoreOwnedItemImage(
      context: context,
      db: db,
      ownedItemId: ownedItemId,
    );
    if (savedType != null && context.mounted) {
      ref.invalidate(_inspectorItemImagesProvider((db: db, ownedItemId: ownedItemId)));
    }
  }

  Future<void> _deleteImage(
    BuildContext context,
    WidgetRef ref,
    String imageId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AccentAlertDialog(
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
    if (confirmed != true || !context.mounted) return;

    final repo = ItemImagesCacheRepository(db);
    await repo.deleteById(imageId);
    ref.invalidate(_inspectorItemImagesProvider((db: db, ownedItemId: ownedItemId)));
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
    final palette = appPalette(context);
    final dismissBackground = palette.panel.withValues(alpha: 0.84);
    final dismissForeground = ThemeData.estimateBrightnessForColor(dismissBackground) ==
            Brightness.dark
        ? Colors.white
        : Colors.black87;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showFullImage(context),
        onLongPress: onDelete,
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: palette.surfaceSubtle,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: palette.divider),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  image.imageData,
                  width: 84,
                  height: 106,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 84,
                    height: 106,
                    color: kAppSurfaceSubtle,
                    child: Icon(Icons.broken_image, color: palette.textMuted),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 3,
              right: 3,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onDelete,
                  customBorder: const CircleBorder(),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: dismissBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: dismissForeground,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullImage(BuildContext context) {
    final palette = appPalette(context);
    showDialog<void>(
      context: context,
      barrierDismissible: true,
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
                child: Image.memory(
                  image.imageData,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    width: 360,
                    height: 320,
                    color: palette.surface,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Invalid image data for this file.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
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
