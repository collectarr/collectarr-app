import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum LibraryDetailPanelVariant {
  sidePanel,
  fullPage,
}

class LibraryDetailPanelScaffold extends StatelessWidget {
  const LibraryDetailPanelScaffold({
    super.key,
    required this.typeLabel,
    required this.entryTitle,
    required this.accent,
    required this.hero,
    required this.sections,
    this.toolbar,
    this.variant = LibraryDetailPanelVariant.sidePanel,
  });

  final String typeLabel;
  final String entryTitle;
  final Color accent;
  final Widget hero;
  final List<Widget> sections;
  final Widget? toolbar;
  final LibraryDetailPanelVariant variant;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final padding = variant == LibraryDetailPanelVariant.fullPage
        ? const EdgeInsets.fromLTRB(12, 12, 12, 16)
        : const EdgeInsets.fromLTRB(8, 8, 8, 12);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panel,
        border: Border(
          left: BorderSide(color: accent.withValues(alpha: 0.22)),
        ),
      ),
      child: ListView(
        padding: padding,
        children: [
          if (toolbar != null) ...[
            toolbar!,
            const SizedBox(height: 8),
          ],
          hero,
          const SizedBox(height: 10),
          ...sections,
        ],
      ),
    );
  }
}
