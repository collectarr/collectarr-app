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
            child: ColoredBox(color: barColor),
          ),
        ),
      ),
    );
  }
}
