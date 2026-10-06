import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/ui/library_panel_header.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:flutter/material.dart';

/// Uniform accent-colored header strip for all modal dialogs.
///
/// Renders the application's main accent with the exact same gradient,
/// lighting and border effect as the top app bar.
class AccentDialogHeader extends StatelessWidget {
  const AccentDialogHeader({
    super.key,
    required this.title,
    this.icon,
    this.onClose,
    this.trailing,
    this.minHeight,
    this.titleStyle,
  });

  final String title;
  final double? minHeight;
  final TextStyle? titleStyle;

  final IconData? icon;

  /// Called when the close button is tapped. If null, no close button is shown.
  final VoidCallback? onClose;

  /// Optional widget shown between the title and the close button.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = LibraryAccentScope.accentOf(context, fallback: colorScheme.primary);
    const foreground = Colors.white;
    return AnimatedLibraryChromeGradient(
      accent: accent,
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      borderBuilder: (animatedAccent, _) => Border(
        bottom: BorderSide(
          color: Color.alphaBlend(
            Colors.white.withValues(alpha: 0.12),
            animatedAccent,
          ),
        ),
      ),
      child: LibraryPanelHeader(
        backgroundColor: Colors.transparent,
        minHeight: minHeight,
        foregroundColor: foreground,
        borderColor: Colors.transparent,
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
                style: TextStyle(
                  color: foreground,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ).merge(titleStyle),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
