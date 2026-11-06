import 'package:collectarr_app/features/library/workspace/tiles/cover_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late double shape;
  late ValueChanged<double> report;

  Widget coverShape(String url, {bool followsImage = true}) =>
      LibraryCoverShape(
        imageUrl: url,
        libraryEntryRef: null,
        fallbackAspectRatio: 0.7,
        followsImage: followsImage,
        builder: (context, aspectRatio, onAspectRatio) {
          shape = aspectRatio;
          report = onAspectRatio;
          return const SizedBox.shrink();
        },
      );

  testWidgets('a cover takes its image\'s shape', (tester) async {
    await tester.pumpWidget(coverShape('https://covers.test/wide'));
    expect(shape, 0.7);

    report(1.33);
    await tester.pump();
    expect(shape, 1.33);
  });

  testWidgets('another cover starts from its own shape', (tester) async {
    await tester.pumpWidget(coverShape('https://covers.test/first'));
    report(1.0);
    await tester.pump();

    await tester.pumpWidget(coverShape('https://covers.test/second'));
    expect(shape, 0.7);

    await tester.pumpWidget(coverShape('https://covers.test/first'));
    expect(shape, 1.0);
  });

  testWidgets('a cover in a fixed case keeps the fallback shape',
      (tester) async {
    await tester.pumpWidget(
        coverShape('https://covers.test/slabbed', followsImage: false));
    report(1.33);
    await tester.pump();
    expect(shape, 0.7);
  });
}
