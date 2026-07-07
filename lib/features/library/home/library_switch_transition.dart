import 'dart:async';

import 'package:flutter/material.dart';

class LibrarySwitchTransition extends StatefulWidget {
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
  State<LibrarySwitchTransition> createState() =>
      _LibrarySwitchTransitionState();
}

class _LibrarySwitchTransitionState extends State<LibrarySwitchTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scrimOpacity;
  Duration _pulseDuration = Duration.zero;
  int _switchToken = 0;
  Timer? _resetTimer;

  @override
  void initState() {
    super.initState();
    _pulseDuration = Duration(
      milliseconds: (widget.duration.inMilliseconds / 2).round().clamp(1, 250),
    );
    _controller = AnimationController(vsync: this, duration: _pulseDuration);
    _scrimOpacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void didUpdateWidget(covariant LibrarySwitchTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextPulseDuration = Duration(
      milliseconds: (widget.duration.inMilliseconds / 2).round().clamp(1, 250),
    );
    if (oldWidget.duration != widget.duration) {
      _pulseDuration = nextPulseDuration;
      _controller.duration = nextPulseDuration;
    }
    if (!widget.enabled || widget.duration == Duration.zero) {
      _resetTimer?.cancel();
      _controller.value = 0;
      return;
    }
    if (oldWidget.child.key != widget.child.key) {
      _startOverlayPulse();
    }
  }

  void _startOverlayPulse() {
    _resetTimer?.cancel();
    final token = ++_switchToken;
    _controller
      ..stop()
      ..value = 0
      ..forward();
    _resetTimer = Timer(_pulseDuration, () {
      if (!mounted || token != _switchToken) {
        return;
      }
      _controller.reverse();
    });
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || widget.duration == Duration.zero) {
      return widget.child;
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _scrimOpacity,
            builder: (context, _) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.transparent,
                      Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.08 * _scrimOpacity.value),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
