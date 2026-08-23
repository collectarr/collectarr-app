import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibraryInfoChip extends StatelessWidget {
  const LibraryInfoChip({
    super.key,
    required this.label,
    this.icon,
    this.foreground,
    this.background,
    this.borderColor,
  });

  final String label;
  final IconData? icon;
  final Color? foreground;
  final Color? background;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final resolvedForeground = foreground ?? palette.textPrimary;
    final resolvedBackground = background ?? palette.surface;
    final resolvedBorder = borderColor ?? palette.divider;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: resolvedBackground,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: resolvedBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: resolvedForeground),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                color: resolvedForeground,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LibraryStatusChip extends StatelessWidget {
  const LibraryStatusChip({
    super.key,
    required this.label,
    this.icon,
    this.foreground,
    this.background,
    this.borderColor,
  });

  final String label;
  final IconData? icon;
  final Color? foreground;
  final Color? background;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return LibraryInfoChip(
      label: label,
      icon: icon,
      foreground: foreground,
      background: background,
      borderColor: borderColor,
    );
  }
}
