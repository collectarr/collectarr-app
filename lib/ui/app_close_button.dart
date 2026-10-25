import 'package:flutter/material.dart';

/// The close control of dialog and panel headers. Like the reference it is
/// a plain 10 px "×", without hover, press or ripple effect; callers may pass
/// an [icon] instead.
class AppCloseButton extends StatelessWidget {
  const AppCloseButton({
    super.key,
    required this.onPressed,
    this.color,
    this.size = 24,
    this.iconSize = 16,
    this.icon,
  });

  final VoidCallback? onPressed;
  final Color? color;
  final double size;
  final double iconSize;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: 'Close',
        onPressed: onPressed,
        constraints: BoxConstraints.tightFor(width: size, height: size),
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.standard,
        style: IconButton.styleFrom(
          foregroundColor: color,
          backgroundColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          side: BorderSide.none,
          padding: EdgeInsets.zero,
          minimumSize: Size(size, size),
          maximumSize: Size(size, size),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ).copyWith(
            overlayColor: const WidgetStatePropertyAll(Colors.transparent)),
        icon: icon == null
            ? Builder(
                builder: (context) => CustomPaint(
                    size: const Size.square(10),
                    painter: _CrossPainter(
                        color ?? IconTheme.of(context).color ?? Colors.white)))
            : Icon(icon, size: iconSize),
      );
}

/// The reference's 10 px "×", drawn rather than set as text: font fallback
/// placed the character a few pixels low in the browser.
class _CrossPainter extends CustomPainter {
  const _CrossPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    const inset = 1.2;
    canvas.drawLine(const Offset(inset, inset),
        Offset(size.width - inset, size.height - inset), paint);
    canvas.drawLine(Offset(size.width - inset, inset),
        Offset(inset, size.height - inset), paint);
  }

  @override
  bool shouldRepaint(_CrossPainter old) => old.color != color;
}
