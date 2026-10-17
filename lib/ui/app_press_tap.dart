import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

final Set<int> _claimedPointers = <int>{};

/// Marks presses on a control nested inside an [AppPressTap] area as the
/// control's own, so the surrounding area neither selects on press nor taps on
/// release. Pointer-down events reach the deepest widget first.
class AppPressClaim extends StatelessWidget {
  const AppPressClaim({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Listener(
        onPointerDown: (event) => claimAppPress(event.pointer),
        onPointerUp: (event) => _claimedPointers.remove(event.pointer),
        onPointerCancel: (event) => _claimedPointers.remove(event.pointer),
        child: child,
      );
}

void claimAppPress(int pointer) => _claimedPointers.add(pointer);

/// Runs [onTap] the moment a mouse's primary button goes down, like selecting
/// a row in a desktop list, instead of waiting for the release. Touch and pen
/// taps still run it on release, through the `onTap` given to [builder].
class AppPressTap extends StatefulWidget {
  const AppPressTap({super.key, required this.onTap, required this.builder});

  final VoidCallback onTap;
  final Widget Function(BuildContext context, VoidCallback onReleaseTap)
      builder;

  @override
  State<AppPressTap> createState() => _AppPressTapState();
}

class _AppPressTapState extends State<AppPressTap> {
  bool _skipReleaseTap = false;

  void _handlePointerDown(PointerDownEvent event) {
    final claimed = _claimedPointers.remove(event.pointer);
    final pressesNow = !claimed &&
        event.kind == PointerDeviceKind.mouse &&
        event.buttons == kPrimaryButton;
    _skipReleaseTap = claimed || pressesNow;
    if (pressesNow) widget.onTap();
  }

  void _handleReleaseTap() {
    if (_skipReleaseTap) {
      _skipReleaseTap = false;
      return;
    }
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) => Listener(
        onPointerDown: _handlePointerDown,
        child: widget.builder(context, _handleReleaseTap),
      );
}
