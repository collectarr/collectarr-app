import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum LibraryInfoPanelVariant {
  info,
  hint,
  warning,
  accent,
}

/// A standard informational panel for defaults, hints, provider info, and warnings.
class LibraryInfoPanel extends StatelessWidget {
  const LibraryInfoPanel({
    super.key,
    this.title,
    required this.message,
    this.icon,
    this.variant = LibraryInfoPanelVariant.info,
    this.accentColor,
    this.action,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  });

  final String? title;
  final String message;
  final IconData? icon;
  final LibraryInfoPanelVariant variant;
  final Color? accentColor;
  final Widget? action;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final theme = Theme.of(context);

    final effectiveColor = _resolveColor(context, palette);
    final effectiveIcon = icon ?? _resolveDefaultIcon();

    return Container(
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: palette.isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: effectiveColor.withValues(alpha: palette.isDark ? 0.35 : 0.25),
        ),
      ),
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(effectiveIcon, size: 18, color: effectiveColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null && title!.trim().isNotEmpty) ...[
                  Text(
                    title!.trim(),
                    style: theme.textTheme.sectionTitle.copyWith(
                      color: palette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                ],
                Text(
                  message,
                  style: theme.textTheme.supportingText.copyWith(
                    color: palette.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: 8),
            action!,
          ],
        ],
      ),
    );
  }

  Color _resolveColor(BuildContext context, AppThemePalette palette) {
    if (accentColor != null) return accentColor!;
    switch (variant) {
      case LibraryInfoPanelVariant.info:
        return palette.accent;
      case LibraryInfoPanelVariant.hint:
        return palette.textMuted;
      case LibraryInfoPanelVariant.warning:
        return palette.highlight;
      case LibraryInfoPanelVariant.accent:
        return palette.accent;
    }
  }

  IconData _resolveDefaultIcon() {
    switch (variant) {
      case LibraryInfoPanelVariant.info:
        return Icons.info_outline;
      case LibraryInfoPanelVariant.hint:
        return Icons.lightbulb_outline;
      case LibraryInfoPanelVariant.warning:
        return Icons.warning_amber_rounded;
      case LibraryInfoPanelVariant.accent:
        return Icons.auto_awesome;
    }
  }
}
