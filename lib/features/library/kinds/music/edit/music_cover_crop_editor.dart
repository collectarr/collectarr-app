import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

/// Interactive crop and quarter-turn editor shared by Music cover panels.
final class MusicCoverCropEditor extends StatefulWidget {
  const MusicCoverCropEditor({
    super.key,
    required this.title,
    required this.imageBytes,
    required this.onApply,
  });

  final String title;
  final Uint8List imageBytes;
  final Future<void> Function(Uint8List bytes) onApply;

  @override
  State<MusicCoverCropEditor> createState() => _MusicCoverCropEditorState();
}

final class _MusicCoverCropEditorState extends State<MusicCoverCropEditor> {
  static const double _minimumCropSize = 0.08;

  late Uint8List _workingBytes;
  late img.Image _decodedImage;
  _CropBounds _bounds = const _CropBounds.fullFrame();
  bool _rotating = false;
  bool _applying = false;

  @override
  void initState() {
    super.initState();
    _workingBytes = widget.imageBytes;
    _decodedImage = _decode(_workingBytes);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final busy = _rotating || _applying;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 7, 10, 5),
            child: Text(
              widget.title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          ColoredBox(
            color: colors.primary,
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: busy ? null : _reset,
                  style: _toolbarButtonStyle(colors),
                  icon: const Icon(Icons.close),
                  label: const Text('Reset'),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: busy ? null : _rotate,
                  style: _toolbarButtonStyle(colors),
                  icon: const Icon(Icons.rotate_right),
                  label: const Text('Rotate'),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: busy ? null : _apply,
                  style: _toolbarButtonStyle(colors),
                  icon: _applying
                      ? SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colors.onPrimary,
                            ),
                          ),
                        )
                      : const Icon(Icons.check),
                  label: const Text('Apply'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: AspectRatio(
                aspectRatio: 1.08,
                child: AbsorbPointer(
                  absorbing: busy,
                  child: _CropPreview(
                    imageBytes: _workingBytes,
                    imageWidth: _decodedImage.width,
                    imageHeight: _decodedImage.height,
                    bounds: _bounds,
                    accent: colors.primary,
                    onHandleDrag: _moveHandle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ButtonStyle _toolbarButtonStyle(ColorScheme colors) => TextButton.styleFrom(
        foregroundColor: colors.onPrimary,
        minimumSize: const Size(0, 38),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      );

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

  void _reset() {
    setState(() {
      _workingBytes = widget.imageBytes;
      _decodedImage = _decode(widget.imageBytes);
      _bounds = const _CropBounds.fullFrame();
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
    required this.bounds,
    required this.accent,
    required this.onHandleDrag,
  });

  final Uint8List imageBytes;
  final int imageWidth;
  final int imageHeight;
  final _CropBounds bounds;
  final Color accent;
  final void Function(_CropHandle handle, Offset delta, Size imageSize)
      onHandleDrag;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = Size(constraints.maxWidth, constraints.maxHeight);
        final imageRatio = imageWidth / imageHeight;
        final availableRatio = available.width / available.height;
        final imageSize = availableRatio > imageRatio
            ? Size(available.height * imageRatio, available.height)
            : Size(available.width, available.width / imageRatio);
        final imageRect = Rect.fromLTWH(
          (available.width - imageSize.width) / 2,
          (available.height - imageSize.height) / 2,
          imageSize.width,
          imageSize.height,
        );
        final cropRect = Rect.fromLTRB(
          imageRect.left + imageRect.width * bounds.left,
          imageRect.top + imageRect.height * bounds.top,
          imageRect.left + imageRect.width * bounds.right,
          imageRect.top + imageRect.height * bounds.bottom,
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: Color(0xFFE3E3E1)),
            Positioned.fromRect(
              rect: imageRect,
              child: Image.memory(imageBytes, fit: BoxFit.fill),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _CropOverlayPainter(
                  imageRect: imageRect,
                  cropRect: cropRect,
                  accent: accent,
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
        cursor: SystemMouseCursors.move,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanUpdate: (details) =>
              onHandleDrag(handle, details.delta, imageSize),
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: accent,
                border: Border.all(color: Colors.white, width: 1),
                borderRadius: BorderRadius.circular(1),
              ),
              child: const SizedBox.square(dimension: 7),
            ),
          ),
        ),
      ),
    );
  }
}

final class _CropOverlayPainter extends CustomPainter {
  const _CropOverlayPainter({
    required this.imageRect,
    required this.cropRect,
    required this.accent,
  });

  final Rect imageRect;
  final Rect cropRect;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final outside = Path.combine(
      PathOperation.difference,
      Path()..addRect(imageRect),
      Path()..addRect(cropRect),
    );
    canvas.drawPath(
      outside,
      Paint()..color = Colors.black.withValues(alpha: 0.52),
    );
    canvas.drawRect(
      cropRect,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    final grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.48)
      ..strokeWidth = 0.7;
    for (var division = 1; division < 3; division++) {
      final x = cropRect.left + cropRect.width * division / 3;
      final y = cropRect.top + cropRect.height * division / 3;
      canvas.drawLine(
          Offset(x, cropRect.top), Offset(x, cropRect.bottom), grid);
      canvas.drawLine(
          Offset(cropRect.left, y), Offset(cropRect.right, y), grid);
    }
  }

  @override
  bool shouldRepaint(covariant _CropOverlayPainter oldDelegate) =>
      oldDelegate.imageRect != imageRect ||
      oldDelegate.cropRect != cropRect ||
      oldDelegate.accent != accent;
}
