import 'package:collectarr_app/ui/library_square_close_button.dart';
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
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          bottom: BorderSide(color: bg.withValues(alpha: 0.92)),
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Colors.white),
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
          if (onClose != null)
            LibrarySquareCloseButton(
              tooltip: 'Close',
              onPressed: onClose!,
              borderColor: Colors.white.withValues(alpha: 0.8),
              foregroundColor: Colors.white,
            ),
        ],
      ),
    );
  }
}
