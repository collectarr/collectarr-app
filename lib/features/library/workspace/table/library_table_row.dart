import 'package:flutter/material.dart';

class LibraryTableInkRow extends StatelessWidget {
  const LibraryTableInkRow({
    super.key,
    required this.selected,
    required this.odd,
    required this.onTap,
    this.onDoubleTap,
    this.onSecondaryTapUp,
    required this.child,
    required this.selectedColor,
    required this.oddColor,
    required this.evenColor,
    required this.selectionRailColor,
    required this.bottomBorderColor,
    required this.hoverColor,
    this.selectionRailWidth = 2,
    this.horizontalMargin = 6,
    this.verticalPadding = 1,
  });

  final bool selected;
  final bool odd;
  final VoidCallback onTap;
  final VoidCallback? onDoubleTap;
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
    final baseColor = odd ? oddColor : evenColor;
    final resolvedSelectedColor = Color.alphaBlend(
      selectedColor.withValues(alpha: 0.52),
      baseColor,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? resolvedSelectedColor : baseColor,
        border: Border(
          left: BorderSide(
            color: selected ? selectionRailColor : Colors.transparent,
            width: selectionRailWidth,
          ),
          bottom: BorderSide(
            color: bottomBorderColor,
          ),
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          onDoubleTap: onDoubleTap,
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
      ),
    );
  }
}
