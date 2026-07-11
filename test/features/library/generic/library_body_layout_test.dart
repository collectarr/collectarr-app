import 'package:collectarr_app/features/library/generic/body.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_pane_widths.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  LibraryWorkspaceViewState stateFor({
    required LibraryViewMode mode,
    required double coverSize,
  }) {
    return LibraryWorkspaceViewState(
      viewMode: mode,
      detailsLayout: LibraryDetailsLayout.right,
      isSidebarVisible: true,
      sortColumn: 'title',
      sortAscending: true,
      coverSize: coverSize,
      sidebarWidth: kLibrarySidebarDefaultWidth,
      detailsWidth: kLibraryDetailsDefaultWidth,
      detailsHeight: kLibraryDetailsDefaultHeight,
      visibleColumns: const {'title'},
      columnWidths: const {},
    );
  }

  test('grid view allows narrower workspace minimum than global default', () {
    final minWidth = resolveLibraryWorkspaceMinWidth(
      viewState: stateFor(mode: LibraryViewMode.grid, coverSize: 180),
    );

    expect(minWidth, lessThan(kLibraryWorkspaceMinWidth));
    expect(minWidth, closeTo(216, 0.001));
  });

  test('list view keeps conservative workspace minimum', () {
    final minWidth = resolveLibraryWorkspaceMinWidth(
      viewState: stateFor(mode: LibraryViewMode.list, coverSize: 180),
    );

    expect(minWidth, kLibraryWorkspaceMinWidth);
  });
}
