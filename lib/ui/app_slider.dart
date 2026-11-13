import 'package:flutter/material.dart';

/// Keeps the value indicator under the same route and semantics boundary as
/// its slider, including while the route is entering, covered or leaving.
///
/// A bare [Slider] in a pushed route sends its value indicator's semantics node
/// without a parent while the route animates in, which Windows rejects as an
/// invalid AXTree update ("will not be in the tree and is not the new root"):
/// https://github.com/flutter/flutter/issues/190357
///
/// Fixed by https://github.com/flutter/flutter/pull/193372, which is in
/// 3.51.0-0.1.pre but in no stable release yet (3.50.0 does not have it).
/// Once the Flutter release we use includes it, replace this widget with
/// [Slider] and delete this file.
///
/// Until then, do not put this widget inside a [Tooltip] or another
/// [OverlayPortal]'s child: its own overlay then lists the value indicator
/// under two semantics parents, which Windows also rejects
/// (https://github.com/flutter/flutter/issues/196503).
class AppSlider extends StatelessWidget {
  const AppSlider(
      {super.key,
      required this.value,
      required this.min,
      required this.max,
      required this.onChanged,
      this.divisions,
      this.label,
      this.mouseCursor});

  final double value;
  final double min;
  final double max;
  final ValueChanged<double>? onChanged;
  final int? divisions;
  final String? label;
  final MouseCursor? mouseCursor;

  @override
  Widget build(BuildContext context) => IgnoreBaseline(
          // Sliders have no text baseline. ListTile must not query the deferred
          // overlay child while measuring its subtitle.
          child: Overlay.wrap(
        alwaysSizeToContent: true,
        clipBehavior: Clip.none,
        child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
            divisions: divisions,
            label: label,
            mouseCursor: mouseCursor),
      ));
}
