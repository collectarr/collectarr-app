import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// A standard loading state widget for Library panels and panes.
class LibraryLoadingState extends StatelessWidget {
  const LibraryLoadingState({
    super.key,
    this.message,
    this.accent,
    this.padding = const EdgeInsets.all(24),
  });

  final String? message;
  final Color? accent;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final theme = Theme.of(context);
    final progressColor = accent ?? palette.accent;

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            if (message != null && message!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                message!.trim(),
                textAlign: TextAlign.center,
                style: theme.textTheme.supportingText.copyWith(
                  color: palette.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
