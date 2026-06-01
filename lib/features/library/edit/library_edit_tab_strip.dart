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
    this.tabController,
    this.allowReorder = false,
    this.onReorderItem,
  });

  final Color accent;
  final List<Widget> tabs;
  final TabController? tabController;
  final bool allowReorder;
  final void Function(int oldIndex, int newIndex)? onReorderItem;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final controller = tabController ?? DefaultTabController.of(context);
    return LibraryEditTabStripFrame(
      child: Row(
        children: [
          _TabScrollArrow(
            icon: Icons.chevron_left,
            onTap: () {
              if (controller.index > 0) {
                controller.animateTo(controller.index - 1);
              }
            },
          ),
          Expanded(
            child: allowReorder && onReorderItem != null
                ? AnimatedBuilder(
                    animation: controller,
                    builder: (context, _) {
                      return SizedBox(
                        height: kLibraryEditTabStripHeight,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (var i = 0; i < tabs.length; i++)
                                DragTarget<int>(
                                  onAcceptWithDetails: (details) {
                                    final from = details.data;
                                    if (from != i) {
                                      onReorderItem!(from, i);
                                    }
                                  },
                                  builder: (context, candidateData, _) {
                                    return LongPressDraggable<int>(
                                      data: i,
                                      axis: Axis.horizontal,
                                      feedback: Material(
                                        elevation: 4,
                                        color: Colors.transparent,
                                        child: LibraryEditDraggedTabLabel(
                                          tab: tabs[i],
                                          accent: accent,
                                        ),
                                      ),
                                      childWhenDragging: Opacity(
                                        opacity: 0.3,
                                        child: LibraryEditDraggedTabLabel(
                                          tab: tabs[i],
                                          accent: accent,
                                          muted: true,
                                        ),
                                      ),
                                      child: GestureDetector(
                                        onTap: () => controller.animateTo(i),
                                        child: LibraryEditStyledTabLabel(
                                          tab: tabs[i],
                                          accent: accent,
                                          selected: controller.index == i,
                                          highlighted: candidateData.isNotEmpty,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : TabBar(
                    controller: controller,
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
                    overlayColor:
                        const WidgetStatePropertyAll(Colors.transparent),
                    splashBorderRadius: BorderRadius.zero,
                    tabs: tabs,
                  ),
          ),
          _TabScrollArrow(
            icon: Icons.chevron_right,
            onTap: () {
              if (controller.index < controller.length - 1) {
                controller.animateTo(controller.index + 1);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _TabScrollArrow extends StatelessWidget {
  const _TabScrollArrow({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Icon(icon, size: 20, color: appPalette(context).textMuted),
      ),
    );
  }
}
