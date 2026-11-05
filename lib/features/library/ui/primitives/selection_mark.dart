import 'package:flutter/material.dart';

/// A small selection glyph, independent of icon fonts and input handling.
class LibrarySelectionMark extends StatelessWidget {
  const LibrarySelectionMark({
    super.key,
    required this.checked,
    required this.foregroundColor,
    this.cutoutColor = Colors.transparent,
    this.outlined = false,
    this.indeterminate = false,
  });

  final bool checked;
  final bool indeterminate;
  final bool outlined;
  final Color foregroundColor;
  final Color cutoutColor;

  @override
  Widget build(BuildContext context) => Semantics(
        checked: checked,
        child: Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: outlined ? null : foregroundColor,
            borderRadius: BorderRadius.circular(2),
            border: outlined
                ? Border.all(color: foregroundColor, width: 1.2)
                : null,
          ),
          child: checked || indeterminate
              ? CustomPaint(
                  painter: _SelectionCheckPainter(
                      color: outlined ? foregroundColor : cutoutColor,
                      indeterminate: indeterminate))
              : null,
        ),
      );
}

class _SelectionCheckPainter extends CustomPainter {
  const _SelectionCheckPainter(
      {required this.color, required this.indeterminate});

  final Color color;
  final bool indeterminate;

  @override
  void paint(Canvas canvas, Size size) {
    final path = indeterminate
        ? (Path()
          ..moveTo(size.width * .25, size.height * .5)
          ..lineTo(size.width * .75, size.height * .5))
        : (Path()
          ..moveTo(size.width * .22, size.height * .5)
          ..lineTo(size.width * .43, size.height * .72)
          ..lineTo(size.width * .8, size.height * .28));
    canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round);
  }

  @override
  bool shouldRepaint(_SelectionCheckPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.indeterminate != indeterminate;
}
