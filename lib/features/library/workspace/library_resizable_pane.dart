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
    final gripColor = dividerColor.withValues(alpha: 0.75);
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (details) => onDragDelta(details.delta.dx),
        child: SizedBox(
          width: 12,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 1,
                height: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: dividerColor),
                ),
              ),
              Container(
                width: 8,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var index = 0; index < 4; index++) ...[
                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: gripColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (index < 3) const SizedBox(height: 3),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
