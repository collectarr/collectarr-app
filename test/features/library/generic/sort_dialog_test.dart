import 'package:collectarr_app/features/library/generic/sort_dialog.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('sort dialog returns reordered multi-column rules', (
    tester,
  ) async {
    List<LibrarySortRule>? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                result = await showLibrarySortDialog(
                  context: context,
                  currentRules: const [
                    LibrarySortRule(
                      column: LibrarySortColumn.title,
                      ascending: true,
                    ),
                    LibrarySortRule(
                      column: LibrarySortColumn.updated,
                      ascending: false,
                    ),
                  ],
                );
              },
              child: const Text('Open sort'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open sort'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Move down').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(result, const [
      LibrarySortRule(
        column: LibrarySortColumn.updated,
        ascending: false,
      ),
      LibrarySortRule(
        column: LibrarySortColumn.title,
        ascending: true,
      ),
    ]);
  });
}