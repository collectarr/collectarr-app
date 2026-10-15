import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// One tab of [AppPageTabs].
class AppPageTab {
  const AppPageTab({required this.label, this.icon});

  final String label;
  final IconData? icon;
}

/// Folder-style tabs that sit on top of a management panel: the active tab
/// takes the panel color, inactive tabs stay dark with dimmed text.
class AppPageTabs extends StatelessWidget {
  const AppPageTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<AppPageTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final inactive = palette.isDark ? const Color(0xFF131313) : palette.canvas;
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (var index = 0; index < tabs.length; index++)
          _tab(context, index, inactive),
      ],
    );
  }

  Widget _tab(BuildContext context, int index, Color inactive) {
    final tab = tabs[index];
    final selected = index == selectedIndex;
    final palette = appPalette(context);
    final foreground = selected
        ? palette.textPrimary
        : palette.textPrimary.withValues(alpha: .7);
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? appManagementPanelColor(context) : inactive,
        child: InkWell(
          mouseCursor: SystemMouseCursors.click,
          onTap: selected ? null : () => onSelected(index),
          child: SizedBox(
            height: 32,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                if (tab.icon != null) ...[
                  Icon(tab.icon, size: 14, color: foreground),
                  const SizedBox(width: 6),
                ],
                Text(tab.label,
                    style: TextStyle(
                        color: foreground,
                        fontSize: 14,
                        fontWeight: FontWeight.w400)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
