import 'package:collectarr_app/features/library/workspace/library_pane_widths.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('clampLibraryPaneWidth keeps pane widths inside bounds', () {
    expect(
      clampLibraryPaneWidth(100, minWidth: 180, maxWidth: 360),
      180,
    );
    expect(
      clampLibraryPaneWidth(260, minWidth: 180, maxWidth: 360),
      260,
    );
    expect(
      clampLibraryPaneWidth(800, minWidth: 180, maxWidth: 360),
      360,
    );
  });

  test('maxLibraryPaneWidthForViewport caps by viewport fraction', () {
    expect(
      maxLibraryPaneWidthForViewport(
        viewportWidth: 900,
        preferredMaxWidth: 520,
        viewportFraction: 0.38,
      ),
      342,
    );
    expect(
      maxLibraryPaneWidthForViewport(
        viewportWidth: 2000,
        preferredMaxWidth: 520,
        viewportFraction: 0.38,
      ),
      520,
    );
  });
}
