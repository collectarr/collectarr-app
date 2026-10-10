import 'package:collectarr_app/core/logging/recoverable_error.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/forms/library_field_spec.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_dropdown_pick_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_image_intake.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_select_dialog.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

typedef ItemImageTypeFieldBuilder = Widget Function(
  BuildContext context, {
  required String value,
  required ValueChanged<String> onChanged,
});

class ItemImagesEditSection extends StatefulWidget {
  const ItemImagesEditSection({
    super.key,
    required this.images,
    required this.accent,
    required this.onChanged,
    this.helperText =
        'Add your own images (max. 5), set a description and an image type.',
    this.maximumImages = 5,
    this.defaultImageType = 'auxiliary',
    this.uniqueImageTypes = const {'front_cover', 'back_cover'},
    this.imageTypeFieldBuilder,
  });

  final List<ItemImageContent> images;
  final Color accent;
  final ValueChanged<List<ItemImageEdit>> onChanged;
  final String helperText;
  final int maximumImages;
  final String defaultImageType;
  final Set<String> uniqueImageTypes;
  final ItemImageTypeFieldBuilder? imageTypeFieldBuilder;

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
    final canAddMore = visible.length < widget.maximumImages;
    final tiles = <Widget>[];
    for (var index = 0; index < visible.length; index++) {
      final image = visible[index];
      tiles.add(
        DragTarget<_EditableImage>(
          onAcceptWithDetails: (details) => _moveImageTo(details.data, index),
          builder: (context, candidates, _) => _ImageCard(
            image: image,
            accent: widget.accent,
            isDropTarget: candidates.isNotEmpty,
            captionField: _captionField(image),
            imageTypeField: _imageTypeField(
              context,
              value: image.imageType,
              onChanged: (value) {
                setState(() => _assignImageType(image, value));
                _notifyChanged();
              },
            ),
            onRemove: () => _deleteImage(image),
            onEdit: () => _openImageEditor(image),
          ),
        ),
      );
    }
    if (canAddMore) {
      tiles.add(
        LibraryImageIntake(
          remaining: widget.maximumImages - visible.length,
          width: 164,
          height: 300,
          onImages: (bytes) {
            for (final image in bytes) {
              _addImage(image);
            }
          },
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.helperText,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: appPalette(context).textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: tiles,
        ),
      ],
    );
  }

  Widget _captionField(_EditableImage image) => LibraryFormField(
        label: 'Description',
        child: LibraryTextFormControl(
          key: ValueKey<String>('item-image-description-${image.id}'),
          initialValue: image.caption ?? '',
          minimumHeight: 32,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 7, vertical: 5),
          ),
          onChanged: (value) {
            image.caption = value.isEmpty ? null : value;
            _notifyChanged();
          },
        ),
      );

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

  void _addImage(Uint8List imageData) {
    if (_visibleImages().length >= widget.maximumImages) {
      return;
    }
    final createdAt = DateTime.now().toUtc();
    setState(() {
      _images.add(
        _EditableImage(
          id: createdAt.microsecondsSinceEpoch.toString(),
          imageData: imageData,
          createdAt: createdAt,
          imageType: widget.defaultImageType,
          sortOrder: _images.length,
          isNew: true,
          hasBinaryChanges: true,
        ),
      );
    });
    _notifyChanged();
  }

  void _deleteImage(_EditableImage image) {
    setState(() => image.deleted = true);
    _notifyChanged();
  }

  void _assignImageType(_EditableImage image, String imageType) {
    if (widget.uniqueImageTypes.contains(imageType)) {
      for (final other in _images) {
        if (!other.deleted &&
            other.id != image.id &&
            other.imageType == imageType) {
          other.imageType = widget.defaultImageType;
        }
      }
    }
    image.imageType = imageType;
  }

  void _moveImageTo(_EditableImage image, int targetIndex) {
    final visible = _visibleImages().toList(growable: true);
    final currentIndex = visible.indexWhere((entry) => entry.id == image.id);
    if (currentIndex < 0 || targetIndex < 0 || targetIndex >= visible.length) {
      return;
    }
    visible.removeAt(currentIndex);
    visible.insert(targetIndex, image);
    setState(() {
      for (var index = 0; index < visible.length; index++) {
        visible[index].sortOrder = index;
      }
    });
    _notifyChanged();
  }

  Future<void> _openImageEditor(_EditableImage image) async {
    final result = await showDialog<_ImageEditorResult>(
      context: context,
      builder: (context) => _ImageEditorDialog(imageBytes: image.imageData),
    );
    if (result == null || !mounted) return;
    if (result.remove) {
      _deleteImage(image);
      return;
    }
    final bytes = result.imageBytes;
    if (bytes == null) return;
    setState(() {
      image.imageData = bytes;
      image.hasBinaryChanges = true;
    });
    _notifyChanged();
  }

  Widget _imageTypeField(
    BuildContext context, {
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    final customBuilder = widget.imageTypeFieldBuilder;
    if (customBuilder != null) {
      return customBuilder(context, value: value, onChanged: onChanged);
    }
    return LibraryDropdownPickField<String>(
      label: 'Image Type',
      value: value,
      options: const [
        LibraryFieldOption(value: 'front_cover', label: 'Front cover'),
        LibraryFieldOption(value: 'back_cover', label: 'Back cover'),
        LibraryFieldOption(value: 'auxiliary', label: 'Auxiliary'),
        LibraryFieldOption(value: 'booklet', label: 'Booklet'),
        LibraryFieldOption(value: 'disc', label: 'Disc'),
        LibraryFieldOption(value: 'label', label: 'Label'),
        LibraryFieldOption(value: 'other', label: 'Other'),
      ],
      openPicker: (
              {required label, required selectedValue, required options}) =>
          showPickListSelectDialog(
        context: context,
        label: label,
        options: options,
        selectedValue: selectedValue,
      ),
      onChanged: (selected) {
        if (selected != null) onChanged(selected);
      },
    );
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

class _ImageEditorResult {
  const _ImageEditorResult({this.imageBytes, this.remove = false});

  final Uint8List? imageBytes;
  final bool remove;
}

class _ImageEditorDialog extends StatefulWidget {
  const _ImageEditorDialog({required this.imageBytes});

  final Uint8List imageBytes;

  @override
  State<_ImageEditorDialog> createState() => _ImageEditorDialogState();
}

class _ImageEditorDialogState extends State<_ImageEditorDialog> {
  late Uint8List _imageBytes = widget.imageBytes;
  var _busy = false;

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context);
    final previewWidth = (viewport.width - 96).clamp(280.0, 680.0);
    final previewHeight = (viewport.height * 0.42).clamp(180.0, 420.0);
    return AccentAlertDialog(
      title: const Text('Edit image'),
      content: SizedBox(
        width: previewWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 4,
              children: [
                TextButton.icon(
                  onPressed: _busy ? null : _replace,
                  icon: const Icon(Icons.file_upload_outlined),
                  label: const Text('Upload'),
                ),
                TextButton.icon(
                  onPressed: _busy
                      ? null
                      : () => Navigator.of(context).pop(
                            const _ImageEditorResult(remove: true),
                          ),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Remove'),
                ),
                TextButton.icon(
                  onPressed: _busy ? null : () => _rotate(clockwise: true),
                  icon: const Icon(Icons.rotate_right),
                  label: const Text('Rotate'),
                ),
                TextButton.icon(
                  onPressed: _busy ? null : _crop,
                  icon: const Icon(Icons.crop_rotate),
                  label: const Text('Crop / Rotate'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ColoredBox(
              color: appPalette(context).surface,
              child: Image.memory(
                _imageBytes,
                width: previewWidth,
                height: previewHeight,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _busy
              ? null
              : () => Navigator.of(context).pop(
                    _ImageEditorResult(imageBytes: _imageBytes),
                  ),
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Future<void> _replace() async {
    final file = await openFile(acceptedTypeGroups: libraryImageFileTypes);
    if (file == null || !mounted) return;
    await _run(() async {
      final bytes = await file.readAsBytes();
      await validateLibraryImageBytes(bytes);
      return bytes;
    });
  }

  Future<void> _rotate({required bool clockwise}) => _run(() async {
        return Uint8List.fromList(
          await compute(
            _rotateImageBytes,
            _ImageTransformRequest.rotate(
              imageData: _imageBytes,
              clockwise: clockwise,
            ),
          ),
        );
      });

  Future<void> _crop() async {
    try {
      final aspectRatio = await compute(_decodeImageAspectRatio, _imageBytes);
      if (!mounted) return;
      final bounds = await showDialog<_ImageCropBounds>(
        context: context,
        builder: (context) => _ImageCropDialog(
          imageBytes: _imageBytes,
          aspectRatio: aspectRatio,
        ),
      );
      if (bounds == null || !mounted) return;
      await _run(() async {
        return Uint8List.fromList(
          await compute(
            _cropImageBytes,
            _ImageTransformRequest.crop(
              imageData: _imageBytes,
              bounds: bounds,
            ),
          ),
        );
      });
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'item_images',
        message: 'Failed to prepare an item image for cropping.',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(content: Text('Unable to edit that image.')),
        );
      }
    }
  }

  Future<void> _run(Future<Uint8List> Function() operation) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final bytes = await operation();
      if (mounted) setState(() => _imageBytes = bytes);
    } catch (error, stackTrace) {
      logRecoverableError(
        source: 'item_images',
        message: 'Failed to edit an item image.',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(content: Text('Unable to edit that image.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _ImageCard extends StatelessWidget {
  const _ImageCard({
    required this.image,
    required this.accent,
    required this.isDropTarget,
    required this.captionField,
    required this.imageTypeField,
    required this.onRemove,
    required this.onEdit,
  });

  final _EditableImage image;
  final Color accent;
  final bool isDropTarget;
  final Widget captionField;
  final Widget imageTypeField;
  final VoidCallback onRemove;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Container(
      key: ValueKey<String>('item-image-${image.id}'),
      width: 164,
      height: 300,
      decoration: BoxDecoration(
        color: palette.panelRaised,
        border: Border.all(
          color: isDropTarget ? accent : palette.divider,
          width: isDropTarget ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 27,
            color: palette.toolbar,
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: Row(
              children: [
                Tooltip(
                  message: 'Drag to reorder',
                  child: Draggable<_EditableImage>(
                    data: image,
                    feedback: Material(
                      elevation: 6,
                      child: SizedBox(
                        width: 40,
                        height: 32,
                        child: Icon(
                          Icons.drag_indicator,
                          color: palette.textPrimary,
                        ),
                      ),
                    ),
                    child: Icon(
                      Icons.drag_indicator,
                      size: 18,
                      color: palette.textMuted,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Remove image',
                  onPressed: onRemove,
                  icon: const Icon(Icons.close, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 22,
                    height: 22,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Image.memory(
                    image.imageData,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: palette.textMuted,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  child: Tooltip(
                    message: 'Edit image',
                    child: Material(
                      color: const Color(0xCC000000),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onEdit,
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.edit,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                captionField,
                const SizedBox(height: 3),
                imageTypeField,
              ],
            ),
          ),
        ],
      ),
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
    return AccentAlertDialog(
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
