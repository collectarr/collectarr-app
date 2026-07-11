import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/toolbar/toolbar_auxiliary_controls.dart';
import 'package:collectarr_app/features/library/generic/toolbar/toolbar_sections.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_media_adapters.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_view_controls.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_dense_controls.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('desktop secondary toolbar exposes a split sort launcher', (
    tester,
  ) async {
    final type = collectarrLibraryTypes.byKind('comic')!;
    final adapter = collectarrMediaAdapters.byKind('comic')!;
    var sortColumnsCount = 0;
    var manageSortFavoritesCount = 0;
    String? appliedSortFavorite;
    const sortFavorite = LibrarySortFavorite(
      id: 'series_issue',
      label: 'Series | Issue',
      icon: Icons.swap_vert,
      rules: [
        LibrarySortRule(column: 'series', ascending: true),
        LibrarySortRule(column: 'issue', ascending: true),
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
              onSortFavoriteSelected: (favorite) =>
                  appliedSortFavorite = favorite.id,
              onManageSortFavorites: () => manageSortFavoritesCount++,
              onEditSort: () => sortColumnsCount++,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final sortButton = find.byType(LibraryToolbarSortButton);
    expect(sortButton, findsOneWidget);
    expect(find.byKey(const ValueKey('library-sort-split-button-menu')),
        findsOneWidget);

    await tester.tap(
      find.descendant(of: sortButton, matching: find.byIcon(Icons.sort)),
    );
    await tester.pump();

    expect(sortColumnsCount, 1);

    final popupButton = tester.widget<PopupMenuButton<Object>>(
      find.byKey(const ValueKey('library-sort-split-button-menu')),
    );
    popupButton.onSelected?.call(libraryManageSortFavoritesMenuValue);
    await tester.pump();

    expect(manageSortFavoritesCount, 1);

    popupButton.onSelected?.call(sortFavorite);
    await tester.pump();

    expect(appliedSortFavorite, 'series_issue');
  });

  testWidgets(
      'desktop secondary toolbar hides details layout control when the details panel is visible',
      (tester) async {
    final type = collectarrLibraryTypes.byKind('comic')!;
    final adapter = collectarrMediaAdapters.byKind('comic')!;

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
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(LibraryDetailsLayoutDropdown), findsNothing);
  });

  testWidgets(
      'desktop secondary toolbar shows details layout control when the details panel is hidden',
      (tester) async {
    final type = collectarrLibraryTypes.byKind('comic')!;
    final adapter = collectarrMediaAdapters.byKind('comic')!;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            child: LibraryDesktopSecondaryToolbar(
              type: type,
              viewState: adapter.viewProfile.defaults().copyWith(
                    viewMode: LibraryViewMode.list,
                    detailsLayout: LibraryDetailsLayout.hidden,
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
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(LibraryDetailsLayoutDropdown), findsOneWidget);
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
              onColumnFavoriteSelected: (preset) =>
                  appliedPreset = preset.label,
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

    expect(find.byKey(const ValueKey('library-column-split-button')),
        findsOneWidget);
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

  testWidgets('sort favorites menu keeps pinned favorites first in saved order',
      (
    tester,
  ) async {
    const pinnedFavorite = LibrarySortFavorite(
      id: 'price_desc',
      label: 'Price desc',
      icon: Icons.attach_money,
      rules: [
        LibrarySortRule(column: 'price', ascending: false),
      ],
    );
    const secondPinnedFavorite = LibrarySortFavorite(
      id: 'title_asc',
      label: 'Title asc',
      icon: Icons.sort_by_alpha,
      rules: [
        LibrarySortRule(column: 'title', ascending: true),
      ],
    );
    const overflowFavorite = LibrarySortFavorite(
      id: 'updated_desc',
      label: 'Updated desc',
      icon: Icons.update,
      rules: [
        LibrarySortRule(column: 'updated', ascending: false),
      ],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LibraryToolbarSortButton(
            onPressed: _noop,
            sortFavorites: [
              secondPinnedFavorite,
              overflowFavorite,
              pinnedFavorite,
            ],
            activeSortFavoriteId: 'title_asc',
            pinnedSortFavoriteIds: {'price_desc', 'title_asc'},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final menuFinder = find.byKey(
      const ValueKey('library-sort-split-button-menu'),
    );
    final popupButton = tester.widget<PopupMenuButton<Object>>(menuFinder);
    final items = popupButton.itemBuilder(tester.element(menuFinder));

    expect(items[0], isA<PopupMenuItem<Object>>());
    expect((items[2] as PopupMenuItem<Object>).value, pinnedFavorite);
    expect((items[3] as PopupMenuItem<Object>).value, secondPinnedFavorite);
    expect((items[5] as PopupMenuItem<Object>).value, overflowFavorite);
  });

  testWidgets('desktop secondary toolbar shows folder preset chip with reset', (
    tester,
  ) async {
    final type = collectarrLibraryTypes.byKind('comic')!;
    final adapter = collectarrMediaAdapters.byKind('comic')!;
    LibraryFolderPreset? changedPreset;
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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
              counts: const LibraryToolbarCounts(shown: 10, total: 20),
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
              groupMode: 'series',
              folderPreset: LibraryFolderPreset(
                modes: const [
                  'series',
                  'publisher'
                ],
              ),
              onGroupModeChanged: (preset) => changedPreset = preset,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(InputChip), findsOneWidget);
    expect(find.byTooltip('Reset folders'), findsOneWidget);

    await tester.tap(find.byTooltip('Reset folders'));
    await tester.pumpAndSettle();

    expect(changedPreset,
        LibraryFolderPreset.single(libraryDefaultGroupMode(type)));
  });

  testWidgets('compact toolbar exposes a visible folders shortcut',
      (tester) async {
    final type = collectarrLibraryTypes.byKind('comic')!;
    var foldersPressed = 0;
    final searchController = TextEditingController();
    addTearDown(searchController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 700,
            child: LibraryCompactToolbarContent(
              type: type,
              searchController: searchController,
              accent: Colors.teal,
              counts: const LibraryToolbarCounts(),
              viewMode: LibraryViewMode.grid,
              selectedBucket: null,
              onAdd: () {},
              onScan: () {},
              onSearchChanged: (_) {},
              onRefreshMetadata: () {},
              onViewModeChanged: (_) {},
              onDetailsLayoutChanged: (_) {},
              onCoverSizeChanged: (_) {},
              onDensityPresetChanged: (_) {},
              onManageColumns: () {},
              quickView: null,
              onQuickViewSelected: (_) {},
              collectionStatusScope: LibraryCollectionStatusScope.all,
              hasActiveFilters: false,
              onClearFilters: () {},
              onClearBucket: () {},
              onFolders: () => foldersPressed++,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Folders'));
    await tester.pumpAndSettle();

    expect(foldersPressed, 1);
  });

  testWidgets(
      'sort favorites manager dialog renders pinned and available panes', (
    tester,
  ) async {
    final type = collectarrLibraryTypes.byKind('comic')!;
    const sortFavorite = LibrarySortFavorite(
      id: 'series_issue',
      label: 'Series | Issue',
      icon: Icons.swap_vert,
      rules: [
        LibrarySortRule(column: 'series', ascending: true),
        LibrarySortRule(column: 'issue', ascending: true),
      ],
    );
    const secondFavorite = LibrarySortFavorite(
      id: 'updated_desc',
      label: 'Updated desc',
      icon: Icons.update,
      rules: [
        LibrarySortRule(column: 'updated', ascending: false),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () {
                showSortFavoritesManagerDialog(
                  context: context,
                  type: type,
                  favorites: const [sortFavorite, secondFavorite],
                  initialPinnedIds: const {'series_issue'},
                  activeSortFavoriteId: 'series_issue',
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Manage Sorting Favorites'), findsOneWidget);
    expect(find.text('Pinned Favorites'), findsOneWidget);
    expect(find.text('Available Favorites'), findsOneWidget);
    expect(find.byKey(const ValueKey('sortFavorite_series_issue')),
        findsOneWidget);
    expect(
      find.byKey(const ValueKey('availableSortFavorite_updated_desc')),
      findsOneWidget,
    );
  });
}

void _noop() {}
