import 'package:collectarr_app/features/library/workspace/library_view_controls.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('reports view and details layout changes', (tester) async {
    var viewMode = LibraryViewMode.grid;
    var detailsLayout = LibraryDetailsLayout.right;
    var coverSize = 128.0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => LibraryViewControls(
              viewMode: viewMode,
              detailsLayout: detailsLayout,
              coverSize: coverSize,
              minCoverSize: 100,
              maxCoverSize: 200,
              onViewModeChanged: (value) => setState(() => viewMode = value),
              onDetailsLayoutChanged: (value) =>
                  setState(() => detailsLayout = value),
              onCoverSizeChanged: (value) => setState(() => coverSize = value),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('List view'));
    await tester.pumpAndSettle();
    expect(viewMode, LibraryViewMode.list);

    await tester.tap(find.byTooltip('Hide details panel'));
    await tester.pumpAndSettle();
    expect(detailsLayout, LibraryDetailsLayout.hidden);

    // Cover size slider is present
    expect(find.byType(Slider), findsOneWidget);
  });
}
