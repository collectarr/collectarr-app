import 'dart:math' as math;

import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// How long a tick takes to draw in or out, as Material's checkbox does.
const appCheckToggleDuration = Duration(milliseconds: 200);

/// The colors of one checkbox face, unchecked and checked.
@immutable
class AppCheckLook {
  const AppCheckLook({
    required this.fill,
    required this.checkedFill,
    required this.check,
    this.border,
    this.checkedBorder,
    this.borderWidth = 1,
    this.radius = 3,
    this.tickWidth,
  });

  /// The reference's form checkbox: a white box with a dark tick on dark
  /// themes, and an outlined box filled with ink on light ones.
  factory AppCheckLook.form(BuildContext context) {
    final palette = appPalette(context);
    return palette.isDark
        ? const AppCheckLook(
            fill: Colors.white,
            checkedFill: Colors.white,
            check: Color(0xFF333333))
        : AppCheckLook(
            fill: Colors.white,
            checkedFill: palette.textPrimary,
            check: Colors.white,
            border: palette.textMuted,
            checkedBorder: palette.textPrimary);
  }

  final Color fill;
  final Color checkedFill;
  final Color check;
  final Color? border;
  final Color? checkedBorder;
  final double borderWidth;
  final double radius;

  /// The tick's stroke; by default it scales with the box.
  final double? tickWidth;
}

/// A checkbox face whose tick draws in when checked and out when cleared.
///
/// [value] null shows a dash for a partial selection. The tick appears at
/// once when animations are off in Settings or on the system.
class AppCheckMark extends StatelessWidget {
  const AppCheckMark({
    super.key,
    required this.value,
    required this.look,
    this.size = 16,
  });

  final bool? value;
  final AppCheckLook look;
  final double size;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(end: value == false ? 0 : 1),
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : appCheckToggleDuration,
        curve: Curves.easeOut,
        builder: (context, progress, _) => CustomPaint(
          size: Size.square(size),
          painter: _AppCheckPainter(
              progress: progress, partial: value == null, look: look),
        ),
      );
}

class _AppCheckPainter extends CustomPainter {
  const _AppCheckPainter(
      {required this.progress, required this.partial, required this.look});

  final double progress;
  final bool partial;
  final AppCheckLook look;

  @override
  void paint(Canvas canvas, Size size) {
    // The box takes its checked colors in the first half, as Material's does.
    final fillProgress = math.min(progress * 2, 1.0);
    final box = RRect.fromRectAndRadius(
        Offset.zero & size, Radius.circular(look.radius));
    canvas.drawRRect(box,
        Paint()..color = Color.lerp(look.fill, look.checkedFill, fillProgress)!);
    final border = look.border == null && look.checkedBorder == null
        ? null
        : Color.lerp(look.border ?? Colors.transparent,
            look.checkedBorder ?? Colors.transparent, fillProgress);
    if (border != null && border.a > 0) {
      canvas.drawRRect(
          box.deflate(look.borderWidth / 2),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = look.borderWidth
            ..color = border);
    }
    if (progress == 0) return;
    final ink = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = look.tickWidth ?? size.width * .13
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = look.check;
    final w = size.width;
    if (partial) {
      final half = w * .28 * progress;
      canvas.drawLine(Offset(w / 2 - half, w / 2), Offset(w / 2 + half, w / 2),
          ink);
      return;
    }
    final tick = Path()
      ..moveTo(w * .22, w * .52)
      ..lineTo(w * .42, w * .72)
      ..lineTo(w * .78, w * .32);
    final metric = tick.computeMetrics().single;
    canvas.drawPath(metric.extractPath(0, metric.length * progress), ink);
  }

  @override
  bool shouldRepaint(_AppCheckPainter old) =>
      old.progress != progress || old.partial != partial || old.look != look;
}

/// The app's checkbox: the reference's form look with an animated tick.
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 16,
    this.look,
    this.semanticLabel,
  });

  /// Null shows a partial selection; tapping it checks the box.
  final bool? value;
  final ValueChanged<bool>? onChanged;
  final double size;
  final AppCheckLook? look;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    return Semantics(
      label: semanticLabel,
      checked: value ?? false,
      mixed: value == null,
      enabled: enabled,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? () => onChanged!(value != true) : null,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Opacity(
              opacity: enabled ? 1 : .5,
              child: AppCheckMark(
                  value: value,
                  look: look ?? AppCheckLook.form(context),
                  size: size),
            ),
          ),
        ),
      ),
    );
  }
}

/// A checkbox with its label; the whole row toggles it.
class AppCheckboxTile extends StatelessWidget {
  const AppCheckboxTile({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.style,
    this.size = 16,
  });

  final bool? value;
  final ValueChanged<bool>? onChanged;
  final String label;
  final TextStyle? style;
  final double size;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    return InkWell(
      onTap: enabled ? () => onChanged!(value != true) : null,
      borderRadius: BorderRadius.circular(3),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Opacity(
            opacity: enabled ? 1 : .5,
            child: AppCheckMark(
                value: value, look: AppCheckLook.form(context), size: size),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Semantics(
              checked: value ?? false,
              enabled: enabled,
              child: Text(label,
                  style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: appPalette(context).textPrimary
                              .withValues(alpha: enabled ? 1 : .5))
                      .merge(style)),
            ),
          ),
        ]),
      ),
    );
  }
}
