import 'package:collectarr_app/ui/app_icons.dart';
import 'package:flutter/material.dart';

/// Arc icon turning once every two seconds, as the reference's spinning
/// loading glyph.
class AppSpinner extends StatefulWidget {
  const AppSpinner({super.key, required this.size, required this.color});
  final double size;
  final Color color;

  @override
  State<AppSpinner> createState() => _AppSpinnerState();
}

class _AppSpinnerState extends State<AppSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RotationTransition(
      turns: _controller,
      child: Icon(AppIcons.spinner, size: widget.size, color: widget.color));
}

/// The spinner over a large label, centred, as the reference shows in a pane
/// whose content is still loading ("Searching...", "Loading...").
class AppLoadingPlaceholder extends StatelessWidget {
  const AppLoadingPlaceholder({
    super.key,
    required this.label,
    required this.color,
    this.fontWeight = FontWeight.w900,
    this.spinnerHeight = 80,
    this.labelHeight = 40,
  });

  final String label;
  final Color color;
  final FontWeight fontWeight;
  final double spinnerHeight;
  final double labelHeight;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                  height: spinnerHeight,
                  child: Center(child: AppSpinner(size: 56, color: color))),
              Text(label,
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: fontWeight,
                      height: labelHeight / 28,
                      color: color)),
            ],
          ),
        ),
      );
}
