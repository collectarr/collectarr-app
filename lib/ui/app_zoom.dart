import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    final keyboard = HardwareKeyboard.instance;
    if (!keyboard.isControlPressed && !keyboard.isMetaPressed) return;

    GestureBinding.instance.pointerSignalResolver.register(event, (_) {
      final direction = event.scrollDelta.dy < 0 ? 1 : -1;
      _adjustScale(direction * 0.05);
    });
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

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerSignal: _handlePointerSignal,
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
