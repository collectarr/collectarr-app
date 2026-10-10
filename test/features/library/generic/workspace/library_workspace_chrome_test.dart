import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_workspace_chrome.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_resizable_pane.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final axis in Axis.values) {
    testWidgets(
        'panel divider paints a continuous seam and five grip marks ($axis)',
        (tester) async {
      final boundaryKey = GlobalKey();
      final horizontal = axis == Axis.horizontal;
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              key: boundaryKey,
              child: SizedBox(
                width: horizontal ? 6 : 100,
                height: horizontal ? 100 : 6,
                child: LibraryResizableDivider(
                  axis: axis,
                  onDragDelta: (_) {},
                ),
              ),
            ),
          ),
        ),
      ));
      await tester.pump();
      final boundary = boundaryKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1);
        final pixels =
            (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
        // Every pixel belongs to either the solid seam or the visible grip.
        var gripPixels = 0;
        for (var offset = 0; offset < pixels.lengthInBytes; offset += 4) {
          final red = pixels.getUint8(offset);
          expect(pixels.getUint8(offset + 3), 255);
          if (red > 200) {
            gripPixels++;
          } else {
            expect(red, 0x26);
            expect(pixels.getUint8(offset + 1), 0x26);
            expect(pixels.getUint8(offset + 2), 0x26);
          }
        }
        expect(gripPixels, 20); // Five visible 2 x 2 marks.
        image.dispose();
      });
    });
  }

  testWidgets('compact dropdown trigger renders icon and arrow', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LibraryToolbarCompactDropdownTrigger(
            icon: Icons.grid_view_outlined,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.grid_view_outlined), findsOneWidget);
    expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
  });

  testWidgets('workspace icon button triggers callback', (tester) async {
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryWorkspaceIconButton(
            icon: Icons.search,
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.search));

    expect(pressed, isTrue);
  });

  testWidgets('workspace separator renders a vertical divider', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LibraryWorkspaceSeparator(color: Colors.red),
        ),
      ),
    );

    final divider =
        tester.widget<VerticalDivider>(find.byType(VerticalDivider));

    expect(divider.color, Colors.red);
  });

  testWidgets('details aware layout frames inspector with details header', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            height: 500,
            child: LibraryDetailsAwareLayout(
              detailsLayout: LibraryDetailsLayout.right,
              onRightWidthChanged: (_) {},
              content: const ColoredBox(color: Colors.blue),
              inspector: const Center(child: Text('Inspector body')),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Details'), findsOneWidget);
    expect(find.text('Inspector body'), findsOneWidget);
  });

  testWidgets('details aware layout can render inspector without shared frame',
      (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            height: 500,
            child: LibraryDetailsAwareLayout(
              detailsLayout: LibraryDetailsLayout.right,
              frameInspector: false,
              onRightWidthChanged: (_) {},
              content: const ColoredBox(color: Colors.blue),
              inspector: const Center(child: Text('Inspector body')),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Details'), findsNothing);
    expect(find.text('Inspector body'), findsOneWidget);
  });

  testWidgets('right divider drag decreases details width when dragged right', (
    tester,
  ) async {
    double? reportedWidth;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            height: 500,
            child: LibraryDetailsAwareLayout(
              detailsLayout: LibraryDetailsLayout.right,
              rightWidth: 340,
              onRightWidthChanged: (value) => reportedWidth = value,
              content: const ColoredBox(color: Colors.blue),
              inspector: const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );

    await tester.drag(
        find.byType(LibraryResizableDivider), const Offset(24, 0));
    await tester.pump();

    expect(reportedWidth, isNotNull);
    expect(reportedWidth, lessThan(340));
  });

  testWidgets('bottom divider drag decreases details height when dragged down',
      (
    tester,
  ) async {
    double? reportedHeight;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            height: 500,
            child: LibraryDetailsAwareLayout(
              detailsLayout: LibraryDetailsLayout.bottom,
              bottomHeight: 300,
              onBottomHeightChanged: (value) => reportedHeight = value,
              content: const ColoredBox(color: Colors.blue),
              inspector: const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );

    await tester.drag(
        find.byType(LibraryResizableDivider), const Offset(0, 24));
    await tester.pump();

    expect(reportedHeight, isNotNull);
    expect(reportedHeight, lessThan(300));
  });
}
