import 'dart:convert';

import 'package:collectarr_app/core/logging/recoverable_error.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

/// Gallery / carousel section for item images within an edit dialog.
///
/// Displays existing images, allows adding new ones (base64), editing captions,
/// and deleting images. Returns the full list of mutations via [onChanged].
class ItemImagesEditSection extends StatefulWidget {
  const ItemImagesEditSection({
    super.key,
    required this.images,
    required this.accent,
    required this.onChanged,
  });

  final List<ItemImage> images;
  final Color accent;
  final ValueChanged<List<ItemImageEdit>> onChanged;

  @override
  State<ItemImagesEditSection> createState() => _ItemImagesEditSectionState();
}

/// Represents an add, update, or delete operation on an item image.
class ItemImageEdit {
  const ItemImageEdit({
    required this.id,
    this.imageData,
    this.caption,
    this.imageType = 'auxiliary',
    this.sortOrder = 0,
    this.deleted = false,
  });

  final String id;
  final String? imageData; // base64, null for unchanged/deleted
  final String? caption;
  final String imageType;
  final int sortOrder;
  final bool deleted;
}

class _ItemImagesEditSectionState extends State<ItemImagesEditSection> {
  late List<_EditableImage> _images;

  @override
  void initState() {
    super.initState();
    _images = [
      for (final img in widget.images)
        _EditableImage(
          id: img.id,
          imageData: img.imageData,
          caption: img.caption,
          imageType: img.imageType,
          sortOrder: img.sortOrder,
          isNew: false,
          deleted: false,
        ),
    ];
  }

  void _notifyChanged() {
    widget.onChanged([
      for (final img in _images)
        ItemImageEdit(
          id: img.id,
          imageData: img.isNew ? img.imageData : null,
          caption: img.caption,
          imageType: img.imageType,
          sortOrder: img.sortOrder,
          deleted: img.deleted,
        ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final visible = _images.where((img) => !img.deleted).toList();
    final canAddMore = visible.length < 5;
    return EditSection(
      title: 'Item photos (${visible.length}/5)',
      accent: widget.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (visible.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'No photos attached. Use the button below to add one.',
                style: TextStyle(color: kEditTextMuted, fontSize: 13),
              ),
            )
          else
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: visible.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final img = visible[index];
                  return _ImageCard(
                    image: img,
                    onEditCaption: () => _editImageDetails(img),
                    onDelete: () => _deleteImage(img),
                  );
                },
              ),
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: canAddMore ? _addImageFromFile : null,
                icon: const Icon(Icons.upload_file_outlined),
                label: const Text('Upload image'),
              ),
              OutlinedButton.icon(
                onPressed: canAddMore ? _addImageFromClipboard : null,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Paste base64 image'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _addImageFromFile() async {
    if (_images.where((img) => !img.deleted).length >= 5) {
      return;
    }
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(
          label: 'images',
          extensions: ['png', 'jpg', 'jpeg', 'gif', 'webp'],
        ),
      ],
    );
    if (file == null) {
      return;
    }
    final bytes = await file.readAsBytes();
    _addImage(base64Encode(bytes));
  }

  Future<void> _addImageFromClipboard() async {
    var draftBase64 = '';
    final base64Data = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add image'),
        content: SizedBox(
          width: 400,
          child: TextField(
            maxLines: 4,
            onChanged: (value) => draftBase64 = value,
            decoration: const InputDecoration(
              labelText: 'Base64 image data',
              hintText: 'Paste base64-encoded image here...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(draftBase64.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (base64Data == null || base64Data.isEmpty) return;
    // Validate base64
    try {
      base64Decode(base64Data);
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'item_images',
        message: 'Failed to decode pasted base64 image data in edit dialog.',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid base64 data')),
        );
      }
      return;
    }
    _addImage(base64Data);
  }

  void _addImage(String base64Data) {
    if (_images.where((img) => !img.deleted).length >= 5) {
      return;
    }
    setState(() {
      _images.add(_EditableImage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        imageData: base64Data,
        caption: null,
        imageType: 'auxiliary',
        sortOrder: _images.length,
        isNew: true,
        deleted: false,
      ));
    });
    _notifyChanged();
  }

  Future<void> _editImageDetails(_EditableImage img) async {
    final controller = TextEditingController(text: img.caption ?? '');
    var selectedType = img.imageType;
    final result = await showDialog<({String caption, String imageType})>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit image details'),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Image type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'front_cover',
                    child: Text('Front cover'),
                  ),
                  DropdownMenuItem(
                    value: 'back_cover',
                    child: Text('Back cover'),
                  ),
                  DropdownMenuItem(
                    value: 'auxiliary',
                    child: Text('Auxiliary'),
                  ),
                ],
                onChanged: (value) {
                  selectedType = value ?? 'auxiliary';
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Caption',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop((
              caption: controller.text.trim(),
              imageType: selectedType,
            )),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null) return;
    setState(() {
      img.caption = result.caption.isEmpty ? null : result.caption;
      img.imageType = result.imageType;
    });
    _notifyChanged();
  }

  void _deleteImage(_EditableImage img) {
    setState(() => img.deleted = true);
    _notifyChanged();
  }
}

class _EditableImage {
  _EditableImage({
    required this.id,
    required this.imageData,
    this.caption,
    this.imageType = 'auxiliary',
    this.sortOrder = 0,
    this.isNew = false,
    this.deleted = false,
  });

  final String id;
  final String imageData;
  String? caption;
  String imageType;
  int sortOrder;
  final bool isNew;
  bool deleted;
}

class _ImageCard extends StatelessWidget {
  const _ImageCard({
    required this.image,
    required this.onEditCaption,
    required this.onDelete,
  });

  final _EditableImage image;
  final VoidCallback onEditCaption;
  final VoidCallback onDelete;

  String _labelForType(String value) {
    switch (value) {
      case 'front_cover':
        return 'Front cover';
      case 'back_cover':
        return 'Back cover';
      default:
        return 'Auxiliary';
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget thumbnail;
    try {
      final bytes = base64Decode(image.imageData);
      thumbnail = Image.memory(
        bytes,
        fit: BoxFit.cover,
        width: 120,
        height: 120,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'item_images',
        message: 'Failed to decode item image thumbnail base64 data.',
        error: error,
        stackTrace: stackTrace,
      );
      thumbnail = _placeholder();
    }
    return SizedBox(
      width: 120,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                SizedBox(width: 120, height: 100, child: thumbnail),
                Positioned(
                  top: 2,
                  right: 2,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _MiniAction(
                        icon: Icons.edit,
                        onPressed: onEditCaption,
                      ),
                      const SizedBox(width: 2),
                      _MiniAction(
                        icon: Icons.close,
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (image.caption != null && image.caption!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                image.caption!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: kEditTextMuted),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              _labelForType(image.imageType),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: kEditTextMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 120,
      height: 100,
      color: kEditPanelRaised,
      child: const Icon(Icons.broken_image_outlined, color: kEditTextMuted),
    );
  }
}

class _MiniAction extends StatelessWidget {
  const _MiniAction({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xCC000000),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 14, color: Colors.white),
        ),
      ),
    );
  }
}
