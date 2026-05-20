import 'package:collectarr_app/features/library/workspace/library_workspace_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('workspace grid renders empty state when there are no items',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LibraryWorkspaceGrid<String>(
          items: const [],
          maxCrossAxisExtent: 120,
          mainAxisExtent: 160,
          emptyBuilder: (_) => const Text('No items'),
          itemBuilder: (_, item) => Text(item),
        ),
      ),
    );

    expect(find.text('No items'), findsOneWidget);
    expect(find.byType(GridView), findsNothing);
  });

  testWidgets('workspace grid renders item tiles', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 320,
          height: 220,
          child: LibraryWorkspaceGrid<String>(
            items: const ['Spider-Man', 'Batman'],
            maxCrossAxisExtent: 120,
            mainAxisExtent: 160,
            emptyBuilder: (_) => const Text('No items'),
            itemBuilder: (_, item) => Text(item),
          ),
        ),
      ),
    );

    expect(find.text('Spider-Man'), findsOneWidget);
    expect(find.text('Batman'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
  });
}
