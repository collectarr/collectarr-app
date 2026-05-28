import 'package:collectarr_app/features/library/workspace/library_view_table_controls.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_control_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_constants.dart';

void main() {
  testWidgets('renders counts and enables column chooser in list mode',
      (tester) async {
    var viewMode = LibraryViewMode.grid;
    var editColumnsCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return LibraryViewTableControls(
                state: LibraryViewTableControlState(
                  counts: const LibraryWorkspaceCounts(shown: 12, total: 28),
                  viewMode: viewMode,
                  detailsLayout: LibraryDetailsLayout.right,
                  isSidebarVisible: true,
                  coverSize: 128,
                  minCoverSize: 100,
                  maxCoverSize: 200,
                ),
                callbacks: LibraryViewTableControlCallbacks(
                  onEditColumns: () => editColumnsCount++,
                  onSidebarVisibilityChanged: (_) {},
                  onViewModeChanged: (value) =>
                      setState(() => viewMode = value),
                  onDetailsLayoutChanged: (_) {},
                  onCoverSizeChanged: (_) {},
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(find.byTooltip('Select columns'), findsOneWidget);
    expect(find.byTooltip('Cover size'), findsOneWidget);
    expect(find.byTooltip('Grid view'), findsOneWidget);
    expect(find.byTooltip('Cards view'), findsOneWidget);
    expect(find.byTooltip('List view'), findsOneWidget);

    await tester.tap(find.byTooltip('Select columns'));
    await tester.pump();
    expect(editColumnsCount, 0);

    await tester.tap(find.byTooltip('List view'));
    await pumpUntilSettled(tester);
    await tester.tap(find.byTooltip('Select columns'));
    await tester.pump();
    expect(editColumnsCount, 1);
  });
}
