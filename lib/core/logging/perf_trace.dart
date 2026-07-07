import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Lightweight performance tracing helper.
///
/// Wraps hot synchronous code paths so we can (a) see them on the DevTools
/// timeline via [developer.Timeline] and (b) get a console line via
/// [debugPrint] (which reliably reaches the `flutter run` console, unlike
/// `developer.log` on desktop). Effectively zero-cost in release: console
/// logging is gated on debug/profile and `Timeline.timeSync` is a no-op when
/// the timeline is not recording.
abstract final class PerfTrace {
  /// Console logging is only emitted in debug/profile builds.
  static bool get _loggingEnabled => kDebugMode || kProfileMode;

  /// Operations slower than this are logged to the console. Set to
  /// [Duration.zero] to log every traced op (useful while diagnosing).
  static Duration logThreshold = Duration.zero;

  static void _emit(String line) {
    // debugPrint reaches the `flutter run` console on all platforms; also emit
    // to the VM service log for DevTools' Logging view.
    debugPrint('[perf] $line');
    developer.log(line, name: 'collectarr.perf');
  }

  /// Times a synchronous [body], emitting a DevTools timeline slice named
  /// [name] and a console line. Returns the body's result.
  static T sync<T>(
    String name,
    T Function() body, {
    Map<String, Object?> Function()? arguments,
  }) {
    if (!_loggingEnabled) {
      return developer.Timeline.timeSync(name, body);
    }
    final stopwatch = Stopwatch()..start();
    final result = developer.Timeline.timeSync(
      name,
      body,
      arguments: arguments?.call(),
    );
    stopwatch.stop();
    if (stopwatch.elapsed >= logThreshold) {
      final extra = arguments == null ? '' : ' ${arguments()}';
      _emit('$name took ${stopwatch.elapsedMicroseconds / 1000}ms$extra');
    }
    return result;
  }

  /// Logs a labelled duration measured elsewhere (e.g. a switch stopwatch),
  /// unconditionally in debug/profile. Use for coarse end-to-end timings.
  static void report(
    String name,
    Duration elapsed, {
    Map<String, Object?>? arguments,
  }) {
    if (!_loggingEnabled) {
      return;
    }
    final extra = arguments == null ? '' : ' $arguments';
    _emit('$name: ${elapsed.inMicroseconds / 1000}ms$extra');
  }
}

