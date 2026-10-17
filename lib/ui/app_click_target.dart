import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Click target that fires the moment the primary button is pressed on it,
/// before any gesture arena resolves, so later pointer movement or competing
/// gestures cannot cancel it.
class AppClickTarget extends StatefulWidget {
  const AppClickTarget(
      {super.key,
      required this.onClick,
      required this.builder,
      this.cursor = SystemMouseCursors.click});

  final VoidCallback? onClick;

  /// Builds the target; `hovered` is true while an enabled target is hovered.
  final Widget Function(BuildContext context, bool hovered) builder;
  final MouseCursor cursor;

  @override
  State<AppClickTarget> createState() => _AppClickTargetState();
}

class _AppClickTargetState extends State<AppClickTarget> {
  bool _hovered = false;

  void _setHovered(bool value) {
    if (_hovered != value) setState(() => _hovered = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onClick != null;
    return MouseRegion(
      cursor: enabled ? widget.cursor : MouseCursor.defer,
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: enabled
            ? (event) {
                if (event.buttons == kPrimaryButton) widget.onClick?.call();
              }
            : null,
        child: widget.builder(context, enabled && _hovered),
      ),
    );
  }
}
