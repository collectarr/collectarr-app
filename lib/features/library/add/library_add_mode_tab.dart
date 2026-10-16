import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Folder tab above the Add dialog's search field: #666 when active, #505050
/// otherwise, as in the reference.
class LibraryAddModeTab extends StatelessWidget {
  const LibraryAddModeTab({
    super.key,
    required this.icon,
    required this.onTap,
    this.label,
    this.tooltip,
    this.selected = false,
  });

  final Widget icon;
  final String? label;
  final String? tooltip;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final background = palette.isDark
        ? (selected ? const Color(0xff666666) : const Color(0xff505050))
        : (selected ? palette.panelRaised : palette.panel);
    final tab = Material(
      color: background,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      child: InkWell(
        mouseCursor: WidgetStateMouseCursor.clickable,
        onTap: onTap,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        child: Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconTheme.merge(
                data: IconThemeData(size: 14, color: palette.textPrimary),
                child: icon,
              ),
              if (label != null) ...[
                const SizedBox(width: 5),
                Text(
                  label!,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(right: 3),
      child: tooltip == null ? tab : Tooltip(message: tooltip, child: tab),
    );
  }
}
