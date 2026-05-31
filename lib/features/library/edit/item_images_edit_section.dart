import 'dart:convert';

import 'package:collectarr_app/core/logging/recoverable_error.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

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

class ItemImageEdit {
  const ItemImageEdit({
    required this.id,
    this.imageData,
    this.caption,
    this.imageType = 'auxiliary',
    this.sortOrder = 0,
    this.createdAt,
    this.deleted = false,
  });

  final String id;
  final Uint8List? imageData;
  final String? caption;
  final String imageType;
  final int sortOrder;
  final DateTime? createdAt;
  final bool deleted;
}

class _ItemImagesEditSectionState extends State<ItemImagesEditSection> {
  late List<_EditableImage> _images;

  @override
  void initState() {
    super.initState();
    _images = [
      for (final image in widget.images)
        _EditableImage(
          id: image.id,
          imageData: image.imageData,
          createdAt: image.createdAt,
          caption: image.caption,
          imageType: image.imageType,
          sortOrder: image.sortOrder,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleImages();
    final deleted =
        _images.where((image) => image.deleted).toList(growable: false);
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
                'No photos attached. Use the tools below to add a front cover, back cover, or supporting shots.',
                style: const TextStyle(color: kEditTextMuted, fontSize: 13),
              ),
            )
          else
            SizedBox(
              height: 156,
              child: ReorderableListView.builder(
                buildDefaultDragHandles: false,
                scrollDirection: Axis.horizontal,
                itemCount: visible.length,
                onReorderItem: _reorderImages,
                itemBuilder: (context, index) {
                  final image = visible[index];
                  return Padding(
                    key: ValueKey('item-image-${image.id}'),
                    padding: EdgeInsets.only(
                        right: index == visible.length - 1 ? 0 : 8),
                    child: _ImageCard(
                      image: image,
                      reorderIndex: index,
                      canMoveLeft: index > 0,
                      canMoveRight: index < visible.length - 1,
                      onAction: (action) => _handleImageAction(image, action),
                    ),
                  );
                },
              ),
            ),
          if (deleted.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Removed photos',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final image in deleted)
                  OutlinedButton.icon(
                    onPressed: () => _restoreImage(image),
                    icon: const Icon(Icons.restore_outlined),
                    label: Text(_labelForType(image.imageType)),
                  ),
              ],
            ),
          ],
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

  List<_EditableImage> _visibleImages() {
    final visible =
        _images.where((image) => !image.deleted).toList(growable: false);
    visible.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return visible;
  }

  void _normalizeVisibleSortOrder() {
    final visible = _visibleImages();
    for (var index = 0; index < visible.length; index++) {
      visible[index].sortOrder = index;
    }
  }

  void _notifyChanged() {
    _normalizeVisibleSortOrder();
    widget.onChanged([
      for (final image in _images)
        ItemImageEdit(
          id: image.id,
          imageData:
              image.isNew || image.hasBinaryChanges ? image.imageData : null,
          caption: image.caption,
          imageType: image.imageType,
          sortOrder: image.sortOrder,
          createdAt: image.createdAt,
          deleted: image.deleted,
        ),
    ]);
  }

  Future<void> _addImageFromFile() async {
    if (_visibleImages().length >= 5) {
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
    _addImage(bytes);
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
    if (base64Data == null || base64Data.isEmpty) {
      return;
    }
    Uint8List bytes;
    try {
      var normalizedData = base64Data.trim();
      if (normalizedData.contains(',')) {
        normalizedData = normalizedData.split(',').last;
      }
      bytes = base64Decode(normalizedData);
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
    _addImage(bytes);
  }

  void _addImage(Uint8List imageData) {
    if (_visibleImages().length >= 5) {
      return;
    }
    final createdAt = DateTime.now().toUtc();
    setState(() {
      _images.add(
        _EditableImage(
          id: createdAt.microsecondsSinceEpoch.toString(),
          imageData: imageData,
          createdAt: createdAt,
          imageType: 'auxiliary',
          sortOrder: _images.length,
          isNew: true,
          hasBinaryChanges: true,
        ),
      );
    });
    _notifyChanged();
  }

  Future<void> _editImageDetails(_EditableImage image) async {
    final controller = TextEditingController(text: image.caption ?? '');
    var selectedType = image.imageType;
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
    if (result == null) {
      return;
    }
    setState(() {
      image.caption = result.caption.isEmpty ? null : result.caption;
      _assignImageType(image, result.imageType);
    });
    _notifyChanged();
  }

  void _restoreImage(_EditableImage image) {
    setState(() {
      image.deleted = false;
      image.sortOrder = _visibleImages().length;
    });
    _notifyChanged();
  }

  void _deleteImage(_EditableImage image) {
    setState(() => image.deleted = true);
    _notifyChanged();
  }

  void _assignImageType(_EditableImage image, String imageType) {
    if (imageType == 'front_cover' || imageType == 'back_cover') {
      for (final other in _images) {
        if (!other.deleted &&
            other.id != image.id &&
            other.imageType == imageType) {
          other.imageType = 'auxiliary';
        }
      }
    }
    image.imageType = imageType;
  }

  Future<void> _rotateImage(
    _EditableImage image, {
    required bool clockwise,
  }) async {
    try {
      final rotatedBytes = await compute(
        _rotateImageBytes,
        _ImageTransformRequest.rotate(
          imageData: image.imageData,
          clockwise: clockwise,
        ),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        image.imageData = rotatedBytes;
        image.hasBinaryChanges = true;
      });
      _notifyChanged();
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'item_images',
        message: 'Failed to rotate item image in edit dialog.',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to rotate that image.')),
        );
      }
    }
  }

  void _moveImage(_EditableImage image, int direction) {
    final visible = _visibleImages();
    final currentIndex = visible.indexWhere((entry) => entry.id == image.id);
    if (currentIndex < 0) {
      return;
    }
    final targetIndex = currentIndex + direction;
    if (targetIndex < 0 || targetIndex >= visible.length) {
      return;
    }
    final other = visible[targetIndex];
    final previousOrder = image.sortOrder;
    setState(() {
      image.sortOrder = other.sortOrder;
      other.sortOrder = previousOrder;
    });
    _notifyChanged();
  }

  void _reorderImages(int oldIndex, int newIndex) {
    final visible = _visibleImages().toList(growable: true);
    if (oldIndex < 0 || oldIndex >= visible.length) {
      return;
    }
    if (newIndex < 0 || newIndex > visible.length) {
      return;
    }
    var targetIndex = newIndex;
    if (oldIndex < targetIndex) {
      targetIndex -= 1;
    }
    final moved = visible.removeAt(oldIndex);
    visible.insert(targetIndex, moved);
    setState(() {
      for (var index = 0; index < visible.length; index++) {
        visible[index].sortOrder = index;
      }
    });
    _notifyChanged();
  }

  Future<void> _cropImage(_EditableImage image) async {
    try {
      final aspectRatio = await compute(_decodeImageAspectRatio, image.imageData);
      if (!mounted) {
        return;
      }
      final bounds = await showDialog<_ImageCropBounds>(
        context: context,
        builder: (context) => _ImageCropDialog(
          imageBytes: image.imageData,
          aspectRatio: aspectRatio,
        ),
      );
      if (bounds == null) {
        return;
      }
      final croppedBytes = await compute(
        _cropImageBytes,
        _ImageTransformRequest.crop(
          imageData: image.imageData,
          bounds: bounds,
        ),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        image.imageData = croppedBytes;
        image.hasBinaryChanges = true;
      });
      _notifyChanged();
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'item_images',
        message: 'Failed to crop item image in edit dialog.',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to crop that image.')),
        );
      }
    }
  }

  void _handleImageAction(_EditableImage image, _ImageCardAction action) {
    switch (action) {
      case _ImageCardAction.editDetails:
        _editImageDetails(image);
      case _ImageCardAction.assignFront:
        setState(() => _assignImageType(image, 'front_cover'));
        _notifyChanged();
      case _ImageCardAction.assignBack:
        setState(() => _assignImageType(image, 'back_cover'));
        _notifyChanged();
      case _ImageCardAction.assignAuxiliary:
        setState(() => _assignImageType(image, 'auxiliary'));
        _notifyChanged();
      case _ImageCardAction.rotateLeft:
        _rotateImage(image, clockwise: false);
      case _ImageCardAction.rotateRight:
        _rotateImage(image, clockwise: true);
      case _ImageCardAction.crop:
        _cropImage(image);
      case _ImageCardAction.moveLeft:
        _moveImage(image, -1);
      case _ImageCardAction.moveRight:
        _moveImage(image, 1);
      case _ImageCardAction.delete:
        _deleteImage(image);
    }
  }

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
}

Uint8List _rotateImageBytes(_ImageTransformRequest request) {
  final decoded = _decodeEditableImage(request.imageData);
  final clockwise = request.clockwise!;
  final rotated = img.copyRotate(
    decoded,
    angle: clockwise ? 90 : -90,
  );
  return Uint8List.fromList(img.encodePng(rotated));
}

double _decodeImageAspectRatio(Uint8List imageData) {
  final decoded = _decodeEditableImage(imageData);
  return decoded.width / decoded.height;
}

Uint8List _cropImageBytes(_ImageTransformRequest request) {
  final decoded = _decodeEditableImage(request.imageData);
  final cropped = _applyCropBounds(decoded, request.bounds!);
  return Uint8List.fromList(img.encodePng(cropped));
}

img.Image _decodeEditableImage(Uint8List imageData) {
  final decoded = img.decodeImage(imageData);
  if (decoded == null) {
    throw StateError('Image decode returned null.');
  }
  return decoded;
}

img.Image _applyCropBounds(img.Image source, _ImageCropBounds bounds) {
  final x = (source.width * bounds.left).round().clamp(0, source.width - 1);
  final y = (source.height * bounds.top).round().clamp(0, source.height - 1);
  final width =
      (source.width * bounds.width).round().clamp(1, source.width - x);
  final height =
      (source.height * bounds.height).round().clamp(1, source.height - y);
  return img.copyCrop(source, x: x, y: y, width: width, height: height);
}

class _ImageTransformRequest {
  const _ImageTransformRequest._({
    required this.imageData,
    this.clockwise,
    this.bounds,
  });

  const _ImageTransformRequest.rotate({
    required Uint8List imageData,
    required bool clockwise,
  }) : this._(imageData: imageData, clockwise: clockwise);

  const _ImageTransformRequest.crop({
    required Uint8List imageData,
    required _ImageCropBounds bounds,
  }) : this._(imageData: imageData, bounds: bounds);

  final Uint8List imageData;
  final bool? clockwise;
  final _ImageCropBounds? bounds;
}

class _EditableImage {
  _EditableImage({
    required this.id,
    required this.imageData,
    required this.createdAt,
    this.caption,
    this.imageType = 'auxiliary',
    this.sortOrder = 0,
    this.isNew = false,
    this.hasBinaryChanges = false,
  });

  final String id;
  Uint8List imageData;
  final DateTime createdAt;
  String? caption;
  String imageType;
  int sortOrder;
  final bool isNew;
  bool hasBinaryChanges;
  bool deleted = false;
}

enum _ImageCardAction {
  editDetails,
  assignFront,
  assignBack,
  assignAuxiliary,
  rotateLeft,
  rotateRight,
  crop,
  moveLeft,
  moveRight,
  delete,
}

class _ImageCropBounds {
  const _ImageCropBounds({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  const _ImageCropBounds.fullFrame()
      : left = 0,
        top = 0,
        right = 1,
        bottom = 1;

  final double left;
  final double top;
  final double right;
  final double bottom;

  double get width => right - left;
  double get height => bottom - top;

  bool get isFullFrame => left == 0 && top == 0 && right == 1 && bottom == 1;

  _ImageCropBounds copyWith({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return _ImageCropBounds(
      left: left ?? this.left,
      top: top ?? this.top,
      right: right ?? this.right,
      bottom: bottom ?? this.bottom,
    );
  }
}

class _ImageCard extends StatelessWidget {
  const _ImageCard({
    required this.image,
    required this.reorderIndex,
    required this.canMoveLeft,
    required this.canMoveRight,
    required this.onAction,
  });

  final _EditableImage image;
  final int reorderIndex;
  final bool canMoveLeft;
  final bool canMoveRight;
  final ValueChanged<_ImageCardAction> onAction;

  @override
  Widget build(BuildContext context) {
    final thumbnail = Image.memory(
      image.imageData,
      fit: BoxFit.cover,
      width: 120,
      height: 120,
      errorBuilder: (_, __, ___) => _placeholder(),
    );

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
                  child: PopupMenuButton<_ImageCardAction>(
                    tooltip: 'Image actions',
                    onSelected: onAction,
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: _ImageCardAction.editDetails,
                        child: Text('Edit details'),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: _ImageCardAction.assignFront,
                        child: Text('Use as front cover'),
                      ),
                      const PopupMenuItem(
                        value: _ImageCardAction.assignBack,
                        child: Text('Use as back cover'),
                      ),
                      const PopupMenuItem(
                        value: _ImageCardAction.assignAuxiliary,
                        child: Text('Use as auxiliary'),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: _ImageCardAction.rotateLeft,
                        child: Text('Rotate left'),
                      ),
                      const PopupMenuItem(
                        value: _ImageCardAction.rotateRight,
                        child: Text('Rotate right'),
                      ),
                      const PopupMenuItem(
                        value: _ImageCardAction.crop,
                        child: Text('Crop'),
                      ),
                      if (canMoveLeft)
                        const PopupMenuItem(
                          value: _ImageCardAction.moveLeft,
                          child: Text('Move earlier'),
                        ),
                      if (canMoveRight)
                        const PopupMenuItem(
                          value: _ImageCardAction.moveRight,
                          child: Text('Move later'),
                        ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: _ImageCardAction.delete,
                        child: Text('Remove'),
                      ),
                    ],
                    child: const _MiniAction(icon: Icons.more_vert),
                  ),
                ),
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Tooltip(
                    message: 'Drag to reorder',
                    child: ReorderableDragStartListener(
                      index: reorderIndex,
                      child: const _MiniAction(icon: Icons.drag_indicator),
                    ),
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
              _typeLabel(image.imageType),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: kEditTextMuted),
            ),
          ),
        ],
      ),
    );
  }

  String _typeLabel(String value) {
    switch (value) {
      case 'front_cover':
        return 'Front cover';
      case 'back_cover':
        return 'Back cover';
      default:
        return 'Auxiliary';
    }
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

class _ImageCropDialog extends StatefulWidget {
  const _ImageCropDialog({
    required this.imageBytes,
    required this.aspectRatio,
  });

  final Uint8List imageBytes;
  final double aspectRatio;

  @override
  State<_ImageCropDialog> createState() => _ImageCropDialogState();
}

class _ImageCropDialogState extends State<_ImageCropDialog> {
  static const double _cropStep = 0.05;
  static const double _minCropSpan = 0.35;

  _ImageCropBounds _bounds = const _ImageCropBounds.fullFrame();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Crop image'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trim away borders or extra framing before saving the local image.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: kEditTextMuted,
                  ),
            ),
            const SizedBox(height: 12),
            _CropPreview(
              imageBytes: widget.imageBytes,
              aspectRatio: widget.aspectRatio,
              bounds: _bounds,
            ),
            const SizedBox(height: 12),
            Text(
              'Crop: ${(_bounds.width * 100).round()}% width x ${(_bounds.height * 100).round()}% height',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: kEditTextMuted,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _trim(left: _cropStep),
                  icon: const Icon(Icons.keyboard_double_arrow_right),
                  label: const Text('Trim left'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _trim(right: -_cropStep),
                  icon: const Icon(Icons.keyboard_double_arrow_left),
                  label: const Text('Trim right'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _trim(top: _cropStep),
                  icon: const Icon(Icons.keyboard_double_arrow_down),
                  label: const Text('Trim top'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _trim(bottom: -_cropStep),
                  icon: const Icon(Icons.keyboard_double_arrow_up),
                  label: const Text('Trim bottom'),
                ),
                TextButton.icon(
                  onPressed: _bounds.isFullFrame
                      ? null
                      : () => setState(
                            () => _bounds = const _ImageCropBounds.fullFrame(),
                          ),
                  icon: const Icon(Icons.crop_free),
                  label: const Text('Reset crop'),
                ),
              ],
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
          onPressed: () => Navigator.of(context).pop(_bounds),
          child: const Text('Apply crop'),
        ),
      ],
    );
  }

  void _trim({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    final nextLeft =
        (_bounds.left + left).clamp(0.0, _bounds.right - _minCropSpan);
    final nextTop =
        (_bounds.top + top).clamp(0.0, _bounds.bottom - _minCropSpan);
    final nextRight =
        (_bounds.right + right).clamp(nextLeft + _minCropSpan, 1.0);
    final nextBottom =
        (_bounds.bottom + bottom).clamp(nextTop + _minCropSpan, 1.0);
    setState(() {
      _bounds = _ImageCropBounds(
        left: nextLeft,
        top: nextTop,
        right: nextRight,
        bottom: nextBottom,
      );
    });
  }
}

class _CropPreview extends StatelessWidget {
  const _CropPreview({
    required this.imageBytes,
    required this.aspectRatio,
    required this.bounds,
  });

  final Uint8List imageBytes;
  final double aspectRatio;
  final _ImageCropBounds bounds;

  @override
  Widget build(BuildContext context) {
    final previewAspectRatio = aspectRatio <= 0 ? 1.0 : aspectRatio;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: previewAspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.memory(imageBytes, fit: BoxFit.cover),
            Container(color: const Color(0x66000000)),
            Align(
              alignment: Alignment(
                (bounds.left + bounds.right) - 1,
                (bounds.top + bounds.bottom) - 1,
              ),
              child: FractionallySizedBox(
                widthFactor: bounds.width,
                heightFactor: bounds.height,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment(
                        ((bounds.left + bounds.right) - 1) / bounds.width,
                        ((bounds.top + bounds.bottom) - 1) / bounds.height,
                      ),
                      widthFactor: 1 / bounds.width,
                      heightFactor: 1 / bounds.height,
                      child: Image.memory(imageBytes, fit: BoxFit.cover),
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
}

class _MiniAction extends StatelessWidget {
  const _MiniAction({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xCC000000),
      shape: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 14, color: Colors.white),
      ),
    );
  }
}
