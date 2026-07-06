import 'package:collectarr_app/features/library/ui/library_chrome_tokens.dart';
import 'package:collectarr_app/features/library/ui/library_panel_chrome.dart';
import 'package:collectarr_app/features/library/ui/library_panel_header.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibraryDialogScaffold extends StatelessWidget {
  const LibraryDialogScaffold({
    super.key,
    required this.title,
    required this.child,
    this.footer,
    this.onClose,
    this.maxWidth = 420,
    this.maxHeight = 560,
    this.padding = const EdgeInsets.all(12),
    this.density = LibraryDensity.comfortable,
  });

  final Widget title;
  final Widget child;
  final Widget? footer;
  final VoidCallback? onClose;
  final double maxWidth;
  final double maxHeight;
  final EdgeInsets padding;
  final LibraryDensity density;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Dialog(
      backgroundColor: palette.panel,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: LibraryPanelChrome(
        header: LibraryPanelHeader(
          backgroundColor: palette.panel,
          foregroundColor: palette.textPrimary,
          borderColor: palette.divider,
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
