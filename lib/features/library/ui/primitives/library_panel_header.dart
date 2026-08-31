import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Standard panel or dialog header for Library UI.
///
/// Owns:
/// - Header title typography
/// - Leading icon or navigation action (back/close)
/// - Subtitle and metadata badges
/// - Trailing actions
/// - Divider styling
class LibraryPanelHeader extends StatelessWidget {
  const LibraryPanelHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.accent,
    this.onClose,
    this.onBack,
    this.trailing,
    this.showBottomDivider = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? accent;
  final VoidCallback? onClose;
  final VoidCallback? onBack;
  final Widget? trailing;
  final bool showBottomDivider;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final theme = Theme.of(context);
    final headerAccent = accent ?? palette.accent;

    return Container(
      decoration: BoxDecoration(
        color: palette.panel,
        border: showBottomDivider
            ? Border(bottom: BorderSide(color: palette.divider))
            : null,
      ),
      padding: padding,
      child: Row(
        children: [
          if (onBack != null) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back, size: 18),
              onPressed: onBack,
              tooltip: 'Back',
            ),
            const SizedBox(width: 8),
          ] else if (icon != null) ...[
            Icon(icon, size: 20, color: headerAccent),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.panelTitle.copyWith(
                    color: palette.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!.trim(),
                    style: theme.textTheme.supportingText.copyWith(
                      color: palette.textMuted,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
          if (onClose != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: onClose,
              tooltip: 'Close',
            ),
          ],
        ],
      ),
    );
  }
}
