import 'package:flutter/material.dart';

enum AppToastTone {
  info,
  success,
  error,
}

void showAppToast(
  BuildContext context,
  String message, {
  AppToastTone tone = AppToastTone.info,
}) {
  if (!context.mounted) {
    return;
  }
  final theme = Theme.of(context);
  final (icon, backgroundColor, foregroundColor) = switch (tone) {
    AppToastTone.info => (
        Icons.info_outline,
        theme.colorScheme.inverseSurface,
        theme.colorScheme.onInverseSurface,
      ),
    AppToastTone.success => (
        Icons.check_circle_outline,
        theme.colorScheme.tertiaryContainer,
        theme.colorScheme.onTertiaryContainer,
      ),
    AppToastTone.error => (
        Icons.error_outline,
        theme.colorScheme.errorContainer,
        theme.colorScheme.onErrorContainer,
      ),
  };
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, size: 18, color: foregroundColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: foregroundColor),
            ),
          ),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: backgroundColor,
      duration: const Duration(seconds: 4),
    ),
  );
}