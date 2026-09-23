import 'package:flutter/material.dart';

import 'package:collectarr_app/ui/theme/theme_palette.dart';

/// Inline error banner with icon and message.
///
/// Use for non-blocking, contextual error messages inside a form or list.
class AppErrorBanner extends StatelessWidget {
  const AppErrorBanner(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.errorBackground,
        border: Border.all(color: palette.errorBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 18,
              color: palette.errorForeground,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: palette.errorForeground,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
