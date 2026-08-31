import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// A standard form section card in Library UI.
///
/// Owns:
/// - Section border and background
/// - Section padding
/// - Title typography and title/accent relationship
/// - Spacing between title and content
///
/// Does NOT own:
/// - Field semantics
/// - Field ordering
/// - Kind vocabulary
class LibraryFormSection extends StatelessWidget {
  const LibraryFormSection({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.accent,
    this.trailing,
    this.padding = const EdgeInsets.all(12),
    this.contentSpacing = 10.0,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
  });

  final String title;
  final Widget child;
  final IconData? icon;
  final Color? accent;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final double contentSpacing;
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final theme = Theme.of(context);
    final sectionAccent = accent ?? palette.accent;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? palette.canvas,
        borderRadius: borderRadius ?? BorderRadius.circular(4),
        border: Border.all(color: borderColor ?? palette.divider),
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: sectionAccent),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.sectionTitle.copyWith(
                      color: sectionAccent,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            SizedBox(height: contentSpacing),
            child,
          ],
        ),
      ),
    );
  }
}
