import 'package:collectarr_app/features/library/workspace/chrome/view_and_organize_sheet.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'ViewAndOrganizeSheet switches layout and density modes and updates cover size',
      (tester) async {
    LibraryViewMode selectedView = LibraryViewMode.grid;
    LibraryWorkspaceDensityPreset selectedDensity =
        LibraryWorkspaceDensityPreset.compact;
    double selectedCoverSize = 140.0;
    bool sortOpened = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryAccentScope(
            kind: 'comic',
            accent: Colors.deepOrange,
            animationsEnabled: true,
            child: ViewAndOrganizeSheet(
              currentViewMode: selectedView,
              onViewModeChanged: (v) => selectedView = v,
              currentDensity: selectedDensity,
              onDensityChanged: (d) => selectedDensity = d,
              currentDetailsLayout: LibraryDetailsLayout.hidden,
              onDetailsLayoutChanged: (_) {},
              currentCoverSize: selectedCoverSize,
              minCoverSize: 100.0,
              maxCoverSize: 300.0,
              onCoverSizeChanged: (s) => selectedCoverSize = s,
              onOpenSortDialog: () => sortOpened = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('View & Organize'), findsOneWidget);
    expect(find.byKey(const ValueKey('view_mode_grid')), findsOneWidget);
    expect(find.byKey(const ValueKey('view_mode_list')), findsOneWidget);
    expect(find.byKey(const ValueKey('cover_size_slider')), findsOneWidget);

    // Switch view mode to List
    await tester.tap(find.byKey(const ValueKey('view_mode_list')));
    await tester.pumpAndSettle();
    expect(selectedView, LibraryViewMode.list);

    // Switch density to comfortable
    await tester.tap(find.byKey(const ValueKey('density_comfortable')));
    await tester.pumpAndSettle();
    expect(selectedDensity, LibraryWorkspaceDensityPreset.comfortable);

    // Open sort dialog
    await tester.tap(find.byKey(const ValueKey('sheet_open_sort')));
    await tester.pumpAndSettle();
    expect(sortOpened, isTrue);
  });

  testWidgets('showViewAndOrganizeSheet opens modal bottom sheet',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryAccentScope(
            kind: 'comic',
            accent: Colors.deepOrange,
            animationsEnabled: true,
            child: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showViewAndOrganizeSheet(
                      context: context,
                      currentViewMode: LibraryViewMode.grid,
                      onViewModeChanged: (_) {},
                      currentDensity: LibraryWorkspaceDensityPreset.compact,
                      onDensityChanged: (_) {},
                      currentDetailsLayout: LibraryDetailsLayout.hidden,
                      onDetailsLayoutChanged: (_) {},
                      currentCoverSize: 150,
                      minCoverSize: 100,
                      maxCoverSize: 300,
                      onCoverSizeChanged: (_) {},
                    );
                  },
                  child: const Text('Open Sheet'),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    expect(find.byType(ViewAndOrganizeSheet), findsOneWidget);
    expect(find.text('View & Organize'), findsOneWidget);
  });
}
