import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// A standard error state widget for panels, search lists, and dialogs.
class LibraryErrorState extends StatelessWidget {
  const LibraryErrorState({
    super.key,
    this.title = 'Something went wrong',
    required this.message,
    this.details,
    this.onRetry,
    this.retryLabel = 'Retry',
    this.icon = Icons.error_outline,
    this.accent,
    this.padding = const EdgeInsets.all(24),
  });

  final String title;
  final String message;
  final String? details;
  final VoidCallback? onRetry;
  final String retryLabel;
  final IconData icon;
  final Color? accent;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final theme = Theme.of(context);
    final errorColor = accent ?? theme.colorScheme.error;

    return Center(
      child: Padding(
        padding: padding,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: errorColor),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.panelTitle.copyWith(
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.supportingText.copyWith(
                  color: palette.textMuted,
                ),
              ),
              if (details != null && details!.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  details!.trim(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.supportingText.copyWith(
                    color: palette.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: Text(retryLabel),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
