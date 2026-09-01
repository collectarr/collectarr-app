import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/generic/page/sidebar_scope_snapshot.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/state/library_workspace_key.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'library_workspace_session_state.dart';

/// Single source of truth managing all library workspace session UI state.
class LibraryWorkspaceSessionController
    extends StateNotifier<LibraryWorkspaceSessionState> {
  LibraryWorkspaceSessionController([this._key])
      : super(const LibraryWorkspaceSessionState()) {
    if (_key != null) {
      _initDefaults();
    }
  }

  final LibraryWorkspaceKey? _key;

  LibraryWorkspaceSessionState get value => state;

  void _initDefaults() {
    if (_key == null) return;
    final module = libraryKindRuntimeForKind(_key.kind);
    state = state.copyWith(
      filters: state.filters.copyWith(
        groupId: () => module.fields.defaultGroup?.value,
        sortId: () => module.fields.defaultSort.value,
        visibleColumnIds: module.fields.defaultVisibleColumns
            .map((column) => column.value)
            .toSet(),
        presentationLevelId: () => _key.presentationLevelId,
      ),
    );
  }

  // ── Search & Filter Actions ────────────────────────────────────────────────

  void updateSearch(String query) {
    state = state.copyWith(
      filters: state.filters.copyWith(
        searchDraft: query,
        searchQuery: query,
      ),
    );
  }

  void clearSearch() => updateSearch('');

  void setFacetValues(String facetId, Set<String> values) {
    final next = Map<String, Set<String>>.from(state.filters.facetValues);
    if (values.isEmpty) {
      next.remove(facetId);
    } else {
      next[facetId] = values;
    }
    state = state.copyWith(
      filters: state.filters.copyWith(facetValues: next),
    );
  }

  void clearFacet(String facetId) {
    final next = Map<String, Set<String>>.from(state.filters.facetValues)
      ..remove(facetId);
    state = state.copyWith(
      filters: state.filters.copyWith(facetValues: next),
    );
  }

  void clearAllFacets() {
    state = state.copyWith(
      filters: state.filters.copyWith(facetValues: const {}),
    );
  }

  void setSort(String sortId, {bool? ascending}) {
    state = state.copyWith(
      filters: state.filters.copyWith(
        sortId: () => sortId,
        sortAscending: ascending ?? state.filters.sortAscending,
      ),
    );
  }

  void updateSort(String sortId, {bool? ascending}) =>
      setSort(sortId, ascending: ascending);

  void toggleSortDirection() {
    final nextAsc = !state.filters.sortAscending;
    setSort(state.filters.sortId ?? '', ascending: nextAsc);
  }

  void setGroup(String? groupId) {
    state = state.copyWith(
      filters: state.filters.copyWith(groupId: () => groupId),
    );
  }

  void updateGroup(String? groupId) => setGroup(groupId);

  void setCollectionStatusScope(LibraryCollectionStatusScope scope) {
    state = state.copyWith(
      filters: state.filters.copyWith(collectionStatusScope: scope),
    );
  }

  void setBucketCompletionScope(LibraryBucketCompletionScope scope) {
    state = state.copyWith(
      filters: state.filters.copyWith(bucketCompletionScope: scope),
    );
  }

  void setSelectedLetter(String? letter) {
    state = state.copyWith(
      filters: state.filters.copyWith(selectedLetter: () => letter),
    );
  }

  void setQuickView(LibraryQuickView? quickView) {
    state = state.copyWith(
      filters: state.filters.copyWith(quickView: () => quickView),
    );
  }

  void setLinkedMetadataFilter(LibraryLinkedMetadataFilter? filter) {
    state = state.copyWith(
      filters: state.filters.copyWith(linkedMetadataFilter: () => filter),
    );
  }

  void setFilterSelection(LibraryFilterSelection selection) {
    state = state.copyWith(
      filters: state.filters.copyWith(filterSelection: selection),
    );
  }

  void resetFilters() {
    if (_key != null) {
      final module = libraryKindRuntimeForKind(_key.kind);
      state = state.copyWith(
        filters: LibrarySessionFilterState(
          groupId: module.fields.defaultGroup?.value,
          sortId: module.fields.defaultSort.value,
          visibleColumnIds: module.fields.defaultVisibleColumns
              .map((column) => column.value)
              .toSet(),
          presentationLevelId: _key.presentationLevelId,
        ),
      );
    } else {
      state = state.copyWith(
        filters: const LibrarySessionFilterState(),
      );
    }
  }

  void reset() {
    state = const LibraryWorkspaceSessionState();
    if (_key != null) {
      _initDefaults();
    }
  }

  // ── View Actions ───────────────────────────────────────────────────────────

  void setViewMode(LibraryViewMode mode) {
    state = state.copyWith(
      view: state.view.copyWith(viewMode: mode),
    );
  }

  void setCoverSize(double size) {
    state = state.copyWith(
      view: state.view.copyWith(coverSize: size),
    );
  }

  void setDetailsLayout(LibraryDetailsLayout layout) {
    state = state.copyWith(
      view: state.view.copyWith(detailsLayout: layout),
    );
  }

  void setDensityPreset(LibraryWorkspaceDensityPreset preset) {
    state = state.copyWith(
      view: state.view.copyWith(densityPreset: preset),
    );
  }

  void toggleSidebar() {
    final next = !state.view.sidebarVisible;
    setSidebarVisible(next);
  }

  void setSidebarVisible(bool visible) {
    state = state.copyWith(
      view: state.view.copyWith(sidebarVisible: visible),
    );
  }

  void setSidebarWidth(double width) {
    state = state.copyWith(
      view: state.view.copyWith(sidebarWidth: width),
    );
  }

  void setDetailsWidth(double width) {
    state = state.copyWith(
      view: state.view.copyWith(detailsWidth: width),
    );
  }

  void setDetailsHeight(double height) {
    state = state.copyWith(
      view: state.view.copyWith(detailsHeight: height),
    );
  }

  void setColumnWidth(String columnId, double width) {
    final next = Map<String, double>.from(state.view.columnWidths);
    next[columnId] = width;
    state = state.copyWith(
      view: state.view.copyWith(columnWidths: next),
    );
  }

  void setVisibleColumns(Set<String> columnIds) {
    state = state.copyWith(
      filters: state.filters.copyWith(visibleColumnIds: columnIds),
    );
  }

  void toggleColumn(String columnId) {
    final current = state.filters.visibleColumnIds;
    final next = Set<String>.from(current);
    if (next.contains(columnId)) {
      next.remove(columnId);
    } else {
      next.add(columnId);
    }
    setVisibleColumns(next);
  }

  void setGroupPresentationOverride(LibraryGroupPresentation? presentation) {
    state = state.copyWith(
      view: state.view.copyWith(
        groupPresentationOverride: () => presentation,
      ),
    );
  }

  // ── Selection Actions ──────────────────────────────────────────────────────

  void selectItem(String? itemId, {bool multiSelect = false}) {
    if (multiSelect && itemId != null) {
      toggleMultiSelection(itemId);
      return;
    }
    state = state.copyWith(
      selection: state.selection.copyWith(
        selectedId: () => itemId,
        selectedIds: itemId == null ? const {} : {itemId},
        anchorId: () => itemId,
      ),
    );
  }

  void toggleMultiSelection(
    String itemId, {
    bool isShiftPressed = false,
    List<String> allVisibleIds = const [],
  }) {
    final currentSelected = Set<String>.from(state.selection.selectedIds);
    final anchor = state.selection.anchorId ?? itemId;

    if (isShiftPressed && allVisibleIds.isNotEmpty) {
      final fromIndex = allVisibleIds.indexOf(anchor);
      final toIndex = allVisibleIds.indexOf(itemId);
      if (fromIndex != -1 && toIndex != -1) {
        final start = fromIndex < toIndex ? fromIndex : toIndex;
        final end = fromIndex < toIndex ? toIndex : fromIndex;
        final rangeIds = allVisibleIds.sublist(start, end + 1);
        currentSelected.addAll(rangeIds);
      } else {
        currentSelected.add(itemId);
      }
    } else {
      if (currentSelected.contains(itemId)) {
        currentSelected.remove(itemId);
      } else {
        currentSelected.add(itemId);
      }
    }

    state = state.copyWith(
      selection: state.selection.copyWith(
        selectedIds: currentSelected,
        selectedId: () => currentSelected.isEmpty
            ? null
            : (currentSelected.contains(itemId)
                ? itemId
                : currentSelected.last),
        anchorId: () => itemId,
      ),
    );
  }

  void clearMultiSelection() {
    state = state.copyWith(
      selection: state.selection.copyWith(
        selectedIds: const {},
        selectedId: () => null,
        anchorId: () => null,
      ),
    );
  }

  void clearSelection() => clearMultiSelection();

  void selectAll(List<String> itemIds) {
    state = state.copyWith(
      selection: state.selection.copyWith(
        selectedIds: itemIds.toSet(),
      ),
    );
  }

  // ── Folder & Navigation Actions ───────────────────────────────────────────

  void selectBucket(String? bucket) {
    state = state.copyWith(
      folder: state.folder.copyWith(selectedBucket: () => bucket),
    );
  }

  void toggleBucketCollapsed(String bucket) {
    final current = Set<String>.from(state.folder.collapsedBuckets);
    if (current.contains(bucket)) {
      current.remove(bucket);
    } else {
      current.add(bucket);
    }
    state = state.copyWith(
      folder: state.folder.copyWith(collapsedBuckets: current),
    );
  }

  void setFolderPreset(LibraryFolderPreset? preset) {
    state = state.copyWith(
      folder: state.folder.copyWith(preset: () => preset),
    );
  }

  void setFolderDisplayMode(LibraryFolderDisplayMode mode) {
    state = state.copyWith(
      folder: state.folder.copyWith(displayMode: mode),
    );
  }

  void setFolder(String? nodeId, {LibraryFolderDisplayMode? displayMode}) {
    setFolderTreeSelectedNode(nodeId);
    if (displayMode != null) {
      setFolderDisplayMode(displayMode);
    }
  }

  void toggleFolderTreeNodeExpanded(String nodeId) {
    final current = Set<String>.from(state.folder.treeExpandedNodeIds);
    if (current.contains(nodeId)) {
      current.remove(nodeId);
    } else {
      current.add(nodeId);
    }
    state = state.copyWith(
      folder: state.folder.copyWith(treeExpandedNodeIds: current),
    );
  }

  void setFolderTreeSelectedNode(String? nodeId) {
    state = state.copyWith(
      folder: state.folder.copyWith(treeSelectedNodeId: () => nodeId),
    );
  }

  void pushScope(LibrarySidebarScopeSnapshot snapshot) {
    final next =
        List<LibrarySidebarScopeSnapshot>.from(state.folder.scopeHistory)
          ..add(snapshot);
    state = state.copyWith(
      folder: state.folder.copyWith(scopeHistory: next),
    );
  }

  LibrarySidebarScopeSnapshot? popScope() {
    if (state.folder.scopeHistory.isEmpty) return null;
    final next =
        List<LibrarySidebarScopeSnapshot>.from(state.folder.scopeHistory);
    final popped = next.removeLast();
    state = state.copyWith(
      folder: state.folder.copyWith(scopeHistory: next),
    );
    return popped;
  }

  // ── Preset Actions ────────────────────────────────────────────────────────

  void setActiveSmartList(String? id, String? name) {
    state = state.copyWith(
      presets: state.presets.copyWith(
        activeSmartListId: () => id,
        activeSmartListName: () => name,
      ),
    );
  }

  void applyPreset(LibraryWorkspacePreset preset) {
    switch (preset) {
      case LibraryWorkspacePreset.cover:
        setViewMode(LibraryViewMode.grid);
      case LibraryWorkspacePreset.card:
        setViewMode(LibraryViewMode.card);
      case LibraryWorkspacePreset.list:
        setViewMode(LibraryViewMode.list);
      case LibraryWorkspacePreset.details:
        setDetailsLayout(LibraryDetailsLayout.right);
    }
  }

  void pinFolderPreset(LibraryFolderPreset preset) {
    final next =
        List<LibraryFolderPreset>.from(state.presets.pinnedFolderPresets);
    if (!next.contains(preset)) {
      next.add(preset);
      state = state.copyWith(
        presets: state.presets.copyWith(pinnedFolderPresets: next),
      );
    }
  }

  void unpinFolderPreset(LibraryFolderPreset preset) {
    final next =
        List<LibraryFolderPreset>.from(state.presets.pinnedFolderPresets)
          ..remove(preset);
    state = state.copyWith(
      presets: state.presets.copyWith(pinnedFolderPresets: next),
    );
  }

  void pinSortFavorite(String sortId) {
    final next = Set<String>.from(state.presets.pinnedSortFavoriteIds)
      ..add(sortId);
    state = state.copyWith(
      presets: state.presets.copyWith(pinnedSortFavoriteIds: next),
    );
  }

  void unpinSortFavorite(String sortId) {
    final next = Set<String>.from(state.presets.pinnedSortFavoriteIds)
      ..remove(sortId);
    state = state.copyWith(
      presets: state.presets.copyWith(pinnedSortFavoriteIds: next),
    );
  }

  void pinColumnFavorite(String columnKey) {
    final next = Set<String>.from(state.presets.pinnedColumnFavoriteKeys)
      ..add(columnKey);
    state = state.copyWith(
      presets: state.presets.copyWith(pinnedColumnFavoriteKeys: next),
    );
  }

  void unpinColumnFavorite(String columnKey) {
    final next = Set<String>.from(state.presets.pinnedColumnFavoriteKeys)
      ..remove(columnKey);
    state = state.copyWith(
      presets: state.presets.copyWith(pinnedColumnFavoriteKeys: next),
    );
  }

  void pinViewPreset(LibraryWorkspacePreset preset) {
    final next =
        Set<LibraryWorkspacePreset>.from(state.presets.pinnedViewPresets)
          ..add(preset);
    state = state.copyWith(
      presets: state.presets.copyWith(pinnedViewPresets: next),
    );
  }

  void unpinViewPreset(LibraryWorkspacePreset preset) {
    final next =
        Set<LibraryWorkspacePreset>.from(state.presets.pinnedViewPresets)
          ..remove(preset);
    state = state.copyWith(
      presets: state.presets.copyWith(pinnedViewPresets: next),
    );
  }

  void saveColumnPreset(LibraryTableColumnPreset preset) {
    final next = List<LibraryTableColumnPreset>.from(
        state.presets.savedColumnFavoritePresets)
      ..removeWhere((p) => p.id == preset.id)
      ..add(preset);
    state = state.copyWith(
      presets: state.presets.copyWith(savedColumnFavoritePresets: next),
    );
  }

  void deleteColumnPreset(String presetId) {
    final next = List<LibraryTableColumnPreset>.from(
        state.presets.savedColumnFavoritePresets)
      ..removeWhere((p) => p.id == presetId);
    state = state.copyWith(
      presets: state.presets.copyWith(savedColumnFavoritePresets: next),
    );
  }

  void applyColumnPreset(LibraryTableColumnPreset preset) {
    setVisibleColumns(preset.columns.toSet());
  }

  // ── Async State Actions ───────────────────────────────────────────────────

  void setLoading(bool loading) {
    state = state.copyWith(
      asyncState: state.asyncState.copyWith(isLoading: loading),
    );
  }

  void setError(Object? error) {
    state = state.copyWith(
      asyncState:
          state.asyncState.copyWith(error: () => error, isLoading: false),
    );
  }

  void reload() {
    state = state.copyWith(
      asyncState:
          state.asyncState.copyWith(error: () => null, isLoading: false),
    );
  }

  void addDetailHydrationInFlight(String id) {
    final next = Set<String>.from(state.asyncState.detailHydrationInFlight)
      ..add(id);
    state = state.copyWith(
      asyncState: state.asyncState.copyWith(detailHydrationInFlight: next),
    );
  }

  void removeDetailHydrationInFlight(String id) {
    final next = Set<String>.from(state.asyncState.detailHydrationInFlight)
      ..remove(id);
    state = state.copyWith(
      asyncState: state.asyncState.copyWith(detailHydrationInFlight: next),
    );
  }

  void setActiveLoanOwnedItemIds(Set<String> ids) {
    state = state.copyWith(
      asyncState: state.asyncState.copyWith(activeLoanOwnedItemIds: ids),
    );
  }

  // ── Bulk Restore ──────────────────────────────────────────────────────────

  void bulkRestore({
    LibrarySessionFilterState? filters,
    LibrarySessionViewState? view,
    LibrarySessionFolderState? folder,
    LibrarySessionPresetState? presets,
  }) {
    state = state.copyWith(
      filters: filters ?? state.filters,
      view: view ?? state.view,
      folder: folder ?? state.folder,
      presets: presets ?? state.presets,
    );
  }

  void restoreFromSavedState({
    LibrarySessionFilterState? filters,
    LibrarySessionViewState? view,
    LibrarySessionFolderState? folder,
    LibrarySessionPresetState? presets,
  }) =>
      bulkRestore(
        filters: filters,
        view: view,
        folder: folder,
        presets: presets,
      );
}

/// Provider for the unified library workspace session controller.
final libraryWorkspaceSessionProvider = StateNotifierProvider.family<
    LibraryWorkspaceSessionController,
    LibraryWorkspaceSessionState,
    LibraryWorkspaceKey>((ref, LibraryWorkspaceKey key) {
  return LibraryWorkspaceSessionController(key);
});
