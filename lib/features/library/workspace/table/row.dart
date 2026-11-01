import 'package:collectarr_app/features/library/ui/chrome_tokens.dart';
import 'package:collectarr_app/features/library/ui/density_scope.dart';
import 'package:collectarr_app/features/library/workspace/config/tokens.dart';
import 'package:collectarr_app/ui/app_press_tap.dart';
import 'package:flutter/material.dart';

class LibraryTableInkRow extends StatelessWidget {
  const LibraryTableInkRow({
    super.key,
    required this.selected,
    this.checked = false,
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
    this.density,
  });

  final bool selected;

  /// Ticked for a bulk action; drawn in [kLibraryCheckedItemBackground] unless
  /// the row is also the active one.
  final bool checked;
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
  final LibraryDensity? density;

  @override
  Widget build(BuildContext context) {
    final resolvedDensity = density ?? LibraryDensityScope.of(context);
    final densityMetrics = resolvedDensity.metrics;
    final resolvedHorizontalMargin =
        horizontalMargin * densityMetrics.tableHorizontalMarginScale;
    final resolvedVerticalPadding =
        verticalPadding * densityMetrics.tableVerticalPaddingScale;
    final baseColor = odd ? oddColor : evenColor;
    final fill = selected
        ? selectedColor
        : checked
            ? kLibraryCheckedItemBackground
            : null;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: fill ?? baseColor,
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
      child: AppPressTap(
          onTap: onTap,
          builder: (context, onReleaseTap) => Material(
                type: MaterialType.transparency,
                child: InkWell(
                  mouseCursor: WidgetStateMouseCursor.clickable,
                  onTap: onReleaseTap,
                  onDoubleTap: onDoubleTap,
                  onSecondaryTapUp: onSecondaryTapUp,
                  // A highlight keeps the alpha it appeared with, so turning
                  // it transparent on selection paints opaque black; a
                  // selected row repaints its own fill instead.
                  hoverColor: fill ?? hoverColor,
                  // Row hover changes instantly, as in the reference list.
                  hoverDuration: Duration.zero,
                  // A keyboard-focused row must not hide the selection fill.
                  focusColor: fill ?? hoverColor,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      resolvedHorizontalMargin,
                      resolvedVerticalPadding,
                      (resolvedHorizontalMargin - selectionRailWidth)
                          .clamp(0.0, double.infinity),
                      resolvedVerticalPadding,
                    ),
                    child: child,
                  ),
                ),
              )),
    );
  }
}
