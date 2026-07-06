import 'package:collectarr_app/features/library/ui/library_chrome_tokens.dart';
import 'package:collectarr_app/features/library/ui/library_panel_chrome.dart';
import 'package:collectarr_app/features/library/ui/library_panel_header.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibraryDialogScaffold extends StatelessWidget {
  const LibraryDialogScaffold({
    super.key,
    required this.title,
    this.accent,
    this.footer,
    this.onClose,
    this.maxWidth = 420,
    this.maxHeight = 560,
    this.padding = const EdgeInsets.all(12),
    this.density = LibraryDensity.comfortable,
    required this.child,
  });

  final Widget title;
  final Widget child;
  final Color? accent;
  final Widget? footer;
  final VoidCallback? onClose;
  final double maxWidth;
  final double maxHeight;
  final EdgeInsets padding;
  final LibraryDensity density;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final resolvedAccent = accent ?? LibraryAccentScope.accentOf(context);
    return Dialog(
      backgroundColor: palette.panel,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: LibraryPanelChrome(
        header: LibraryPanelHeader(
          backgroundColor: resolvedAccent,
          foregroundColor: Colors.white,
          borderColor: resolvedAccent.withValues(alpha: 0.92),
          onClose: onClose,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          density: density,
          child: title,
        ),
        body: Padding(
          padding: padding,
          child: child,
        ),
        footer: footer,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        backgroundColor: palette.panel,
        density: density,
      ),
    );
  }
}
