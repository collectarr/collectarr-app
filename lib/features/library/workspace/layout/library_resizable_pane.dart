import 'package:flutter/material.dart';

class LibraryResizableDivider extends StatefulWidget {
  const LibraryResizableDivider({
    super.key,
    required this.onDragDelta,
    this.axis = Axis.horizontal,
    this.color,
    this.accentColor,
    this.onDragStart,
    this.onDragEnd,
  });

  final ValueChanged<double> onDragDelta;
  final Axis axis;
  final Color? color;
  final Color? accentColor;
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;

  @override
  State<LibraryResizableDivider> createState() =>
      _LibraryResizableDividerState();
}

class _LibraryResizableDividerState extends State<LibraryResizableDivider> {
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHorizontalResize = widget.axis == Axis.horizontal;
    final baseColor = widget.color ??
        (theme.brightness == Brightness.dark
            ? Colors.black.withValues(alpha: 0.92)
            : Colors.white.withValues(alpha: 0.96));
    final activeColor = widget.accentColor ?? theme.colorScheme.primary;
    final barColor = _dragging ? activeColor : baseColor;
    final gripColor =
        ThemeData.estimateBrightnessForColor(barColor) == Brightness.dark
            ? Colors.white.withValues(alpha: 0.96)
            : Colors.black.withValues(alpha: 0.78);
    final borderColor =
        ThemeData.estimateBrightnessForColor(barColor) == Brightness.dark
            ? Colors.white.withValues(alpha: 0.18)
            : Colors.black.withValues(alpha: 0.15);
    return MouseRegion(
      cursor: isHorizontalResize
          ? SystemMouseCursors.resizeColumn
          : SystemMouseCursors.resizeRow,
      child: Semantics(
        label: 'Resize panel',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: isHorizontalResize
              ? (_) {
                  if (!_dragging) {
                    setState(() => _dragging = true);
                  }
                  widget.onDragStart?.call();
                }
              : null,
          onHorizontalDragEnd: isHorizontalResize
              ? (_) {
                  if (_dragging) {
                    setState(() => _dragging = false);
                  }
                  widget.onDragEnd?.call();
                }
              : null,
          onHorizontalDragUpdate: isHorizontalResize
              ? (details) => widget.onDragDelta(details.delta.dx)
              : null,
          onVerticalDragStart: isHorizontalResize
              ? null
              : (_) {
                  if (!_dragging) {
                    setState(() => _dragging = true);
                  }
                  widget.onDragStart?.call();
                },
          onVerticalDragEnd: isHorizontalResize
              ? null
              : (_) {
                  if (_dragging) {
                    setState(() => _dragging = false);
                  }
                  widget.onDragEnd?.call();
                },
          onVerticalDragUpdate: isHorizontalResize
              ? null
              : (details) => widget.onDragDelta(details.delta.dy),
          onHorizontalDragCancel: isHorizontalResize
              ? () {
                  if (_dragging) {
                    setState(() => _dragging = false);
                  }
                  widget.onDragEnd?.call();
                }
              : null,
          onVerticalDragCancel: isHorizontalResize
              ? null
              : () {
                  if (_dragging) {
                    setState(() => _dragging = false);
                  }
                  widget.onDragEnd?.call();
                },
          child: SizedBox(
            width: isHorizontalResize ? 14 : double.infinity,
            height: isHorizontalResize ? double.infinity : 14,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: isHorizontalResize ? 2 : double.infinity,
                  height: isHorizontalResize ? double.infinity : 2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: barColor),
                  ),
                ),
                Container(
                  width: isHorizontalResize ? 9 : null,
                  height: isHorizontalResize ? null : 9,
                  padding: isHorizontalResize
                      ? const EdgeInsets.symmetric(vertical: 5)
                      : const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: borderColor),
                  ),
                  child: isHorizontalResize
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var index = 0; index < 3; index++) ...[
                              Container(
                                width: 3,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: gripColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              if (index < 2) const SizedBox(height: 3),
                            ],
                          ],
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var index = 0; index < 3; index++) ...[
                              Container(
                                width: 3,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: gripColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              if (index < 2) const SizedBox(width: 3),
                            ],
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
