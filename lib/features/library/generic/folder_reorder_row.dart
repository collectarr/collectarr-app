import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The same lift is used on hover and while dragging, without Material elevation.
class LibraryFolderReorderRow extends StatefulWidget {
  const LibraryFolderReorderRow({
    super.key,
    required this.child,
    required this.color,
    required this.borderColor,
    required this.hoverColor,
    this.selectedField = false,
    this.height,
    this.minHeight = 0,
    this.padding = EdgeInsets.zero,
    this.bottomSpacing = 4,
  });

  final Widget child;
  final Color color;
  final Color borderColor;
  final Color hoverColor;
  final bool selectedField;
  final double? height;
  final double minHeight;
  final EdgeInsets padding;
  final double bottomSpacing;

  static Widget dragProxy(
    Widget child,
    int index,
    Animation<double> animation,
  ) =>
      Builder(
        builder: (context) => Material(
          type: MaterialType.transparency,
          textStyle: DefaultTextStyle.of(context).style,
          child: _FolderDragFeedback(child: child),
        ),
      );

  @override
  State<LibraryFolderReorderRow> createState() =>
      _LibraryFolderReorderRowState();
}

class _LibraryFolderReorderRowState extends State<LibraryFolderReorderRow> {
  var _hovered = false;

  @override
  Widget build(BuildContext context) {
    final dragging =
        context.dependOnInheritedWidgetOfExactType<_FolderDragFeedback>() !=
            null;
    final lifted = _hovered || dragging;
    final scale = lifted ? (widget.selectedField ? 1.025 : 1.015) : 1.0;
    final angle =
        lifted ? (widget.selectedField ? 1.0 : 0.5) * math.pi / 180 : 0.0;
    return MouseRegion(
      cursor: dragging ? SystemMouseCursors.grabbing : SystemMouseCursors.grab,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Padding(
        padding: EdgeInsets.only(bottom: widget.bottomSpacing),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.linear,
          transformAlignment: Alignment.center,
          transform: Matrix4.rotationZ(angle)
            ..scaleByDouble(scale, scale, 1, 1),
          height: widget.height,
          constraints: BoxConstraints(minHeight: widget.minHeight),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: lifted ? widget.hoverColor : widget.color,
            border: Border.all(color: widget.borderColor),
            borderRadius: BorderRadius.circular(4),
            boxShadow: lifted
                ? [
                    BoxShadow(
                        color: widget.borderColor, offset: const Offset(2, 2))
                  ]
                : const [],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class _FolderDragFeedback extends InheritedWidget {
  const _FolderDragFeedback({required super.child});

  @override
  bool updateShouldNotify(_FolderDragFeedback oldWidget) => false;
}
