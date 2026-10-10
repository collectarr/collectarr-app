import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_tokens.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_pane_widths.dart';
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
    final baseColor = widget.color ?? libraryWorkspacePaneDividerColor(context);
    final activeColor = widget.accentColor ?? theme.colorScheme.primary;
    final barColor = _dragging ? activeColor : baseColor;
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
            width:
                isHorizontalResize ? kLibraryPaneDividerWidth : double.infinity,
            height:
                isHorizontalResize ? double.infinity : kLibraryPaneDividerWidth,
            child: ColoredBox(
              color: barColor,
              child: Center(
                child: SizedBox(
                  width: isHorizontalResize ? 2 : 34,
                  height: isHorizontalResize ? 34 : 2,
                  child: CustomPaint(
                    painter: _LibraryPaneGripPainter(
                      axis: widget.axis,
                      color: appContrastingTextColor(barColor),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Five 2 px marks spaced 6 px apart, matching the CLZ panel dragger.
class _LibraryPaneGripPainter extends CustomPainter {
  const _LibraryPaneGripPainter({required this.axis, required this.color});

  final Axis axis;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (var index = 0; index < 5; index++) {
      final offset = 4.0 + index * 6;
      canvas.drawRect(
        axis == Axis.horizontal
            ? Rect.fromLTWH(0, offset, 2, 2)
            : Rect.fromLTWH(offset, 0, 2, 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_LibraryPaneGripPainter oldDelegate) =>
      axis != oldDelegate.axis || color != oldDelegate.color;
}
