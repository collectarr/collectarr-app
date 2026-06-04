import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';

class LibraryAddResultBadge extends StatelessWidget {
  const LibraryAddResultBadge(
    this.label, {
    super.key,
    this.accent,
    this.icon,
    this.backgroundColor,
    this.borderColor,
    this.foregroundColor,
  });

  final String label;
  final Color? accent;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final badgeColor =
        accent ?? LibraryAccentScope.maybeOf(context)?.accent ?? palette.accent;
    final resolvedForeground = foregroundColor ??
        (ThemeData.estimateBrightnessForColor(badgeColor) == Brightness.dark
            ? Colors.white
            : palette.textPrimary);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ??
            Color.alphaBlend(
              palette.surfaceDim.withValues(alpha: 0.62),
              badgeColor,
            ),
        borderRadius: BorderRadius.circular(3),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 11, color: resolvedForeground),
              const SizedBox(width: 3),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: resolvedForeground,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
