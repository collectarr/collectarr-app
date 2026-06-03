import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LibraryCtrlScrollZoom extends StatelessWidget {
  const LibraryCtrlScrollZoom({
    super.key,
    required this.viewMode,
    required this.coverSize,
    required this.minCoverSize,
    required this.maxCoverSize,
    required this.onCoverSizeChanged,
    required this.child,
  });

  final LibraryViewMode viewMode;
  final double coverSize;
  final double minCoverSize;
  final double maxCoverSize;
  final ValueChanged<double> onCoverSizeChanged;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerSignal: _handlePointerSignal,
      child: child,
    );
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent ||
        !viewMode.supportsCoverSize ||
        !isLibraryZoomModifierPressed()) {
      return;
    }
    GestureBinding.instance.pointerSignalResolver.register(event, (_) {
      final next = zoomedLibraryCoverSize(
        current: coverSize,
        scrollDeltaY: event.scrollDelta.dy,
        min: minCoverSize,
        max: maxCoverSize,
      );
      if (next != coverSize) {
        onCoverSizeChanged(next);
      }
    });
  }
}

bool isLibraryZoomModifierPressed() {
  final keyboard = HardwareKeyboard.instance;
  return keyboard.isControlPressed || keyboard.isMetaPressed;
}

double zoomedLibraryCoverSize({
  required double current,
  required double scrollDeltaY,
  required double min,
  required double max,
}) {
  if (scrollDeltaY == 0 || min >= max) {
    return current.clamp(min, max).toDouble();
  }
  final step = ((max - min) / 8).clamp(6.0, 16.0).toDouble();
  final direction = scrollDeltaY < 0 ? 1 : -1;
  return (current + (step * direction)).clamp(min, max).toDouble();
}
