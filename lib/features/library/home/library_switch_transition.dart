import 'package:flutter/material.dart';

class LibrarySwitchTransition extends StatelessWidget {
  const LibrarySwitchTransition({
    super.key,
    required this.child,
    required this.duration,
    this.enabled = true,
  });

  final Widget child;
  final Duration duration;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled || duration == Duration.zero) {
      return child;
    }
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          fit: StackFit.expand,
          children: [
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      transitionBuilder: (child, animation) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );
        final slide = Tween<Offset>(
          begin: const Offset(0.015, 0.01),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: slide,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.99, end: 1).animate(animation),
              child: child,
            ),
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(child.key ?? child.runtimeType),
        child: child,
      ),
    );
  }
}
