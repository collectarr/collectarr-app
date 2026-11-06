import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Calls [onShake] when the phone is shaken, while [enabled].
class LibraryShakeToShuffle extends StatefulWidget {
  const LibraryShakeToShuffle({
    super.key,
    required this.enabled,
    required this.onShake,
    required this.child,
  });

  final bool enabled;
  final VoidCallback onShake;
  final Widget child;

  @override
  State<LibraryShakeToShuffle> createState() => _LibraryShakeToShuffleState();
}

class _LibraryShakeToShuffleState extends State<LibraryShakeToShuffle> {
  final _detector = LibraryShakeDetector();
  StreamSubscription<AccelerometerEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(LibraryShakeToShuffle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) _sync();
  }

  void _sync() {
    final listen =
        widget.enabled && !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    if (!listen) {
      _subscription?.cancel();
      _subscription = null;
      return;
    }
    _subscription ??=
        accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval)
            .listen(_onEvent, onError: (Object _) {}, cancelOnError: true);
  }

  void _onEvent(AccelerometerEvent event) {
    final shaken = _detector.add(
      DateTime.now(),
      math.sqrt(event.x * event.x + event.y * event.y + event.z * event.z),
    );
    if (shaken) {
      unawaited(HapticFeedback.mediumImpact());
      widget.onShake();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Recognizes a shake as most of a short window of samples being well above
/// gravity, then waits before recognizing another.
class LibraryShakeDetector {
  static const _strongAcceleration = 13.0;
  static const _window = Duration(milliseconds: 500);
  static const _minimumSpan = Duration(milliseconds: 250);
  static const _cooldown = Duration(seconds: 2);

  final _samples = <(DateTime, bool)>[];
  DateTime? _lastShake;

  /// Adds a sample of [acceleration] in m/s² and returns whether it completes
  /// a shake.
  bool add(DateTime time, double acceleration) {
    final last = _lastShake;
    if (last != null && time.difference(last) < _cooldown) return false;
    _samples
      ..add((time, acceleration > _strongAcceleration))
      ..removeWhere((sample) => time.difference(sample.$1) > _window);
    if (time.difference(_samples.first.$1) < _minimumSpan) return false;
    final strong = _samples.where((sample) => sample.$2).length;
    if (strong * 4 < _samples.length * 3) return false;
    _samples.clear();
    _lastShake = time;
    return true;
  }
}
