import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibraryAddChoiceMenu<T> extends StatelessWidget {
  const LibraryAddChoiceMenu({
    super.key,
    required this.tooltip,
    required this.width,
    required this.label,
    required this.values,
    required this.labelFor,
    required this.onSelected,
  });

  final String tooltip;
  final double width;
  final String label;
  final List<T> values;
  final String Function(T value) labelFor;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return PopupMenuButton<T>(
      tooltip: tooltip,
      popUpAnimationStyle: AnimationStyle.noAnimation,
      position: PopupMenuPosition.under,
      color: palette.isDark ? const Color(0xff444444) : palette.panelRaised,
      surfaceTintColor: Colors.transparent,
      menuPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: BorderSide(
            color: palette.isDark ? const Color(0xff666666) : palette.divider),
      ),
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final value in values)
          PopupMenuItem(
            value: value,
            height: 30,
            child: Text(labelFor(value),
                style: TextStyle(color: palette.textPrimary, fontSize: 14)),
          ),
      ],
      child: Container(
        width: width,
        height: 24,
        padding: const EdgeInsets.only(left: 6, right: 2),
        decoration: BoxDecoration(
          color: palette.isDark ? const Color(0xff383838) : palette.field,
          border: Border.all(color: const Color(0xff767676)),
        ),
        child: Row(children: [
          Expanded(
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: palette.textPrimary, fontSize: 14)),
          ),
          Icon(Icons.keyboard_arrow_down, size: 14, color: palette.textPrimary),
        ]),
      ),
    );
  }
}
