import 'package:flutter/material.dart';

class LibraryResizableDivider extends StatelessWidget {
  const LibraryResizableDivider({
    super.key,
    required this.onDragDelta,
    this.axis = Axis.horizontal,
    this.color,
    this.onDragStart,
    this.onDragEnd,
  });

  final ValueChanged<double> onDragDelta;
  final Axis axis;
  final Color? color;
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;

  @override
  Widget build(BuildContext context) {
    final dividerColor = color ?? Theme.of(context).dividerColor;
    final gripColor = dividerColor.withValues(alpha: 0.75);
    final isHorizontalResize = axis == Axis.horizontal;
    return MouseRegion(
      cursor: isHorizontalResize
          ? SystemMouseCursors.resizeColumn
          : SystemMouseCursors.resizeRow,
      child: Semantics(
        label: 'Resize panel',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart:
              isHorizontalResize ? (_) => onDragStart?.call() : null,
          onHorizontalDragEnd:
              isHorizontalResize ? (_) => onDragEnd?.call() : null,
          onHorizontalDragUpdate: isHorizontalResize
              ? (details) => onDragDelta(details.delta.dx)
              : null,
          onVerticalDragStart:
              isHorizontalResize ? null : (_) => onDragStart?.call(),
          onVerticalDragEnd:
              isHorizontalResize ? null : (_) => onDragEnd?.call(),
          onVerticalDragUpdate: isHorizontalResize
              ? null
              : (details) => onDragDelta(details.delta.dy),
          child: SizedBox(
            width: isHorizontalResize ? 12 : double.infinity,
            height: isHorizontalResize ? double.infinity : 12,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: isHorizontalResize ? 1 : double.infinity,
                  height: isHorizontalResize ? double.infinity : 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: dividerColor),
                  ),
                ),
                Container(
                  width: isHorizontalResize ? 7 : null,
                  height: isHorizontalResize ? null : 7,
                  padding: isHorizontalResize
                      ? const EdgeInsets.symmetric(vertical: 5)
                      : const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(999),
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
