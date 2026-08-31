import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// A standard empty state visual primitive for Library UI.
///
/// Standardizes:
/// - Centered layout with responsive scrollable container
/// - Accent-tinted icon
/// - Title and subtitle typography using [LibraryTextTheme]
/// - Primary and secondary actions
class LibraryEmptyVisualState extends StatelessWidget {
  const LibraryEmptyVisualState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.accent,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.secondaryActionIcon,
    this.footer,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    this.maxWidth = 420,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Color? accent;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? actionIcon;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final IconData? secondaryActionIcon;
  final Widget? footer;
  final EdgeInsetsGeometry padding;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final theme = Theme.of(context);
    final effectiveAccent = accent ?? palette.accent;

    return Center(
      child: SingleChildScrollView(
        padding: padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 44, color: effectiveAccent),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.panelTitle.copyWith(
                  color: palette.textPrimary,
                ),
              ),
              if (message != null && message!.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  message!.trim(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.supportingText.copyWith(
                    color: palette.textMuted,
                  ),
                ),
              ],
              if (onAction != null || onSecondaryAction != null) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    if (onSecondaryAction != null &&
                        secondaryActionLabel != null)
                      OutlinedButton.icon(
                        onPressed: onSecondaryAction,
                        icon: secondaryActionIcon != null
                            ? Icon(secondaryActionIcon, size: 16)
                            : const SizedBox.shrink(),
                        label: Text(secondaryActionLabel!),
                      ),
                    if (onAction != null && actionLabel != null)
                      FilledButton.icon(
                        onPressed: onAction,
                        style: FilledButton.styleFrom(
                          backgroundColor: effectiveAccent,
                          foregroundColor: Colors.white,
                        ),
                        icon: actionIcon != null
                            ? Icon(actionIcon, size: 16)
                            : const SizedBox.shrink(),
                        label: Text(actionLabel!),
                      ),
                  ],
                ),
              ],
              if (footer != null) ...[
                const SizedBox(height: 12),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
