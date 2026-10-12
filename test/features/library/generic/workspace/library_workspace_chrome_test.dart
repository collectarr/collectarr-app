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
    expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
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

  for (final initialLayout in [
    LibraryDetailsLayout.right,
    LibraryDetailsLayout.bottom,
  ]) {
    testWidgets('resizing bounds outgoing $initialLayout inspector during fade',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1500, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      const inspectorKey = ValueKey('resize-test-inspector');
      var persistenceCalls = 0;
      Widget page(LibraryDetailsLayout layout) => MaterialApp(
            home: Scaffold(
              body: LibraryDetailsAwareLayout(
                detailsLayout: layout,
                frameInspector: false,
                rightWidth: 1000,
                maxRightWidth: 4096,
                bottomHeight: 600,
                maxBottomHeight: 4096,
                onRightWidthChanged: (_) => persistenceCalls++,
                onBottomHeightChanged: (_) => persistenceCalls++,
                content: const ColoredBox(color: Colors.blue),
                inspector: ColoredBox(key: inspectorKey, color: Colors.red),
              ),
            ),
          );
      await tester.pumpWidget(page(initialLayout));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.binding.setSurfaceSize(const Size(744, 500));
      final nextLayout = initialLayout == LibraryDetailsLayout.right
          ? LibraryDetailsLayout.bottom
          : LibraryDetailsLayout.right;
      await tester.pumpWidget(page(nextLayout));
      for (var frame = 0; frame < 12; frame++) {
        await tester.pump(const Duration(milliseconds: 30));
        expect(tester.takeException(), isNull,
            reason: 'transition frame $frame');
      }
      final size = tester.getSize(find.byKey(inspectorKey).last);
      if (nextLayout == LibraryDetailsLayout.right) {
        expect(size.width, lessThanOrEqualTo(418));
      } else {
        expect(size.height, lessThanOrEqualTo(274));
      }
      expect(persistenceCalls, 0);

      await tester.binding.setSurfaceSize(const Size(1500, 1000));
      await tester.pumpWidget(page(initialLayout));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final restoredSize = tester.getSize(find.byKey(inspectorKey).last);
      if (initialLayout == LibraryDetailsLayout.right) {
        expect(restoredSize.width, 1000);
      } else {
        expect(restoredSize.height, 600);
      }
    });
  }

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
