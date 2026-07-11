import 'package:collectarr_app/features/library/workspace/table/library_view_table_controls.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_control_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders split column launcher and applies favorites in list mode', (
    tester,
  ) async {
    var viewMode = LibraryViewMode.list;
    var detailsLayout = LibraryDetailsLayout.right;
    var editColumnsCount = 0;
    String? selectedPreset;
    const viewModeDropdownKey = Key('library-view-mode-dropdown');
    const detailsLayoutDropdownKey = Key('library-details-layout-dropdown');
    final essentialPreset = LibraryTableColumnPreset(
      label: 'Essential',
      columns: const {
        'title',
        'issue',
      },
    );
    final pricingPreset = LibraryTableColumnPreset(
      label: 'Pricing',
      columns: const {
        'title',
        'publisher',
        'release_date',
      },
    );

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
                  densityPreset: LibraryWorkspaceDensityPreset.compact,
                  isSidebarVisible: true,
                  coverSize: 128,
                  minCoverSize: 100,
                  maxCoverSize: 200,
                  columnFavoritePresets: [essentialPreset, pricingPreset],
                  activeColumnFavoriteLabel: 'Essential',
                  pinnedColumnFavoriteKeys: const {'builtin:essential'},
                ),
                callbacks: LibraryViewTableControlCallbacks(
                  onEditColumns: () => editColumnsCount++,
                  onSidebarVisibilityChanged: (_) {},
                  onViewModeChanged: (value) =>
                      setState(() => viewMode = value),
                  onDetailsLayoutChanged: (value) =>
                      setState(() => detailsLayout = value),
                  onDensityPresetChanged: (_) {},
                  onCoverSizeChanged: (_) {},
                  onColumnFavoriteSelected: (preset) =>
                      selectedPreset = preset.label,
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('legacy-library-column-split-button')),
      findsOneWidget,
    );
    expect(find.byKey(viewModeDropdownKey), findsOneWidget);
    expect(find.byKey(detailsLayoutDropdownKey), findsOneWidget);

    await tester.tap(find.text('Essential').first);
    await tester.pump();
    expect(editColumnsCount, 1);

    final dropdown = tester.widget<PopupMenuButton<LibraryViewMode>>(
      find.byKey(viewModeDropdownKey),
    );
    dropdown.onSelected?.call(LibraryViewMode.grid);
    final detailsDropdown = tester.widget<PopupMenuButton<LibraryDetailsLayout>>(
      find.byKey(detailsLayoutDropdownKey),
    );
    detailsDropdown.onSelected?.call(LibraryDetailsLayout.hidden);
    await tester.pump();

    expect(find.byKey(const ValueKey('legacy-library-column-split-button')), findsNothing);
    expect(detailsLayout, LibraryDetailsLayout.hidden);

    dropdown.onSelected?.call(LibraryViewMode.list);
    await tester.pump();

    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('legacy-library-column-split-button')),
        matching: find.byIcon(Icons.keyboard_arrow_down),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pricing').last);
    await tester.pumpAndSettle();

    expect(selectedPreset, 'Pricing');
  });
}
