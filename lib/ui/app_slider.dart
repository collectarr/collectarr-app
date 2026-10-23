import 'package:flutter/material.dart';

/// Keeps the value indicator under the same route and semantics boundary as
/// its slider, including while the route is entering, covered or leaving.
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
