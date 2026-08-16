import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/session/library_workspace_session_controller.dart';
import 'package:collectarr_app/features/library/workspace/session/library_workspace_session_state.dart';
import 'package:collectarr_app/features/library/workspace/state/library_filters_provider.dart';
import 'package:collectarr_app/features/library/workspace/state/library_view_config_provider.dart';
import 'package:collectarr_app/features/library/workspace/state/library_workspace_key.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const key = LibraryWorkspaceKey(kind: CatalogMediaKind.comic);

  group('LibraryWorkspaceSessionController Tests', () {
    late ProviderContainer container;
    late LibraryWorkspaceSessionController controller;

    setUp(() {
      container = ProviderContainer();
      controller =
          container.read(libraryWorkspaceSessionProvider(key).notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state restores kind defaults cleanly', () {
      final state = container.read(libraryWorkspaceSessionProvider(key));
      expect(state.filters.searchQuery, isEmpty);
      expect(state.filters.groupId, isNotNull);
      expect(state.filters.sortId, isNotNull);
      expect(state.filters.visibleColumnIds, isNotEmpty);
      expect(state.view.viewMode, LibraryViewMode.grid);
      expect(state.selection.selectedId, isNull);
      expect(state.selection.selectedIds, isEmpty);
      expect(state.folder.displayMode, LibraryFolderDisplayMode.drilldown);
      expect(state.presets.pinnedFolderPresets, isEmpty);
      expect(state.asyncState.isLoading, false);
    });

    test('search actions update session state and sync with filters provider',
        () {
      controller.updateSearch('Spider-Man');
      var state = container.read(libraryWorkspaceSessionProvider(key));
      expect(state.filters.searchQuery, 'Spider-Man');
      expect(state.filters.searchDraft, 'Spider-Man');

      // Verifies sync with legacy downstream filters provider
      final legacyFilters = container.read(libraryFiltersProvider(key));
      expect(legacyFilters.searchQuery, 'Spider-Man');

      controller.clearSearch();
      state = container.read(libraryWorkspaceSessionProvider(key));
      expect(state.filters.searchQuery, isEmpty);
      expect(state.filters.searchDraft, isEmpty);
    });

    test('sort and group actions update state and legacy providers', () {
      controller.setSort('comic.cover_price', ascending: false);
      var state = container.read(libraryWorkspaceSessionProvider(key));
      expect(state.filters.sortId, 'comic.cover_price');
      expect(state.filters.sortAscending, false);

      var legacyFilters = container.read(libraryFiltersProvider(key));
      expect(legacyFilters.sortId, 'comic.cover_price');
      expect(legacyFilters.sortAscending, false);

      controller.toggleSortDirection();
      state = container.read(libraryWorkspaceSessionProvider(key));
      expect(state.filters.sortAscending, true);

      controller.setGroup('comic.publisher');
      state = container.read(libraryWorkspaceSessionProvider(key));
      expect(state.filters.groupId, 'comic.publisher');
    });

    test(
        'filter actions update facets, scopes, quick views, and linked metadata',
        () {
      controller.setFacetValues('publisher', {'Marvel', 'DC'});
      var state = container.read(libraryWorkspaceSessionProvider(key));
      expect(state.filters.facetValues['publisher'], {'Marvel', 'DC'});

      controller
          .setCollectionStatusScope(LibraryCollectionStatusScope.inCollection);
      state = container.read(libraryWorkspaceSessionProvider(key));
      expect(state.filters.collectionStatusScope,
          LibraryCollectionStatusScope.inCollection);

      controller.setSelectedLetter('S');
      state = container.read(libraryWorkspaceSessionProvider(key));
      expect(state.filters.selectedLetter, 'S');

      const qv = LibraryQuickView.missingCovers;
      controller.setQuickView(qv);
      state = container.read(libraryWorkspaceSessionProvider(key));
      expect(state.filters.quickView, LibraryQuickView.missingCovers);

      controller.resetFilters();
      state = container.read(libraryWorkspaceSessionProvider(key));
      expect(state.filters.facetValues, isEmpty);
    });

    test('view actions update viewMode, coverSize, sidebar, and column widths',
        () {
      controller.setViewMode(LibraryViewMode.list);
      var state = container.read(libraryWorkspaceSessionProvider(key));
      expect(state.view.viewMode, LibraryViewMode.list);

      var legacyView = container.read(libraryViewConfigProvider(key));
      expect(legacyView.viewMode, LibraryViewMode.list);

      controller.setCoverSize(240.0);
      state = container.read(libraryWorkspaceSessionProvider(key));
      expect(state.view.coverSize, 240.0);

      controller.setColumnWidth('comic.title', 300.0);
      state = container.read(libraryWorkspaceSessionProvider(key));
      expect(state.view.columnWidths['comic.title'], 300.0);

      controller.toggleSidebar();
      state = container.read(libraryWorkspaceSessionProvider(key));
      expect(state.view.sidebarVisible, false);
    });

    test('selection actions handle single, multi, and range selection', () {
      controller.selectItem('item-1');
      var state = container.read(libraryWorkspaceSessionProvider(key));
      controller.clearMultiSelection();
      controller.toggleMultiSelection('item-2');
      state = container.read(libraryWorkspaceSessionProvider(key));
      expect(state.selection.selectedIds, {'item-2'});

      controller.toggleMultiSelection('item-3');
      state = container.read(libraryWorkspaceSessionProvider(key));
      expect(state.selection.selectedIds, {'item-2', 'item-3'});

      // Shift-selection
      controller.toggleMultiSelection(
        'item-5',
        isShiftPressed: true,
        allVisibleIds: ['item-1', 'item-2', 'item-3', 'item-4', 'item-5'],
      );
      state = container.read(libraryWorkspaceSessionProvider(key));
      expect(state.selection.selectedIds,
          containsAll(['item-3', 'item-4', 'item-5']));

      controller.clearMultiSelection();
      state = container.read(libraryWorkspaceSessionProvider(key));
      expect(state.selection.selectedIds, isEmpty);
      expect(state.selection.selectedId, isNull);
    });

    test('folder actions handle buckets, collapsed states, and tree nodes', () {
      controller.selectBucket('Marvel');
      var state = container.read(libraryWorkspaceSessionProvider(key));
      expect(state.folder.selectedBucket, 'Marvel');

      controller.toggleBucketCollapsed('Marvel');
      state = container.read(libraryWorkspaceSessionProvider(key));
      expect(state.folder.collapsedBuckets, contains('Marvel'));

      controller.toggleBucketCollapsed('Marvel');
      state = container.read(libraryWorkspaceSessionProvider(key));
      expect(state.folder.collapsedBuckets, isNot(contains('Marvel')));

      controller.toggleFolderTreeNodeExpanded('series-1');
      state = container.read(libraryWorkspaceSessionProvider(key));
      expect(state.folder.treeExpandedNodeIds, contains('series-1'));
    });

    test(
        'preset actions manage pinned folders, column presets, and smart lists',
        () {
      final preset = LibraryFolderPreset(modes: ['publisher']);
      controller.pinFolderPreset(preset);
      var state = container.read(libraryWorkspaceSessionProvider(key));
      expect(state.presets.pinnedFolderPresets, contains(preset));

      controller.unpinFolderPreset(preset);
      state = container.read(libraryWorkspaceSessionProvider(key));
      expect(state.presets.pinnedFolderPresets, isNot(contains(preset)));

      controller.setActiveSmartList('smart-1', 'Unread Comics');
      state = container.read(libraryWorkspaceSessionProvider(key));
      expect(state.presets.activeSmartListId, 'smart-1');
      expect(state.presets.activeSmartListName, 'Unread Comics');

      const colPreset = LibraryTableColumnPreset(
        id: 'col-1',
        label: 'Essential Columns',
        columns: {'comic.title', 'comic.issue_number'},
      );
      controller.saveColumnPreset(colPreset);
      state = container.read(libraryWorkspaceSessionProvider(key));
      expect(state.presets.savedColumnFavoritePresets, contains(colPreset));

      controller.applyColumnPreset(colPreset);
      state = container.read(libraryWorkspaceSessionProvider(key));
      expect(state.filters.visibleColumnIds,
          {'comic.title', 'comic.issue_number'});
    });

    test('async state manages loading, error, and detail hydration', () {
      controller.setLoading(true);
      var state = container.read(libraryWorkspaceSessionProvider(key));
      expect(state.asyncState.isLoading, true);

      controller.setError('Network failure');
      state = container.read(libraryWorkspaceSessionProvider(key));
      expect(state.asyncState.error, 'Network failure');

      controller.addDetailHydrationInFlight('item-99');
      state = container.read(libraryWorkspaceSessionProvider(key));
      expect(state.asyncState.detailHydrationInFlight, contains('item-99'));

      controller.removeDetailHydrationInFlight('item-99');
      state = container.read(libraryWorkspaceSessionProvider(key));
      expect(
          state.asyncState.detailHydrationInFlight, isNot(contains('item-99')));
    });

    test('bulk restore hydrates filters and view config correctly', () {
      controller.restoreFromSavedState(
        filters: const LibrarySessionFilterState(
          searchQuery: 'Batman',
          sortId: 'comic.title',
          sortAscending: false,
        ),
        view: const LibrarySessionViewState(
          viewMode: LibraryViewMode.list,
          coverSize: 220.0,
        ),
      );

      final state = container.read(libraryWorkspaceSessionProvider(key));
      expect(state.filters.searchQuery, 'Batman');
      expect(state.filters.sortId, 'comic.title');
      expect(state.filters.sortAscending, false);
      expect(state.view.viewMode, LibraryViewMode.list);
      expect(state.view.coverSize, 220.0);

      final legacyFilters = container.read(libraryFiltersProvider(key));
      expect(legacyFilters.searchQuery, 'Batman');
      final legacyView = container.read(libraryViewConfigProvider(key));
      expect(legacyView.viewMode, LibraryViewMode.list);
    });
  });
}
