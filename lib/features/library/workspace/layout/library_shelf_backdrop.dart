import 'dart:math' as math;

import 'package:flutter/material.dart';

const libraryShelfBackColor = Color(0xffb57e36);
const libraryShelfPlankColor = Color(0xffb77a30);
const libraryShelfHighlightColor = Color(0xffd79c4c);

/// Original code-drawn timber backdrop; no external shelf image is required.
class LibraryShelfBackdrop extends StatelessWidget {
  const LibraryShelfBackdrop({
    super.key,
    required this.child,
    required this.shelfPitch,
    this.color = libraryShelfBackColor,
  });

  final Widget child;
  final double shelfPitch;
  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _ShelfTimberPainter(shelfPitch: shelfPitch, color: color),
        child: child,
      );
}

class _ShelfTimberPainter extends CustomPainter {
  const _ShelfTimberPainter({required this.shelfPitch, required this.color});

  final double shelfPitch;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    final pitch = math.max(1.0, shelfPitch);
    for (var top = 0.0; top < size.height; top += pitch) {
      final rect = Rect.fromLTWH(0, top, size.width, pitch);
      canvas.drawRect(
          rect,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.alphaBlend(const Color(0x35000000), color),
                color,
                libraryShelfHighlightColor,
                libraryShelfPlankColor,
              ],
              stops: const [0, .12, .93, 1],
            ).createShader(rect));
    }
    // Fine, deterministic vertical grain continues across empty shelf space.
    final grain = Paint()..strokeWidth = .7;
    for (var x = 0.0; x < size.width; x += 3) {
      grain.color =
          Colors.black.withValues(alpha: .015 + .012 * (1 + math.sin(x)));
      canvas.drawLine(Offset(x, 0), Offset(x + 1, size.height), grain);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ShelfTimberPainter oldDelegate) =>
      oldDelegate.shelfPitch != shelfPitch || oldDelegate.color != color;
}
