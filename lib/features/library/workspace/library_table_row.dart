import 'package:flutter/material.dart';

class LibraryTableInkRow extends StatelessWidget {
  const LibraryTableInkRow({
    super.key,
    required this.selected,
    required this.odd,
    required this.onTap,
    this.onSecondaryTapUp,
    required this.child,
    required this.selectedColor,
    required this.oddColor,
    required this.evenColor,
    required this.selectionRailColor,
    required this.bottomBorderColor,
    required this.hoverColor,
    this.selectionRailWidth = 3,
    this.horizontalMargin = 8,
    this.verticalPadding = 2,
  });

  final bool selected;
  final bool odd;
  final VoidCallback onTap;
  final GestureTapUpCallback? onSecondaryTapUp;
  final Widget child;
  final Color selectedColor;
  final Color oddColor;
  final Color evenColor;
  final Color selectionRailColor;
  final Color bottomBorderColor;
  final Color hoverColor;
  final double selectionRailWidth;
  final double horizontalMargin;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        color: selected
            ? selectedColor
            : odd
                ? oddColor
                : evenColor,
        border: Border(
          left: BorderSide(
            color: selected ? selectionRailColor : Colors.transparent,
            width: selectionRailWidth,
          ),
          bottom: BorderSide(color: bottomBorderColor),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        onSecondaryTapUp: onSecondaryTapUp,
        hoverColor: hoverColor,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalMargin,
            verticalPadding,
            horizontalMargin - selectionRailWidth,
            verticalPadding,
          ),
          child: child,
        ),
      ),
    );
  }
}
