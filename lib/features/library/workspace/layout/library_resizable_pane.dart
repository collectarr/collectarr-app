import 'package:flutter/material.dart';

class LibraryResizableDivider extends StatefulWidget {
  const LibraryResizableDivider({
    super.key,
    required this.onDragDelta,
    this.axis = Axis.horizontal,
    this.color,
    this.useCumulativeDelta = false,
  });

  final ValueChanged<double> onDragDelta;
  final Axis axis;
  final Color? color;
  final bool useCumulativeDelta;

  @override
  State<LibraryResizableDivider> createState() =>
      _LibraryResizableDividerState();
}

class _LibraryResizableDividerState extends State<LibraryResizableDivider> {
  double _cumulativeDelta = 0;

  void _resetDrag() {
    _cumulativeDelta = 0;
  }

  void _emitDelta(double delta) {
    if (!widget.useCumulativeDelta) {
      widget.onDragDelta(delta);
      return;
    }
    _cumulativeDelta += delta;
    widget.onDragDelta(_cumulativeDelta);
  }

  @override
  Widget build(BuildContext context) {
    final dividerColor = widget.color ?? Theme.of(context).dividerColor;
    final gripColor = dividerColor.withValues(alpha: 0.75);
    final isHorizontalResize = widget.axis == Axis.horizontal;
    return MouseRegion(
      cursor: isHorizontalResize
          ? SystemMouseCursors.resizeColumn
          : SystemMouseCursors.resizeRow,
      child: Semantics(
        label: 'Resize panel',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart:
              isHorizontalResize ? (_) => _resetDrag() : null,
          onHorizontalDragUpdate: isHorizontalResize
              ? (details) => _emitDelta(details.delta.dx)
              : null,
          onHorizontalDragEnd: isHorizontalResize ? (_) => _resetDrag() : null,
          onHorizontalDragCancel: isHorizontalResize ? _resetDrag : null,
          onVerticalDragStart: isHorizontalResize ? null : (_) => _resetDrag(),
          onVerticalDragUpdate: isHorizontalResize
              ? null
              : (details) => _emitDelta(details.delta.dy),
          onVerticalDragEnd: isHorizontalResize ? null : (_) => _resetDrag(),
          onVerticalDragCancel: isHorizontalResize ? null : _resetDrag,
          child: SizedBox(
            width: isHorizontalResize ? 12 : double.infinity,
            height: isHorizontalResize ? double.infinity : 12,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
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
      ),
    );
  }
}
