import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// A decorated surface wrapper with resize handles on right and bottom edges.
class LibraryResizableSurface extends StatelessWidget {
  const LibraryResizableSurface({
    super.key,
    required this.child,
    this.accent,
    this.onResizeWidth,
    this.onResizeHeight,
    this.enableHorizontal = true,
    this.enableVertical = true,
    this.handleThickness = 6.0,
    this.showBorder = true,
    this.showShadow = true,
    this.backgroundColor,
  });

  final Widget child;
  final Color? accent;
  final ValueChanged<double>? onResizeWidth;
  final ValueChanged<double>? onResizeHeight;
  final bool enableHorizontal;
  final bool enableVertical;
  final double handleThickness;
  final bool showBorder;
  final bool showShadow;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final canResizeH = enableHorizontal && onResizeWidth != null;
    final canResizeV = enableVertical && onResizeHeight != null;

    return Stack(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor ?? palette.panel,
            border: showBorder ? Border.all(color: palette.divider) : null,
            boxShadow: showShadow
                ? const [
                    BoxShadow(
                      color: Color(0xCC000000),
                      blurRadius: 22,
                      offset: Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: child,
        ),
        // Right edge resize handle
        if (canResizeH)
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragUpdate: (d) => onResizeWidth!(d.delta.dx * 2),
                child: SizedBox(width: handleThickness),
              ),
            ),
          ),
        // Bottom edge resize handle
        if (canResizeV)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeRow,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragUpdate: (d) => onResizeHeight!(d.delta.dy * 2),
                child: SizedBox(height: handleThickness),
              ),
            ),
          ),
        // Bottom-right corner resize handle
        if (canResizeH && canResizeV)
          Positioned(
            right: 0,
            bottom: 0,
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeDownRight,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (d) {
                  onResizeWidth!(d.delta.dx * 2);
                  onResizeHeight!(d.delta.dy * 2);
                },
                child: SizedBox(
                  width: handleThickness * 2,
                  height: handleThickness * 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
