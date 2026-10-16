import 'package:flutter_svg/flutter_svg.dart';
import 'package:collectarr_app/ui/app_panel_title.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/ui/library_panel_header.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:flutter/material.dart';

/// Uniform accent-colored header strip for all modal dialogs.
///
/// Uses the current kind's accent chrome and fixed white title metrics.
class AccentDialogHeader extends StatelessWidget {
  const AccentDialogHeader({
    super.key,
    required this.title,
    required this.icon,
    this.onClose,
    this.showCloseButton = true,
    this.trailing,
    this.minHeight,
    this.accent,
    this.svgAsset,
  });

  final String title;
  final double? minHeight;
  final Color? accent;

  final IconData icon;
  final String? svgAsset;

  /// Called when the close button is tapped. If null and [showCloseButton] is true,
  /// tapping the close button will dismiss the dialog via [Navigator.maybePop].
  final VoidCallback? onClose;

  /// Whether to show the close button. Defaults to true.
  final bool showCloseButton;

  /// Optional widget shown between the title and the close button.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final resolvedAccent = accent ??
        LibraryAccentScope.accentOf(context, fallback: colorScheme.primary);
    const foreground = Colors.white;
    final effectiveOnClose = showCloseButton
        ? (onClose ?? () => Navigator.of(context).maybePop())
        : null;

    final header = LibraryPanelHeader(
      backgroundColor: Colors.transparent,
      minHeight: minHeight ?? 38,
      foregroundColor: foreground,
      borderColor: Colors.transparent,
      onClose: effectiveOnClose,
      trailing: trailing,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          ...[
            if (svgAsset != null)
              SvgPicture.asset(svgAsset!,
                  width: 20,
                  height: 20,
                  colorFilter:
                      const ColorFilter.mode(Colors.white, BlendMode.srcIn))
            else
              Icon(icon, size: 20, color: foreground),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: appPanelTitleStyle,
            ),
          ),
        ],
      ),
    );
    return AnimatedLibraryChrome(
      accent: resolvedAccent,
      child: header,
    );
  }
}
