import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

const double kLibraryEditTabStripHeight = 38;
const double kLibraryEditTabStripContainerHeight = 39;

class LibraryEditTabStripFrame extends StatelessWidget {
  const LibraryEditTabStripFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Container(
      height: kLibraryEditTabStripContainerHeight,
      decoration: BoxDecoration(
        color: palette.panelRaised,
        border: Border(bottom: BorderSide(color: palette.divider)),
      ),
      child: child,
    );
  }
}

class LibraryEditStyledTabLabel extends StatelessWidget {
  const LibraryEditStyledTabLabel({
    super.key,
    required this.tab,
    required this.accent,
    required this.selected,
    required this.highlighted,
  });

  final Widget tab;
  final Color accent;
  final bool selected;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final foreground = selected ? palette.textPrimary : palette.textMuted;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: highlighted ? accent.withValues(alpha: 0.12) : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: selected ? accent : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      alignment: Alignment.center,
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: foreground,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 12,
        ),
        child: IconTheme.merge(
          data: IconThemeData(color: foreground, size: 16),
          child: tab,
        ),
      ),
    );
  }
}

class LibraryEditDraggedTabLabel extends StatelessWidget {
  const LibraryEditDraggedTabLabel({
    super.key,
    required this.tab,
    required this.accent,
    this.muted = false,
  });

  final Widget tab;
  final Color accent;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final foreground = muted ? palette.textMuted : palette.textPrimary;
    return Container(
      height: kLibraryEditTabStripHeight,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        child: IconTheme.merge(
          data: IconThemeData(color: foreground, size: 16),
          child: tab,
        ),
      ),
    );
  }
}

class LibraryEditMaterialTabBar extends StatelessWidget {
  const LibraryEditMaterialTabBar({
    super.key,
    required this.accent,
    required this.tabs,
  });

  final Color accent;
  final List<Widget> tabs;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return LibraryEditTabStripFrame(
      child: TabBar(
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorWeight: 2,
        indicatorColor: accent,
        dividerColor: Colors.transparent,
        labelColor: palette.textPrimary,
        unselectedLabelColor: palette.textMuted,
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 10),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        splashBorderRadius: BorderRadius.zero,
        tabs: tabs,
      ),
    );
  }
}