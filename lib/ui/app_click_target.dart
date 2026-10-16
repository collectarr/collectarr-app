import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// A tap that keeps tracking however far the pointer moves, so that, like a
/// browser click, it fires whenever the button is released over its target.
class _ClickGestureRecognizer extends TapGestureRecognizer {
  _ClickGestureRecognizer({super.debugOwner});

  @override
  double? get preAcceptSlopTolerance => null;

  @override
  double? get postAcceptSlopTolerance => null;
}

/// Click target with browser semantics: pressing, moving within the target and
/// releasing still clicks; releasing outside it cancels. Competing gestures,
/// such as a scroll, still win the arena.
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

  void _handleTapUp(TapUpDetails details) {
    final size = context.size;
    if (size != null && (Offset.zero & size).contains(details.localPosition)) {
      widget.onClick?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onClick != null;
    return MouseRegion(
      cursor: enabled ? widget.cursor : MouseCursor.defer,
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: RawGestureDetector(
        behavior: HitTestBehavior.opaque,
        gestures: {
          if (enabled)
            _ClickGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<_ClickGestureRecognizer>(
              () => _ClickGestureRecognizer(debugOwner: this),
              (recognizer) => recognizer.onTapUp = _handleTapUp,
            ),
        },
        child: widget.builder(context, enabled && _hovered),
      ),
    );
  }
}
