import 'dart:math' as math;

import 'package:collectarr_app/features/library/edit/covers/panel_frame.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

/// Interactive crop and quarter-turn editor of the cover panels. As in the
/// reference it takes over the panel in place: a blue toolbar over the cover at
/// the panel's width, with Reset leaving without any change.
final class LibraryCoverCropEditor extends StatefulWidget {
  const LibraryCoverCropEditor({
    super.key,
    required this.title,
    required this.imageBytes,
    required this.onApply,
    required this.onReset,
  });

  final String title;
  final Uint8List imageBytes;
  final Future<void> Function(Uint8List bytes) onApply;
  final VoidCallback onReset;

  @override
  State<LibraryCoverCropEditor> createState() => _LibraryCoverCropEditorState();
}

final class _LibraryCoverCropEditorState extends State<LibraryCoverCropEditor> {
  static const double _minimumCropSize = 0.08;
  static const Color _toolbarHover = Color(0xff349cd5);
  static const Color _cropColor = Color(0xff3399ff);

  late Uint8List _workingBytes;
  late img.Image _decodedImage;
  late final double _originalRatio;
  _CropBounds _bounds = const _CropBounds.fullFrame();
  bool _rotating = false;
  bool _applying = false;

  @override
  void initState() {
    super.initState();
    _workingBytes = widget.imageBytes;
    _decodedImage = _decode(_workingBytes);
    _originalRatio = _decodedImage.width / _decodedImage.height;
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final busy = _rotating || _applying;
    Widget button(IconData icon, String label, VoidCallback onPressed) =>
        LibraryCoverToolbarButton(
          icon: icon,
          label: label,
          foregroundColor: Colors.white,
          hoverColor: _toolbarHover,
          onPressed: busy ? null : onPressed,
        );

    return LibraryCoverPanelFrame(
      title: widget.title,
      toolbarColor: palette.utilityAction,
      // The preview keeps the inset itself: handles straddle the cover's edge
      // and only take the pointer within their parent's bounds.
      padding: EdgeInsets.zero,
      toolbar: Row(
        children: [
          button(AppIcons.close, 'Reset', widget.onReset),
          const Spacer(),
          button(AppIcons.rotateRight, 'Rotate', _rotate),
          const Spacer(),
          button(AppIcons.check, 'Apply', _apply),
        ],
      ),
      child: AbsorbPointer(
        absorbing: busy,
        child: _CropPreview(
          imageBytes: _workingBytes,
          imageWidth: _decodedImage.width,
          imageHeight: _decodedImage.height,
          originalRatio: _originalRatio,
          bounds: _bounds,
          color: _cropColor,
          onHandleDrag: _moveHandle,
          onCropDrag: _moveCrop,
        ),
      ),
    );
  }

  Future<void> _rotate() async {
    setState(() => _rotating = true);
    try {
      final rotatedBytes = await compute(_rotateCoverBytes, _workingBytes);
      final rotated = _decode(rotatedBytes);
      if (!mounted) return;
      setState(() {
        _decodedImage = rotated;
        _workingBytes = rotatedBytes;
        _bounds = const _CropBounds.fullFrame();
      });
    } catch (_) {
      if (mounted) _showError('Could not rotate this cover.');
    } finally {
      if (mounted) setState(() => _rotating = false);
    }
  }

  void _moveCrop(Offset delta, Size imageSize) {
    if (imageSize.width <= 0 || imageSize.height <= 0) return;
    final width = _bounds.right - _bounds.left;
    final height = _bounds.bottom - _bounds.top;
    final left = (_bounds.left + delta.dx / imageSize.width)
        .clamp(0.0, 1.0 - width)
        .toDouble();
    final top = (_bounds.top + delta.dy / imageSize.height)
        .clamp(0.0, 1.0 - height)
        .toDouble();
    setState(() {
      _bounds = _CropBounds(
          left: left, top: top, right: left + width, bottom: top + height);
    });
  }

  void _moveHandle(_CropHandle handle, Offset delta, Size imageSize) {
    if (imageSize.width <= 0 || imageSize.height <= 0) return;
    final dx = delta.dx / imageSize.width;
    final dy = delta.dy / imageSize.height;
    var left = _bounds.left;
    var top = _bounds.top;
    var right = _bounds.right;
    var bottom = _bounds.bottom;

    if (handle.movesLeft) {
      left = (left + dx).clamp(0.0, right - _minimumCropSize);
    }
    if (handle.movesRight) {
      right = (right + dx).clamp(left + _minimumCropSize, 1.0);
    }
    if (handle.movesTop) {
      top = (top + dy).clamp(0.0, bottom - _minimumCropSize);
    }
    if (handle.movesBottom) {
      bottom = (bottom + dy).clamp(top + _minimumCropSize, 1.0);
    }

    setState(() {
      _bounds = _CropBounds(left: left, top: top, right: right, bottom: bottom);
    });
  }

  Future<void> _apply() async {
    setState(() => _applying = true);
    try {
      final bytes = await compute(
        _cropCoverBytes,
        <String, Object>{
          'imageBytes': _workingBytes,
          'left': _bounds.left,
          'top': _bounds.top,
          'right': _bounds.right,
          'bottom': _bounds.bottom,
        },
      );
      if (mounted) await widget.onApply(bytes);
    } catch (_) {
      if (mounted) _showError('Could not crop this cover.');
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  img.Image _decode(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw const FormatException('Invalid cover image.');
    return decoded;
  }
}

Uint8List _rotateCoverBytes(Uint8List imageBytes) {
  final decoded = img.decodeImage(imageBytes);
  if (decoded == null) throw const FormatException('Invalid cover image.');
  return Uint8List.fromList(
    img.encodePng(img.copyRotate(decoded, angle: 90)),
  );
}

Uint8List _cropCoverBytes(Map<String, Object> request) {
  final decoded = img.decodeImage(request['imageBytes'] as Uint8List);
  if (decoded == null) throw const FormatException('Invalid cover image.');
  final left = request['left'] as double;
  final top = request['top'] as double;
  final right = request['right'] as double;
  final bottom = request['bottom'] as double;
  final x = (decoded.width * left).round().clamp(0, decoded.width - 1);
  final y = (decoded.height * top).round().clamp(0, decoded.height - 1);
  final width =
      (decoded.width * (right - left)).round().clamp(1, decoded.width - x);
  final height =
      (decoded.height * (bottom - top)).round().clamp(1, decoded.height - y);
  return Uint8List.fromList(
    img.encodePng(
      img.copyCrop(decoded, x: x, y: y, width: width, height: height),
    ),
  );
}

enum _CropHandle {
  topLeft,
  top,
  topRight,
  right,
  bottomRight,
  bottom,
  bottomLeft,
  left;

  bool get movesLeft => this == topLeft || this == bottomLeft || this == left;
  bool get movesTop => this == topLeft || this == top || this == topRight;
  bool get movesRight =>
      this == topRight || this == right || this == bottomRight;
  bool get movesBottom =>
      this == bottomLeft || this == bottom || this == bottomRight;

  MouseCursor get cursor => switch (this) {
        topLeft || bottomRight => SystemMouseCursors.resizeUpLeftDownRight,
        topRight || bottomLeft => SystemMouseCursors.resizeUpRightDownLeft,
        top || bottom => SystemMouseCursors.resizeUpDown,
        left || right => SystemMouseCursors.resizeLeftRight,
      };
}

final class _CropBounds {
  const _CropBounds({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  const _CropBounds.fullFrame()
      : left = 0,
        top = 0,
        right = 1,
        bottom = 1;

  final double left;
  final double top;
  final double right;
  final double bottom;
}

final class _CropPreview extends StatelessWidget {
  const _CropPreview({
    required this.imageBytes,
    required this.imageWidth,
    required this.imageHeight,
    required this.originalRatio,
    required this.bounds,
    required this.color,
    required this.onHandleDrag,
    required this.onCropDrag,
  });

  final Uint8List imageBytes;
  final int imageWidth;
  final int imageHeight;

  /// Keeps the panel's height through a turn to a wider image.
  final double originalRatio;
  final _CropBounds bounds;
  final Color color;
  final void Function(_CropHandle handle, Offset delta, Size imageSize)
      onHandleDrag;
  final void Function(Offset delta, Size imageSize) onCropDrag;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const inset = LibraryCoverPanelFrame.inset;
        final width = constraints.maxWidth - inset * 2;
        final imageSize = Size(width, width * imageHeight / imageWidth);
        final height = math.max(imageSize.height, width / originalRatio);
        final imageRect = const Offset(inset, inset) & imageSize;
        final cropRect = Rect.fromLTRB(
          imageRect.left + imageRect.width * bounds.left,
          imageRect.top + imageRect.height * bounds.top,
          imageRect.left + imageRect.width * bounds.right,
          imageRect.top + imageRect.height * bounds.bottom,
        );

        return SizedBox(
          height: height + inset * 2,
          child: Stack(
            children: [
              Positioned.fromRect(
                rect: imageRect,
                child: Image.memory(imageBytes, fit: BoxFit.fill),
              ),
              Positioned.fromRect(
                rect: cropRect,
                child: MouseRegion(
                  cursor: SystemMouseCursors.move,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanUpdate: (details) =>
                        onCropDrag(details.delta, imageSize),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: color),
                      ),
                    ),
                  ),
                ),
              ),
              for (final handle in _CropHandle.values)
                _positionedHandle(
                  handle,
                  cropRect,
                  imageSize,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _positionedHandle(
    _CropHandle handle,
    Rect cropRect,
    Size imageSize,
  ) {
    final point = switch (handle) {
      _CropHandle.topLeft => cropRect.topLeft,
      _CropHandle.top => Offset(cropRect.center.dx, cropRect.top),
      _CropHandle.topRight => cropRect.topRight,
      _CropHandle.right => Offset(cropRect.right, cropRect.center.dy),
      _CropHandle.bottomRight => cropRect.bottomRight,
      _CropHandle.bottom => Offset(cropRect.center.dx, cropRect.bottom),
      _CropHandle.bottomLeft => cropRect.bottomLeft,
      _CropHandle.left => Offset(cropRect.left, cropRect.center.dy),
    };
    return Positioned(
      left: point.dx - 10,
      top: point.dy - 10,
      width: 20,
      height: 20,
      child: MouseRegion(
        cursor: handle.cursor,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanUpdate: (details) =>
              onHandleDrag(handle, details.delta, imageSize),
          child: Center(
            child: ColoredBox(
              color: color,
              child: const SizedBox.square(dimension: 5),
            ),
          ),
        ),
      ),
    );
  }
}
