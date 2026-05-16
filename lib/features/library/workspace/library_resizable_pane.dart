import 'package:flutter/material.dart';

class LibraryResizableDivider extends StatelessWidget {
  const LibraryResizableDivider({
    super.key,
    required this.onDragDelta,
    this.color,
  });

  final ValueChanged<double> onDragDelta;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final dividerColor = color ?? Theme.of(context).dividerColor;
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (details) => onDragDelta(details.delta.dx),
        child: SizedBox(
          width: 8,
          child: Center(
            child: Container(
              width: 1,
              color: dividerColor,
            ),
          ),
        ),
      ),
    );
  }
}
