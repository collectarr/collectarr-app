import 'package:collectarr_app/features/library/ui/library_panel_header.dart';
import 'package:flutter/material.dart';

/// Uniform accent-colored header strip for all modal dialogs.
///
/// Renders the library accent color as background with white title text,
/// an optional leading icon, and an optional close button.
class AccentDialogHeader extends StatelessWidget {
  const AccentDialogHeader({
    super.key,
    required this.title,
    this.accent,
    this.icon,
    this.onClose,
    this.trailing,
  });

  final String title;

  /// Accent background color. Falls back to [ColorScheme.primary].
  final Color? accent;

  final IconData? icon;

  /// Called when the close button is tapped. If null, no close button is shown.
  final VoidCallback? onClose;

  /// Optional widget shown between the title and the close button.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final bg = accent ?? Theme.of(context).colorScheme.primary;
    return LibraryPanelHeader(
      backgroundColor: bg,
      foregroundColor: Colors.white,
      borderColor: bg.withValues(alpha: 0.92),
      onClose: onClose,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
