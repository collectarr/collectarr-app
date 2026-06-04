import 'package:flutter/material.dart';

enum LibraryResizableDividerStyle {
  classic,
  clzDragger,
}

class LibraryResizableDivider extends StatelessWidget {
  const LibraryResizableDivider({
    super.key,
    required this.onDragDelta,
    this.axis = Axis.horizontal,
    this.color,
    this.style = LibraryResizableDividerStyle.classic,
  });

  final ValueChanged<double> onDragDelta;
  final Axis axis;
  final Color? color;
  final LibraryResizableDividerStyle style;

  @override
  Widget build(BuildContext context) {
    final dividerColor = color ?? Theme.of(context).dividerColor;
    final gripColor = dividerColor.withValues(alpha: 0.75);
    final isHorizontalResize = axis == Axis.horizontal;
    final useClzDraggerStyle = style == LibraryResizableDividerStyle.clzDragger;
    final draggerThickness = useClzDraggerStyle ? 6.0 : 12.0;
    return MouseRegion(
      cursor: isHorizontalResize
          ? SystemMouseCursors.resizeColumn
          : SystemMouseCursors.resizeRow,
      child: Semantics(
        label: 'Resize panel',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: isHorizontalResize
              ? (details) => onDragDelta(details.delta.dx)
              : null,
          onVerticalDragUpdate: isHorizontalResize
              ? null
              : (details) => onDragDelta(details.delta.dy),
          child: SizedBox(
            width: isHorizontalResize ? draggerThickness : double.infinity,
            height: isHorizontalResize ? double.infinity : draggerThickness,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              color: useClzDraggerStyle ? const Color(0xFF262626) : null,
              child: useClzDraggerStyle
                  ? null
                  : Stack(
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
      ),
    );
  }
}
