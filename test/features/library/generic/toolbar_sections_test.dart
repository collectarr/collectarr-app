import 'package:collectarr_app/features/library/generic/quick_view.dart';
import 'package:collectarr_app/features/library/generic/toolbar/toolbar_auxiliary_controls.dart';
import 'package:collectarr_app/features/library/generic/toolbar/toolbar_sections.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_media_adapters.dart';
import 'package:collectarr_app/features/library/workspace/library_dense_controls.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('desktop secondary toolbar exposes a split sort launcher', (
    tester,
  ) async {
    final type = collectarrLibraryTypes.byKind('comic')!;
    final adapter = collectarrMediaAdapters.byKind('comic')!;
    var manageSortCount = 0;
    String? appliedSortFavorite;
    String? toggledSortFavorite;
    const sortFavorite = LibrarySortFavorite(
      id: 'series_issue',
      label: 'Series | Issue',
      icon: Icons.swap_vert,
      rules: [
        LibrarySortRule(column: LibrarySortColumn.series, ascending: true),
        LibrarySortRule(column: LibrarySortColumn.issue, ascending: true),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            child: LibraryDesktopSecondaryToolbar(
              type: type,
              viewState: adapter.viewProfile.defaults().copyWith(
                viewMode: LibraryViewMode.list,
                detailsLayout: LibraryDetailsLayout.right,
              ),
              adapter: adapter,
              counts: const LibraryToolbarCounts(shown: 18, total: 42),
              onEditColumns: () {},
              onSidebarVisibilityChanged: (_) {},
              onViewModeChanged: (_) {},
              onDetailsLayoutChanged: (_) {},
              onCoverSizeChanged: (_) {},
              selectedBucket: null,
              onClearBucket: () {},
              quickView: null,
              hasActiveFilters: false,
              onQuickViewSelected: (_) {},
              onClearFilters: () {},
              sortFavorites: const [sortFavorite],
              activeSortFavoriteId: 'series_issue',
              pinnedSortFavoriteIds: const {'series_issue'},
              onSortFavoriteSelected: (favorite) => appliedSortFavorite = favorite.id,
              onTogglePinnedSortFavorite: (favorite) => toggledSortFavorite = favorite.id,
              onEditSort: () => manageSortCount++,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final sortButton = find.byType(LibraryToolbarSortButton);
    expect(sortButton, findsOneWidget);
    expect(find.byKey(const ValueKey('library-sort-split-button-menu')), findsOneWidget);
    expect(find.byKey(const ValueKey('library-sort-manage-menu')), findsOneWidget);

    await tester.tap(
      find.descendant(of: sortButton, matching: find.byIcon(Icons.sort)),
    );
    await tester.pump();

    expect(manageSortCount, 1);

    final popupButton = tester.widget<PopupMenuButton<Object>>(
      find.byKey(const ValueKey('library-sort-split-button-menu')),
    );
    popupButton.onSelected?.call(sortFavorite);
    await tester.pump();

    expect(appliedSortFavorite, 'series_issue');

    final managePopupButton = tester.widget<PopupMenuButton<LibrarySortFavorite>>(
      find.byKey(const ValueKey('library-sort-manage-menu')),
    );
    managePopupButton.onSelected?.call(sortFavorite);
    await tester.pump();

    expect(toggledSortFavorite, 'series_issue');
  });

  testWidgets('desktop secondary toolbar exposes a split column launcher', (
    tester,
  ) async {
    final type = collectarrLibraryTypes.byKind('comic')!;
    final adapter = collectarrMediaAdapters.byKind('comic')!;
    var manageColumnsCount = 0;
    String? appliedPreset;
    final essentialPreset = LibraryTableColumnPreset(
      label: 'Essential',
      columns: const {
        LibraryTableColumn.title,
        LibraryTableColumn.issue,
      },
    );
    final pricingPreset = LibraryTableColumnPreset(
      label: 'Pricing',
      columns: const {
        LibraryTableColumn.title,
        LibraryTableColumn.publisher,
        LibraryTableColumn.releaseDate,
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            child: LibraryDesktopSecondaryToolbar(
              type: type,
              viewState: adapter.viewProfile.defaults().copyWith(
                viewMode: LibraryViewMode.list,
                detailsLayout: LibraryDetailsLayout.right,
              ),
              adapter: adapter,
              counts: const LibraryToolbarCounts(shown: 18, total: 42),
              onEditColumns: () => manageColumnsCount++,
              columnFavoritePresets: [essentialPreset, pricingPreset],
              activeColumnFavoriteLabel: 'Essential',
              onColumnFavoriteSelected: (preset) => appliedPreset = preset.label,
              pinnedColumnFavoriteKeys: {
                libraryColumnFavoriteKey(essentialPreset),
              },
              onEditSort: null,
              onSidebarVisibilityChanged: (_) {},
              onViewModeChanged: (_) {},
              onDetailsLayoutChanged: (_) {},
              onCoverSizeChanged: (_) {},
              selectedBucket: null,
              onClearBucket: () {},
              quickView: null,
              hasActiveFilters: false,
              onQuickViewSelected: (_) {},
              onClearFilters: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('library-column-split-button')), findsOneWidget);
    expect(find.byType(LibraryDenseSplitButton<Object>), findsOneWidget);
    expect(find.text('Essential'), findsOneWidget);

    final splitButton = tester.widget<LibraryDenseSplitButton<Object>>(
      find.byType(LibraryDenseSplitButton<Object>),
    );
    splitButton.onPressed?.call();
    await tester.pump();

    expect(manageColumnsCount, 1);

    final popupButton = tester.widget<PopupMenuButton<Object>>(
      find.descendant(
        of: find.byKey(const ValueKey('library-column-split-button')),
        matching: find.byType(PopupMenuButton<Object>),
      ),
    );
    popupButton.onSelected?.call(pricingPreset);
    await tester.pump();

    expect(appliedPreset, 'Pricing');
  });
}