import 'package:collectarr_app/features/library/workspace/library_view_table_controls.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_control_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders counts and enables column chooser in list mode',
      (tester) async {
    var viewMode = LibraryViewMode.grid;
    var detailsLayout = LibraryDetailsLayout.right;
    var editColumnsCount = 0;
    const viewModeDropdownKey = Key('library-view-mode-dropdown');
    const detailsLayoutDropdownKey = Key('library-details-layout-dropdown');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return LibraryViewTableControls(
                state: LibraryViewTableControlState(
                  counts: const LibraryWorkspaceCounts(shown: 12, total: 28),
                  viewMode: viewMode,
                  detailsLayout: detailsLayout,
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
                  onDetailsLayoutChanged: (value) =>
                      setState(() => detailsLayout = value),
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
    expect(find.byKey(viewModeDropdownKey), findsOneWidget);
    expect(find.byKey(detailsLayoutDropdownKey), findsOneWidget);
    expect(find.byTooltip('Grid view'), findsOneWidget);
    expect(find.byTooltip('Details right'), findsOneWidget);

    await tester.tap(find.byTooltip('Select columns'));
    await tester.pump();
    expect(editColumnsCount, 0);

    final dropdown = tester.widget<PopupMenuButton<LibraryViewMode>>(
      find.byKey(viewModeDropdownKey),
    );
    dropdown.onSelected?.call(LibraryViewMode.list);
    final detailsDropdown =
        tester.widget<PopupMenuButton<LibraryDetailsLayout>>(
      find.byKey(detailsLayoutDropdownKey),
    );
    detailsDropdown.onSelected?.call(LibraryDetailsLayout.hidden);
    await tester.pump();
    expect(find.byTooltip('Details hidden'), findsOneWidget);
    await tester.tap(find.byTooltip('Select columns'));
    await tester.pump();
    expect(editColumnsCount, 1);
  });
}
