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
