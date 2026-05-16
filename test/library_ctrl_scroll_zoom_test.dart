import 'package:collectarr_app/features/library/workspace/library_ctrl_scroll_zoom.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('zoomedLibraryCoverSize grows on upward Ctrl-scroll and clamps', () {
    expect(
      zoomedLibraryCoverSize(
        current: 128,
        scrollDeltaY: -120,
        min: 104,
        max: 188,
      ),
      greaterThan(128),
    );

    expect(
      zoomedLibraryCoverSize(
        current: 188,
        scrollDeltaY: -120,
        min: 104,
        max: 188,
      ),
      188,
    );
  });

  test('zoomedLibraryCoverSize shrinks on downward Ctrl-scroll and clamps', () {
    expect(
      zoomedLibraryCoverSize(
        current: 128,
        scrollDeltaY: 120,
        min: 104,
        max: 188,
      ),
      lessThan(128),
    );

    expect(
      zoomedLibraryCoverSize(
        current: 104,
        scrollDeltaY: 120,
        min: 104,
        max: 188,
      ),
      104,
    );
  });
}
