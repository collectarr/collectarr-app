import 'package:collectarr_app/features/library/workspace/mobile/shake_to_shuffle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final start = DateTime(2026);
  DateTime at(int milliseconds) =>
      start.add(Duration(milliseconds: milliseconds));

  test('a phone at rest is not shaken', () {
    final detector = LibraryShakeDetector();
    for (var time = 0; time < 2000; time += 20) {
      expect(detector.add(at(time), 9.8), isFalse);
    }
  });

  test('sustained strong acceleration is one shake until the cooldown ends',
      () {
    final detector = LibraryShakeDetector();
    final shakes = [
      for (var time = 0; time < 1000; time += 20)
        if (detector.add(at(time), 20)) time,
    ];
    expect(shakes, hasLength(1));
    expect(shakes.single, greaterThanOrEqualTo(250));
  });
}
