import 'package:collectarr_app/features/library/workspace/chrome/library_workspace_menus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('menu row renders leading and trailing widgets', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LibraryWorkspaceMenuRow(
            label: 'Views',
            leading: Icon(Icons.grid_view_outlined),
            trailing: Icon(Icons.check),
          ),
        ),
      ),
    );

    expect(find.text('Views'), findsOneWidget);
    expect(find.byIcon(Icons.grid_view_outlined), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('menu section divider renders section label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LibraryWorkspaceMenuSectionDivider(label: 'Folders'),
        ),
      ),
    );

    expect(find.text('Folders'), findsOneWidget);
    expect(find.byType(Divider), findsOneWidget);
  });

  testWidgets('tree header reflects highlight and expansion state', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryWorkspaceMenuTreeHeader(
            label: 'Main',
            expanded: false,
            highlighted: true,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Main'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNothing);
    expect(find.byIcon(Icons.expand_more), findsOneWidget);
  });
}
