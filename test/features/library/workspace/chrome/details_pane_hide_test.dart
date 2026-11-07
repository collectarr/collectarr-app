import 'package:collectarr_app/features/library/workspace/chrome/chrome.dart';
import 'package:collectarr_app/features/library/workspace/config/view_enums.dart';
import 'package:collectarr_app/features/library/workspace/layout/pane_widths.dart';
import 'package:collectarr_app/features/library/workspace/layout/resizable_pane.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<({List<double> widths, List<bool> hides})> pump(
      WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final widths = <double>[];
    final hides = <bool>[];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: LibraryDetailsAwareLayout(
          content: const SizedBox.expand(),
          inspector: const SizedBox.expand(),
          detailsLayout: LibraryDetailsLayout.right,
          rightWidth: 340,
          onRightWidthChanged: widths.add,
          onHide: () => hides.add(true),
        ),
      ),
    ));
    await tester.pump();
    return (widths: widths, hides: hides);
  }

  Future<void> dragDivider(WidgetTester tester, double distance) async {
    final divider = tester.getCenter(find.byType(LibraryResizableDivider));
    final gesture = await tester.startGesture(divider);
    // Small steps, so the drag gesture wins and each one reports a delta.
    const step = 20.0;
    for (var moved = 0.0; moved < distance; moved += step) {
      await gesture.moveBy(const Offset(step, 0));
      await tester.pump();
    }
    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('a drag to the smallest size only shrinks the panel',
      (tester) async {
    final calls = await pump(tester);

    await dragDivider(tester, 340 - kLibraryDetailsMinWidth);

    expect(calls.hides, isEmpty);
    expect(calls.widths.last, kLibraryDetailsMinWidth);
  });

  testWidgets('a drag well past the smallest size hides the panel',
      (tester) async {
    final calls = await pump(tester);

    await dragDivider(tester, 340 - kLibraryDetailsMinWidth + 100);

    expect(calls.hides, [true]);
    // The panel returns at the size it had before the drag.
    expect(calls.widths.last, 340);
  });
}
