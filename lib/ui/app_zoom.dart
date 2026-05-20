import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wraps the app to enable ctrl+scroll zoom on Flutter Web.
/// On non-web platforms this is a no-op passthrough.
class AppZoomWrapper extends StatefulWidget {
  const AppZoomWrapper({super.key, required this.child});

  final Widget child;

  @override
  State<AppZoomWrapper> createState() => _AppZoomWrapperState();
}

class _AppZoomWrapperState extends State<AppZoomWrapper> {
  double _scale = 1.0;

  static const _minScale = 0.5;
  static const _maxScale = 2.0;
  static const _step = 0.05;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return widget.child;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerSignal: _handlePointerSignal,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(_scale),
        ),
        child: Transform.scale(
          scale: _scale,
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: MediaQuery.of(context).size.width / _scale,
            height: MediaQuery.of(context).size.height / _scale,
            child: widget.child,
          ),
        ),
      ),
    );
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    final keyboard = HardwareKeyboard.instance;
    if (!keyboard.isControlPressed && !keyboard.isMetaPressed) return;

    // Consume the event so it doesn't propagate to other scroll handlers
    GestureBinding.instance.pointerSignalResolver.register(event, (_) {
      final direction = event.scrollDelta.dy < 0 ? 1 : -1;
      setState(() {
        _scale = (_scale + direction * _step).clamp(_minScale, _maxScale);
      });
    });
  }
}
