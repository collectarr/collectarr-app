import 'package:collectarr_app/features/library/workspace/chrome/library_view_controls.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
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
              densityPreset: LibraryWorkspaceDensityPreset.compact,
              coverSize: coverSize,
              minCoverSize: 100,
              maxCoverSize: 200,
              onViewModeChanged: (value) => setState(() => viewMode = value),
              onDetailsLayoutChanged: (value) =>
                  setState(() => detailsLayout = value),
              onCoverSizeChanged: (value) => setState(() => coverSize = value),
              onDensityPresetChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    final viewDropdown = tester.widget<PopupMenuButton<LibraryViewMode>>(
      find.byWidgetPredicate((widget) => widget is PopupMenuButton<LibraryViewMode>),
    );
    viewDropdown.onSelected?.call(LibraryViewMode.list);
    await tester.pump();
    expect(viewMode, LibraryViewMode.list);

    final detailsDropdown = tester.widget<PopupMenuButton<LibraryDetailsLayout>>(
      find.byWidgetPredicate(
        (widget) => widget is PopupMenuButton<LibraryDetailsLayout>,
      ),
    );
    detailsDropdown.onSelected?.call(LibraryDetailsLayout.hidden);
    await tester.pump();
    expect(detailsLayout, LibraryDetailsLayout.hidden);

    // Cover size slider is present
    expect(find.byType(Slider), findsOneWidget);
  });
}
