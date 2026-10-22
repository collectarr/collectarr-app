import 'package:collectarr_app/ui/app_icons.dart';
import 'package:flutter/material.dart';

/// Resolves an icon representing the platform.
IconData resolveGamePlatformIcon(String platform) {
  final lower = platform.toLowerCase();
  if (lower.contains('pc') ||
      lower.contains('windows') ||
      lower.contains('mac') ||
      lower.contains('linux') ||
      lower.contains('dos') ||
      lower.contains('steam') ||
      lower.contains('computer')) {
    return Icons.desktop_windows;
  }
  if (lower.contains('android') ||
      lower.contains('ios') ||
      lower.contains('mobile') ||
      lower.contains('phone')) {
    return Icons.smartphone;
  }
  return AppIcons.gamepad;
}

/// Builds the platform icon cell for the Games list view matching the reference.
Widget buildGamePlatformIcon(String? platform) {
  if (platform == null || platform.trim().isEmpty) {
    return const SizedBox.shrink();
  }
  final p = platform.trim();
  final icon = resolveGamePlatformIcon(p);
  return Center(
    child: Tooltip(
      message: p,
      child: Icon(
        icon,
        size: 16,
        color: const Color(0xFF9E9E9E),
      ),
    ),
  );
}
