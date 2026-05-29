import 'package:collectarr_app/features/library/workspace/library_workspace_chrome.dart';
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
}

