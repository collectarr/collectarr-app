import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Screen sizes — use these instead of hard-coded Size(...) in tests.
// ---------------------------------------------------------------------------
const kDesktopTestSize = Size(1200, 1000);
const kDesktopHDTestSize = Size(1920, 1080);
const kMobileTestSize = Size(1170, 2532);

const kDesktopTestDPR = 1.0;
const kMobileTestDPR = 3.0;

// ---------------------------------------------------------------------------
// Pump helpers — settle without being blocked by repeating animations.
// ---------------------------------------------------------------------------

/// Pumps frames until either [timeout] elapses or the widget tree is idle,
/// whichever comes first.  Unlike [WidgetTester.pumpAndSettle], this never
/// throws if the timeout is reached — it simply stops pumping.
///
/// Use this in tests where background animations (shimmer, pulsing loaders)
/// run indefinitely and would cause [pumpAndSettle] to time out.
Future<void> pumpUntilSettled(
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 5),
  Duration interval = const Duration(milliseconds: 100),
}) async {
  final end = tester.binding.clock.now().add(timeout);
  do {
    await tester.pump(interval);
  } while (tester.binding.hasScheduledFrame &&
      tester.binding.clock.now().isBefore(end));
}
