import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// Wraps the application root to enable browser-like desktop & web UI zoom:
/// - `Ctrl` + `+` / `Ctrl` + `=` / `Ctrl` + `Numpad +`: Zoom in
/// - `Ctrl` + `-` / `Ctrl` + `Numpad -`: Zoom out
/// - `Ctrl` + `0` / `Ctrl` + `Numpad 0`: Reset zoom (100%)
/// - `Ctrl` + Mouse wheel scroll up: Zoom in
/// - `Ctrl` + Mouse wheel scroll down: Zoom out
class AppZoomWrapper extends StatefulWidget {
  const AppZoomWrapper({super.key, required this.child});

  final Widget child;

  @override
  State<AppZoomWrapper> createState() => _AppZoomWrapperState();
}

class _AppZoomWrapperState extends State<AppZoomWrapper> {
  double _scale = 1.0;
  bool _indicatorVisible = false;
  Timer? _indicatorTimer;

  static const _minScale = 0.50; // 50%
  static const _maxScale = 2.50; // 250%

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    _indicatorTimer?.cancel();
    super.dispose();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return false;
    final keyboard = HardwareKeyboard.instance;
    final isCtrl = keyboard.isControlPressed || keyboard.isMetaPressed;
    if (!isCtrl) return false;

    final key = event.logicalKey;
    final char = event.character;

    final isPlus = key == LogicalKeyboardKey.equal ||
        key == LogicalKeyboardKey.add ||
        key == LogicalKeyboardKey.numpadAdd ||
        char == '+' ||
        char == '=';

    final isMinus = key == LogicalKeyboardKey.minus ||
        key == LogicalKeyboardKey.numpadSubtract ||
        char == '-';

    final isReset = key == LogicalKeyboardKey.digit0 ||
        key == LogicalKeyboardKey.numpad0 ||
        char == '0';

    if (isPlus) {
      _adjustScale(0.10);
      return true;
    } else if (isMinus) {
      _adjustScale(-0.10);
      return true;
    } else if (isReset) {
      _resetScale();
      return true;
    }

    return false;
  }

  void _handleCtrlScroll(PointerSignalEvent event) {
    final zoomIn = switch (event) {
      PointerScrollEvent(:final scrollDelta) when scrollDelta.dy != 0 =>
        scrollDelta.dy < 0,
      PointerScaleEvent(:final scale) when scale != 1 => scale > 1,
      _ => null,
    };
    if (zoomIn == null) return;
    _adjustScale((zoomIn ? 1 : -1) * 0.05);
  }

  void _adjustScale(double delta) {
    final next = (_scale + delta).clamp(_minScale, _maxScale);
    final rounded = (next * 20).round() / 20; // Round to nearest 5%
    if ((rounded - _scale).abs() > 0.001) {
      setState(() {
        _scale = rounded;
        _showIndicator();
      });
    }
  }

  void _resetScale() {
    if ((_scale - 1.0).abs() > 0.001) {
      setState(() {
        _scale = 1.0;
        _showIndicator();
      });
    }
  }

  void _showIndicator() {
    _indicatorTimer?.cancel();
    setState(() => _indicatorVisible = true);
    _indicatorTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() => _indicatorVisible = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final scaledWidth = mq.size.width / _scale;
    final scaledHeight = mq.size.height / _scale;

    return _CtrlScrollCatcher(
      onCtrlScroll: _handleCtrlScroll,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          SizedBox(
            width: mq.size.width,
            height: mq.size.height,
            child: (_scale - 1.0).abs() < 0.001
                ? widget.child
                : FittedBox(
                    fit: BoxFit.fill,
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: scaledWidth,
                      height: scaledHeight,
                      child: MediaQuery(
                        data: mq.copyWith(
                          size: Size(scaledWidth, scaledHeight),
                        ),
                        child: widget.child,
                      ),
                    ),
                  ),
          ),
          Positioned(
            top: 48,
            right: 18,
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _indicatorVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 180),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xEE222222),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '${(_scale * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Claims Ctrl/⌘ + wheel for zooming wherever the pointer is.
///
/// Pointer signals go to the first handler registered with the resolver, and
/// handlers register in hit-test order, so nested scrollables would otherwise
/// take the wheel. This box enters the hit-test path ahead of its children.
///
/// Flutter Web reports Ctrl + wheel as a [PointerScaleEvent] and always
/// prevents the browser's own page zoom, so the scale signal zooms here too.
class _CtrlScrollCatcher extends SingleChildRenderObjectWidget {
  const _CtrlScrollCatcher({required this.onCtrlScroll, super.child});

  final ValueChanged<PointerSignalEvent> onCtrlScroll;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderCtrlScrollCatcher(onCtrlScroll);

  @override
  void updateRenderObject(
          BuildContext context, _RenderCtrlScrollCatcher renderObject) =>
      renderObject.onCtrlScroll = onCtrlScroll;
}

class _RenderCtrlScrollCatcher extends RenderProxyBox {
  _RenderCtrlScrollCatcher(this.onCtrlScroll);

  ValueChanged<PointerSignalEvent> onCtrlScroll;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!size.contains(position)) return false;
    result.add(BoxHitTestEntry(this, position));
    hitTestChildren(result, position: position);
    return true;
  }

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    if (event is PointerScrollEvent) {
      final keyboard = HardwareKeyboard.instance;
      if (!keyboard.isControlPressed && !keyboard.isMetaPressed) return;
    } else if (event is! PointerScaleEvent) {
      return;
    }
    GestureBinding.instance.pointerSignalResolver
        .register(event as PointerSignalEvent, (event) => onCtrlScroll(event));
  }
}
