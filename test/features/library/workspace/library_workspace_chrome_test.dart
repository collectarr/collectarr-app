import 'package:collectarr_app/features/library/workspace/chrome/library_workspace_chrome.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_resizable_pane.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
