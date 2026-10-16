import 'package:collectarr_app/features/library/workspace/chrome/library_view_controls.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('cover size and item spacing have equal slider widths',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Row(children: [
      LibraryCoverSizeSlider(
        viewMode: LibraryViewMode.grid,
        coverSize: 128,
        minCoverSize: 100,
        maxCoverSize: 200,
        onChanged: (_) {},
      ),
      LibrarySpacingSlider(spacing: 8, onChanged: (_) {}),
    ]))));
    final sliders = find.byType(Slider);
    expect(sliders, findsNWidgets(2));
    expect(tester.getSize(sliders.at(0)).width,
        tester.getSize(sliders.at(1)).width);
    expect(find.byTooltip('Cover Size'), findsOneWidget);
    expect(find.byTooltip('Item Spacing'), findsOneWidget);
  });

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

    final viewDropdown = tester.widget<PopupMenuButton<LibraryViewMode>>(
      find.byWidgetPredicate(
          (widget) => widget is PopupMenuButton<LibraryViewMode>),
    );
    viewDropdown.onSelected?.call(LibraryViewMode.list);
    await tester.pump();
    expect(viewMode, LibraryViewMode.list);

    final detailsDropdown =
        tester.widget<PopupMenuButton<LibraryDetailsLayout>>(
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
