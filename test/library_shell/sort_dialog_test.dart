import 'package:collectarr_app/features/library/generic/sort_dialog.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_constants.dart';

void main() {
  testWidgets('sort dialog returns reordered multi-column rules', (
    tester,
  ) async {
    List<LibrarySortRule>? result;
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                result = await showLibrarySortDialog(
                  context: context,
                  type: moviesLibraryConfig,
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
    await pumpUntilSettled(tester);

    await tester.tap(find.byTooltip('Move down').first);
    await pumpUntilSettled(tester);
    await tester.tap(find.text('Save'));
    await pumpUntilSettled(tester);

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

  testWidgets('sort dialog saves and reloads a custom preset', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    List<LibrarySortRule>? result;

    Future<void> openDialog(List<LibrarySortRule> rules) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => FilledButton(
                onPressed: () async {
                  result = await showLibrarySortDialog(
                    context: context,
                    type: moviesLibraryConfig,
                    currentRules: rules,
                  );
                },
                child: const Text('Open sort'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open sort'));
      await pumpUntilSettled(tester);
    }

    await openDialog(const [
      LibrarySortRule(column: LibrarySortColumn.title, ascending: true),
    ]);

    final searchField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.hintText == 'Search fields',
    );
    await tester.enterText(searchField, '');
    await pumpUntilSettled(tester);
    final releaseDateTile = find.byKey(const ValueKey('available-sort-releaseDate'));
    await tester.ensureVisible(releaseDateTile);
    await tester.tap(releaseDateTile);
    await pumpUntilSettled(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Preset name'),
      'Storage box',
    );
    await tester.pump();
    await tester.tap(find.text('Save favorite'));
    await pumpUntilSettled(tester);
    await tester.tap(find.text('Save'));
    await pumpUntilSettled(tester);

    expect(result, isNotNull);
    expect(result!.length, 2);
    expect(result![0], const LibrarySortRule(column: LibrarySortColumn.title, ascending: true));
    expect(result![1].column, LibrarySortColumn.releaseDate);

    await openDialog(const [
      LibrarySortRule(column: LibrarySortColumn.title, ascending: true),
    ]);

    expect(find.text('Storage box'), findsOneWidget);
  });
}
