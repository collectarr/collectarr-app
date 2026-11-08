import 'package:collectarr_app/features/library/generic/workspace.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  double width(double coverSize, {double maxWidth = 244}) =>
      libraryCardWidthForCoverSize(
        coverSize: coverSize,
        minCoverSize: 96,
        maxCoverSize: 276,
        minWidth: 150,
        maxWidth: maxWidth,
      );

  test('card width spans its range across the whole cover size slider', () {
    expect(width(96), 150);
    expect(width(186), 197);
    expect(width(276), 244);
  });

  test('every slider step changes the card, even near its ends', () {
    expect(width(97), greaterThan(width(96)));
    expect(width(276), greaterThan(width(275)));
  });

  test('a scaled maximum never takes the card below its minimum', () {
    expect(width(276, maxWidth: 100), 150);
  });
}
