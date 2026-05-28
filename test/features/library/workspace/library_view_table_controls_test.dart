import 'package:collectarr_app/features/library/workspace/library_view_table_controls.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_control_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
    expect(find.byTooltip('Views'), findsOneWidget);
    expect(find.byTooltip('Cover size'), findsOneWidget);

    await tester.tap(find.byTooltip('Select columns'));
    await tester.pump();
    expect(editColumnsCount, 0);

    final dropdown = tester.widget<DropdownButton<LibraryViewMode>>(
      find.byKey(const Key('library-view-mode-dropdown')),
    );
    expect(
      _dropdownItemLabels(dropdown.items!),
      ['List', 'Cards', 'Flow', 'Grid', 'Shelves'],
    );

    dropdown.onChanged!(LibraryViewMode.list);
    await tester.pump();
    await tester.tap(find.byTooltip('Select columns'));
    await tester.pump();
    expect(editColumnsCount, 1);
  });
}

List<String> _dropdownItemLabels(
  List<DropdownMenuItem<LibraryViewMode>> items,
) {
  return [for (final item in items) _extractText(item.child)];
}

String _extractText(Widget? widget) {
  if (widget == null) {
    return '';
  }
  if (widget is Text) {
    return widget.data ?? '';
  }
  if (widget is Expanded) {
    return _extractText(widget.child);
  }
  if (widget is Row) {
    for (final child in widget.children) {
      final text = _extractText(child);
      if (text.isNotEmpty) {
        return text;
      }
    }
  }
  return '';
}
