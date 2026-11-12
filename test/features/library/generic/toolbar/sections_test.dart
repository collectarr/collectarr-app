import 'package:collectarr_app/features/library/workspace/config/tokens.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/generic/toolbar/auxiliary_controls.dart';
import 'package:collectarr_app/features/library/generic/toolbar/sections.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/chrome/view_controls.dart';
import 'package:collectarr_app/features/library/workspace/chrome/dense_controls.dart';
import 'package:collectarr_app/features/library/workspace/chrome/menus.dart';
import 'package:collectarr_app/features/library/workspace/config/config.dart';
import 'package:collectarr_app/features/library/generic/sort_preset_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collectarr_app/features/library/workspace/chrome/controls.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the item count uses the singular for one item', (tester) async {
    Future<void> pump(int shown, int total) => tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: LibraryItemCountLabel(
                shown: shown,
                total: total,
                singularLabel: 'Game',
                pluralLabel: 'Games'))));
    await pump(1, 1);
    expect(find.text('1 game'), findsOneWidget);
    await pump(0, 1);
    expect(find.text('0 of 1 game'), findsOneWidget);
    await pump(9, 9);
    expect(find.text('9 games'), findsOneWidget);
  });

  testWidgets('desktop secondary toolbar exposes a split sort launcher', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final type = libraryKindRegistrationForKind(CatalogMediaKind.music);
    final runtime = type;
    var sortColumnsCount = 0;
    var manageSortFavoritesCount = 0;
    String? appliedSortFavorite;
    const sortFavorite = LibrarySortFavorite(
      id: 'series_issue',
      label: 'Series | Issue',
      icon: Icons.swap_vert,
      rules: [
        LibrarySortRule(column: 'music.artist_summary', ascending: true),
        LibrarySortRule(column: 'music.title', ascending: true),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            child: LibraryDesktopSecondaryToolbar(
              type: type,
              viewState:
                  libraryViewProfileForKind(runtime.kind).defaults().copyWith(
                        viewMode: LibraryViewMode.list,
                        detailsLayout: LibraryDetailsLayout.right,
                      ),
              counts: const LibraryToolbarCounts(shown: 18, total: 42),
              onEditColumns: () {},
              onSidebarVisibilityChanged: (_) {},
              onViewModeChanged: (_) {},
              onDetailsLayoutChanged: (_) {},
              onCoverSizeChanged: (_) {},
              selectedBucket: null,
              onClearBucket: () {},
              onRemoveLinkedMetadataFilter: (_) {},
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

    expect(find.byType(LibrarySpacingSlider), findsNothing);
    expect(find.byType(LibraryCoverSizeSlider), findsNothing);
    expect(find.byType(Slider), findsNothing);

    final sortButton = find.byType(LibraryToolbarSortButton);
    expect(sortButton, findsOneWidget);
    expect(find.byKey(const ValueKey('library-sort-split-button-menu')),
        findsOneWidget);

    await tester.tap(
      find.descendant(
          of: sortButton, matching: find.byIcon(AppIcons.sortAlpha)),
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
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

  testWidgets(
      'desktop secondary toolbar hides details layout control when the details panel is visible',
      (tester) async {
    final type = libraryKindRegistrationForKind(CatalogMediaKind.music);
    final runtime = type;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            child: LibraryDesktopSecondaryToolbar(
              type: type,
              viewState:
                  libraryViewProfileForKind(runtime.kind).defaults().copyWith(
                        viewMode: LibraryViewMode.list,
                        detailsLayout: LibraryDetailsLayout.right,
                      ),
              counts: const LibraryToolbarCounts(shown: 18, total: 42),
              onEditColumns: () {},
              onSidebarVisibilityChanged: (_) {},
              onViewModeChanged: (_) {},
              onDetailsLayoutChanged: (_) {},
              onCoverSizeChanged: (_) {},
              selectedBucket: null,
              onClearBucket: () {},
              onRemoveLinkedMetadataFilter: (_) {},
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
    final type = libraryKindRegistrationForKind(CatalogMediaKind.music);
    final runtime = type;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            child: LibraryDesktopSecondaryToolbar(
              type: type,
              viewState:
                  libraryViewProfileForKind(runtime.kind).defaults().copyWith(
                        viewMode: LibraryViewMode.list,
                        detailsLayout: LibraryDetailsLayout.hidden,
                      ),
              counts: const LibraryToolbarCounts(shown: 18, total: 42),
              onEditColumns: () {},
              onSidebarVisibilityChanged: (_) {},
              onViewModeChanged: (_) {},
              onDetailsLayoutChanged: (_) {},
              onCoverSizeChanged: (_) {},
              selectedBucket: null,
              onClearBucket: () {},
              onRemoveLinkedMetadataFilter: (_) {},
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
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

  testWidgets('desktop secondary toolbar exposes a split column launcher', (
    tester,
  ) async {
    final type = libraryKindRegistrationForKind(CatalogMediaKind.music);
    final runtime = type;
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
              viewState:
                  libraryViewProfileForKind(runtime.kind).defaults().copyWith(
                        viewMode: LibraryViewMode.list,
                        detailsLayout: LibraryDetailsLayout.right,
                      ),
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
              onRemoveLinkedMetadataFilter: (_) {},
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
    expect(find.text('Essential'), findsNothing);
    expect(
        tester
            .widget<LibraryDenseSplitButton<Object>>(
                find.byType(LibraryDenseSplitButton<Object>))
            .iconOnly,
        isTrue);

    // Like the view and sort buttons, it starts right after its separator.
    final columnsLeft = tester
        .getTopLeft(find.byKey(const ValueKey('library-column-split-button')))
        .dx;
    final separatorRight = find
        .byType(LibraryWorkspaceSeparator)
        .evaluate()
        .map((element) {
          final box = element.renderObject! as RenderBox;
          return box.localToGlobal(Offset(box.size.width, 0)).dx;
        })
        .where((right) => right <= columnsLeft)
        .reduce((a, b) => a > b ? a : b);
    expect(columnsLeft, separatorRight);

    final splitButton = tester.widget<LibraryDenseSplitButton<Object>>(
      find.byType(LibraryDenseSplitButton<Object>),
    );
    // As in the reference: Manage Favorites, then a "Favorites" heading over
    // the favorites, with the active one checked.
    expect(splitButton.entries.map((entry) => entry.label),
        ['Manage Favorites', 'Essential', 'Pricing']);
    expect(splitButton.entries.map((entry) => entry.section),
        [null, 'Favorites', null]);
    expect(
        splitButton.entries.map((entry) => entry.active), [false, true, false]);

    await tester.tap(find.descendant(
      of: find.byKey(const ValueKey('library-column-split-button')),
      matching: find.byIcon(AppIcons.columns),
    ));
    await tester.pump();

    expect(manageColumnsCount, 1);
    expect(find.text('Manage Favorites'), findsNothing);

    final trigger = find.byKey(const ValueKey('library-column-split-button'));
    await tester.tap(find.descendant(
        of: trigger, matching: find.byIcon(AppIcons.chevronDown)));
    await tester.pumpAndSettle();
    final menuRows = find.byType(LibraryToolbarMenuItem<Object>);
    expect(tester.getTopLeft(menuRows.first).dx,
        closeTo(tester.getTopLeft(trigger).dx - 4, 0.01));
    expect(tester.getTopLeft(menuRows.first).dy,
        closeTo(tester.getBottomLeft(trigger).dy + 4, 0.01));
    expect(tester.widget<Text>(find.text('Manage Favorites')).style!.fontWeight,
        FontWeight.w700);
    expect(tester.widget<Text>(find.text('Essential')).style!.fontWeight,
        kLibraryToolbarMenuFavoriteFontWeight);
    expect(
        find.descendant(
            of: find.byType(LibraryToolbarMenuSection),
            matching: find.byType(Divider)),
        findsNWidgets(2));
    final heading = tester.getRect(find.byType(LibraryToolbarMenuSection));
    final popup = tester.getRect(menuRows.first);
    expect(heading.left, popup.left);
    expect(heading.right, popup.right);
    final check = find.byIcon(AppIcons.check);
    expect(tester.widget<Icon>(check).color, Colors.white);
    expect(
        tester.getTopLeft(find.text('Essential')).dx -
            tester.getTopRight(check).dx,
        closeTo(kLibraryToolbarMenuMarkSpacing, 0.01));
    await tester.tap(find.text('Pricing'));
    await tester.pumpAndSettle();

    expect(appliedPreset, 'Pricing');
    await tester.tap(find.descendant(
        of: trigger, matching: find.byIcon(AppIcons.chevronDown)));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(LibraryToolbarMenuIconAction));
    await tester.pumpAndSettle();
    expect(manageColumnsCount, 2);
    expect(find.byType(LibraryToolbarMenuIconAction), findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

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
    expect(items, hasLength(4));
    expect(
        items
            .whereType<PopupMenuItem<Object>>()
            .where((item) => item.value == overflowFavorite),
        isEmpty);
  });

  testWidgets(
      'desktop grouping stays in the sidebar without duplicate toolbar chips', (
    tester,
  ) async {
    final type = libraryKindRegistrationForKind(CatalogMediaKind.music);
    final runtime = type;
    var linked = const <LibraryLinkedMetadataFilter>[];
    var cleared = false;
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Widget buildToolbar() => MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 1200,
              child: LibraryDesktopSecondaryToolbar(
                type: type,
                viewState:
                    libraryViewProfileForKind(runtime.kind).defaults().copyWith(
                          viewMode: LibraryViewMode.list,
                          detailsLayout: LibraryDetailsLayout.right,
                        ),
                counts: const LibraryToolbarCounts(shown: 10, total: 20),
                onEditColumns: () {},
                onSidebarVisibilityChanged: (_) {},
                onViewModeChanged: (_) {},
                onDetailsLayoutChanged: (_) {},
                onCoverSizeChanged: (_) {},
                selectedBucket: 'Example series',
                linkedMetadataFilters: linked,
                onRemoveLinkedMetadataFilter: (_) => cleared = true,
                onClearBucket: () {},
                quickView: null,
                hasActiveFilters: false,
                onQuickViewSelected: (_) {},
                onClearFilters: () {},
                groupMode: 'series',
                folderPreset: LibraryFolderPreset(
                  modes: const ['series', 'publisher'],
                ),
                onGroupModeChanged: (_) {},
              ),
            ),
          ),
        );
    await tester.pumpWidget(buildToolbar());

    expect(find.byType(LibraryToolbarScopeChip), findsNothing);
    expect(find.byTooltip('Reset folders'), findsNothing);
    expect(
        tester
            .getTopLeft(find.byKey(const Key('library-view-mode-dropdown')))
            .dx,
        4);

    linked = const [
      LibraryLinkedMetadataFilter(value: 'Demo Contributor', field: 'Producer'),
      LibraryLinkedMetadataFilter(value: 'Demo Genre', field: 'Genre'),
    ];
    await tester.pumpWidget(buildToolbar());
    expect(find.byType(LibraryToolbarScopeChip), findsNWidgets(2));
    expect(find.text('Producer: Demo Contributor'), findsOneWidget);
    expect(find.text('Genre: Demo Genre'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear').first);
    expect(cleared, isTrue);
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

  testWidgets('compact toolbar exposes a visible folders shortcut',
      (tester) async {
    final type = libraryKindRegistrationForKind(CatalogMediaKind.music);
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
              onRemoveLinkedMetadataFilter: (_) {},
              onFolders: () => foldersPressed++,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Folders'));
    await tester.pumpAndSettle();

    expect(foldersPressed, 1);
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

  testWidgets(
      'sort favorites manager keeps one editable list without built-in choices',
      (
    tester,
  ) async {
    final type = libraryKindRegistrationForKind(CatalogMediaKind.music);
    final sortFavorite = librarySortFavoritesForType(type).first;
    final secondFavorite = librarySortFavoritesForType(type).last;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () {
                showSortFavoritesManagerDialog(
                  context: context,
                  type: type,
                  favorites: [sortFavorite, secondFavorite],
                  initialPinnedIds: {sortFavorite.id},
                  currentRules: sortFavorite.rules,
                  onSortSelected: (_) {},
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
    expect(find.text('Sorting Favorites'), findsOneWidget);
    expect(find.text('Available Favorites'), findsNothing);
    expect(find.byKey(ValueKey('sortFavorite_${sortFavorite.id}')),
        findsOneWidget);
    // As in the reference: the active favorite is marked and each rule
    // carries an ASC or DESC badge.
    expect(
        find.descendant(
            of: find.byKey(ValueKey('sortFavorite_${sortFavorite.id}')),
            matching: find.byKey(const ValueKey('sortFavoriteActive'))),
        findsOneWidget);
    expect(find.text(sortFavorite.rules.first.ascending ? 'ASC' : 'DESC'),
        findsWidgets);
    expect(
        find.byKey(const ValueKey('sortFavoritesAddButton')), findsOneWidget);
    expect(find.text('Add Built-in Favorite'), findsNothing);
    expect(find.byKey(ValueKey('sortFavorite_${secondFavorite.id}')),
        findsOneWidget);
    expect(find.text('Edit'), findsNWidgets(2));
    // The sort in use is a favorite, so there is no current-sort row.
    expect(find.byKey(const ValueKey('sortFavoritesCurrent')), findsNothing);
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

  testWidgets(
      'a sort that is no favorite sits above the separator and can be '
      'chosen again or added', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final type = libraryKindRegistrationForKind(CatalogMediaKind.music);
    final favorite = librarySortFavoritesForType(type).first;
    final current = [
      LibrarySortRule(
          column: favorite.rules.first.column,
          ascending: !favorite.rules.first.ascending),
    ];
    final applied = <List<LibrarySortRule>>[];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => FilledButton(
            onPressed: () => showSortFavoritesManagerDialog(
              context: context,
              type: type,
              favorites: [favorite],
              initialPinnedIds: {favorite.id},
              currentRules: current,
              onSortSelected: applied.add,
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final currentRow = find.byKey(const ValueKey('sortFavoritesCurrent'));
    final favoriteRow = find.byKey(ValueKey('sortFavorite_${favorite.id}'));
    expect(
        find.descendant(
            of: currentRow,
            matching: find.byKey(const ValueKey('sortFavoriteActive'))),
        findsOneWidget);
    // The 44 px row, 20 px down to the 1 px line and 20 px on to the
    // favorites, as in the reference.
    expect(tester.getSize(currentRow).height, 85);
    expect(
        tester.getBottomLeft(currentRow).dy, tester.getTopLeft(favoriteRow).dy);

    await tester.tap(find
        .descendant(of: favoriteRow, matching: find.byType(GestureDetector))
        .first);
    await tester.pumpAndSettle();
    expect(applied, [favorite.rules]);
    expect(
        find.descendant(
            of: favoriteRow,
            matching: find.byKey(const ValueKey('sortFavoriteActive'))),
        findsOneWidget);

    await tester.tap(currentRow);
    await tester.pumpAndSettle();
    expect(applied.last, current);

    await tester.tap(find.byKey(const ValueKey('sortFavoritesPromoteButton')));
    await tester.pumpAndSettle();
    expect(currentRow, findsNothing);
    expect(find.byKey(const ValueKey('sortFavoriteActive')), findsOneWidget);
    expect((await LibrarySortPresetStore(type).read()).last.rules, current);
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));
}

void _noop() {}
