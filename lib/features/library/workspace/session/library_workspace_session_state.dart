import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/generic/page/sidebar_scope_snapshot.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:flutter/foundation.dart';

// ─── Filter Subsection ───────────────────────────────────────────────────────

@immutable
final class LibrarySessionFilterState {
  const LibrarySessionFilterState({
    this.searchQuery = '',
    this.searchDraft = '',
    this.facetValues = const {},
    this.groupId,
    this.sortId,
    this.sortAscending = true,
    this.visibleColumnIds = const {},
    this.presentationLevelId,
    this.collectionStatusScope = LibraryCollectionStatusScope.all,
    this.bucketCompletionScope = LibraryBucketCompletionScope.all,
    this.selectedLetter,
    this.quickView,
    this.linkedMetadataFilter,
    this.filterSelection = LibraryFilterSelection.none,
  });

  final String searchQuery;
  final String searchDraft;
  final Map<LibraryFacetIdRuntime, Set<String>> facetValues;
  final LibraryGroupIdRuntime? groupId;
  final LibrarySortIdRuntime? sortId;
  final bool sortAscending;
  final Set<LibraryFieldIdRuntime> visibleColumnIds;
  final String? presentationLevelId;
  final LibraryCollectionStatusScope collectionStatusScope;
  final LibraryBucketCompletionScope bucketCompletionScope;
  final String? selectedLetter;
  final LibraryQuickView? quickView;
  final LibraryLinkedMetadataFilter? linkedMetadataFilter;
  final LibraryFilterSelection filterSelection;

  LibrarySessionFilterState copyWith({
    String? searchQuery,
    String? searchDraft,
    Map<LibraryFacetIdRuntime, Set<String>>? facetValues,
    LibraryGroupIdRuntime? Function()? groupId,
    LibrarySortIdRuntime? Function()? sortId,
    bool? sortAscending,
    Set<LibraryFieldIdRuntime>? visibleColumnIds,
    String? Function()? presentationLevelId,
    LibraryCollectionStatusScope? collectionStatusScope,
    LibraryBucketCompletionScope? bucketCompletionScope,
    String? Function()? selectedLetter,
    LibraryQuickView? Function()? quickView,
    LibraryLinkedMetadataFilter? Function()? linkedMetadataFilter,
    LibraryFilterSelection? filterSelection,
  }) {
    return LibrarySessionFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      searchDraft: searchDraft ?? this.searchDraft,
      facetValues: facetValues ?? this.facetValues,
      groupId: groupId != null ? groupId() : this.groupId,
      sortId: sortId != null ? sortId() : this.sortId,
      sortAscending: sortAscending ?? this.sortAscending,
      visibleColumnIds: visibleColumnIds ?? this.visibleColumnIds,
      presentationLevelId: presentationLevelId != null
          ? presentationLevelId()
          : this.presentationLevelId,
      collectionStatusScope:
          collectionStatusScope ?? this.collectionStatusScope,
      bucketCompletionScope:
          bucketCompletionScope ?? this.bucketCompletionScope,
      selectedLetter:
          selectedLetter != null ? selectedLetter() : this.selectedLetter,
      quickView: quickView != null ? quickView() : this.quickView,
      linkedMetadataFilter: linkedMetadataFilter != null
          ? linkedMetadataFilter()
          : this.linkedMetadataFilter,
      filterSelection: filterSelection ?? this.filterSelection,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibrarySessionFilterState &&
          runtimeType == other.runtimeType &&
          searchQuery == other.searchQuery &&
          searchDraft == other.searchDraft &&
          mapEquals(facetValues, other.facetValues) &&
          groupId == other.groupId &&
          sortId == other.sortId &&
          sortAscending == other.sortAscending &&
          setEquals(visibleColumnIds, other.visibleColumnIds) &&
          presentationLevelId == other.presentationLevelId &&
          collectionStatusScope == other.collectionStatusScope &&
          bucketCompletionScope == other.bucketCompletionScope &&
          selectedLetter == other.selectedLetter &&
          quickView == other.quickView &&
          linkedMetadataFilter == other.linkedMetadataFilter &&
          filterSelection == other.filterSelection;

  @override
  int get hashCode => Object.hash(
        searchQuery,
        searchDraft,
        Object.hashAll(facetValues.entries
            .map((e) => Object.hash(e.key, Object.hashAll(e.value)))),
        groupId,
        sortId,
        sortAscending,
        Object.hashAll(visibleColumnIds),
        presentationLevelId,
        collectionStatusScope,
        bucketCompletionScope,
        selectedLetter,
        quickView,
        linkedMetadataFilter,
        filterSelection,
      );
}

// ─── View Subsection ─────────────────────────────────────────────────────────

@immutable
final class LibrarySessionViewState {
  const LibrarySessionViewState({
    this.viewMode = LibraryViewMode.grid,
    this.coverSize = 180.0,
    this.detailsLayout = LibraryDetailsLayout.right,
    this.densityPreset = LibraryWorkspaceDensityPreset.comfortable,
    this.sidebarVisible = true,
    this.sidebarWidth = 260.0,
    this.detailsWidth = 360.0,
    this.detailsHeight = 240.0,
    this.columnWidths = const {},
    this.groupPresentationOverride,
  });

  final LibraryViewMode viewMode;
  final double coverSize;
  final LibraryDetailsLayout detailsLayout;
  final LibraryWorkspaceDensityPreset densityPreset;
  final bool sidebarVisible;
  final double sidebarWidth;
  final double detailsWidth;
  final double detailsHeight;
  final Map<LibraryFieldIdRuntime, double> columnWidths;
  final LibraryGroupPresentation? groupPresentationOverride;

  LibrarySessionViewState copyWith({
    LibraryViewMode? viewMode,
    double? coverSize,
    LibraryDetailsLayout? detailsLayout,
    LibraryWorkspaceDensityPreset? densityPreset,
    bool? sidebarVisible,
    double? sidebarWidth,
    double? detailsWidth,
    double? detailsHeight,
    Map<LibraryFieldIdRuntime, double>? columnWidths,
    LibraryGroupPresentation? Function()? groupPresentationOverride,
  }) {
    return LibrarySessionViewState(
      viewMode: viewMode ?? this.viewMode,
      coverSize: coverSize ?? this.coverSize,
      detailsLayout: detailsLayout ?? this.detailsLayout,
      densityPreset: densityPreset ?? this.densityPreset,
      sidebarVisible: sidebarVisible ?? this.sidebarVisible,
      sidebarWidth: sidebarWidth ?? this.sidebarWidth,
      detailsWidth: detailsWidth ?? this.detailsWidth,
      detailsHeight: detailsHeight ?? this.detailsHeight,
      columnWidths: columnWidths ?? this.columnWidths,
      groupPresentationOverride: groupPresentationOverride != null
          ? groupPresentationOverride()
          : this.groupPresentationOverride,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibrarySessionViewState &&
          runtimeType == other.runtimeType &&
          viewMode == other.viewMode &&
          coverSize == other.coverSize &&
          detailsLayout == other.detailsLayout &&
          densityPreset == other.densityPreset &&
          sidebarVisible == other.sidebarVisible &&
          sidebarWidth == other.sidebarWidth &&
          detailsWidth == other.detailsWidth &&
          detailsHeight == other.detailsHeight &&
          mapEquals(columnWidths, other.columnWidths) &&
          groupPresentationOverride == other.groupPresentationOverride;

  @override
  int get hashCode => Object.hash(
        viewMode,
        coverSize,
        detailsLayout,
        densityPreset,
        sidebarVisible,
        sidebarWidth,
        detailsWidth,
        detailsHeight,
        Object.hashAll(columnWidths.entries),
        groupPresentationOverride,
      );
}

// ─── Selection Subsection ───────────────────────────────────────────────────

@immutable
final class LibrarySessionSelectionState {
  const LibrarySessionSelectionState({
    this.selectedId,
    this.selectedIds = const {},
    this.anchorId,
  });

  final String? selectedId;
  final Set<String> selectedIds;
  final String? anchorId;

  /// Compatibility alias for [selectedIds].
  Set<String> get itemIds => selectedIds;

  bool get isMultiSelecting => selectedIds.isNotEmpty;
  int get selectedCount => selectedIds.length;

  LibrarySessionSelectionState copyWith({
    String? Function()? selectedId,
    Set<String>? selectedIds,
    String? Function()? anchorId,
  }) {
    return LibrarySessionSelectionState(
      selectedId: selectedId != null ? selectedId() : this.selectedId,
      selectedIds: selectedIds ?? this.selectedIds,
      anchorId: anchorId != null ? anchorId() : this.anchorId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibrarySessionSelectionState &&
          runtimeType == other.runtimeType &&
          selectedId == other.selectedId &&
          setEquals(selectedIds, other.selectedIds) &&
          anchorId == other.anchorId;

  @override
  int get hashCode => Object.hash(
        selectedId,
        Object.hashAll(selectedIds),
        anchorId,
      );
}

// ─── Folder Subsection ──────────────────────────────────────────────────────

@immutable
final class LibrarySessionFolderState {
  const LibrarySessionFolderState({
    this.selectedBucket,
    this.preset,
    this.collapsedBuckets = const {},
    this.displayMode = LibraryFolderDisplayMode.drilldown,
    this.treeExpandedNodeIds = const {},
    this.treeSelectedNodeId,
    this.scopeHistory = const [],
  });

  final String? selectedBucket;
  final LibraryFolderPreset? preset;
  final Set<String> collapsedBuckets;
  final LibraryFolderDisplayMode displayMode;
  final Set<String> treeExpandedNodeIds;
  final String? treeSelectedNodeId;
  final List<LibrarySidebarScopeSnapshot> scopeHistory;

  LibrarySessionFolderState copyWith({
    String? Function()? selectedBucket,
    LibraryFolderPreset? Function()? preset,
    Set<String>? collapsedBuckets,
    LibraryFolderDisplayMode? displayMode,
    Set<String>? treeExpandedNodeIds,
    String? Function()? treeSelectedNodeId,
    List<LibrarySidebarScopeSnapshot>? scopeHistory,
  }) {
    return LibrarySessionFolderState(
      selectedBucket:
          selectedBucket != null ? selectedBucket() : this.selectedBucket,
      preset: preset != null ? preset() : this.preset,
      collapsedBuckets: collapsedBuckets ?? this.collapsedBuckets,
      displayMode: displayMode ?? this.displayMode,
      treeExpandedNodeIds: treeExpandedNodeIds ?? this.treeExpandedNodeIds,
      treeSelectedNodeId: treeSelectedNodeId != null
          ? treeSelectedNodeId()
          : this.treeSelectedNodeId,
      scopeHistory: scopeHistory ?? this.scopeHistory,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibrarySessionFolderState &&
          runtimeType == other.runtimeType &&
          selectedBucket == other.selectedBucket &&
          preset == other.preset &&
          setEquals(collapsedBuckets, other.collapsedBuckets) &&
          displayMode == other.displayMode &&
          setEquals(treeExpandedNodeIds, other.treeExpandedNodeIds) &&
          treeSelectedNodeId == other.treeSelectedNodeId &&
          listEquals(scopeHistory, other.scopeHistory);

  @override
  int get hashCode => Object.hash(
        selectedBucket,
        preset,
        Object.hashAll(collapsedBuckets),
        displayMode,
        Object.hashAll(treeExpandedNodeIds),
        treeSelectedNodeId,
        Object.hashAll(scopeHistory),
      );
}

// ─── Presets Subsection ─────────────────────────────────────────────────────

@immutable
final class LibrarySessionPresetState {
  const LibrarySessionPresetState({
    this.pinnedFolderPresets = const [],
    this.activeSmartListId,
    this.activeSmartListName,
    this.pinnedViewPresets = const {},
    this.pinnedSortFavoriteIds = const {},
    this.pinnedColumnFavoriteKeys = const {},
    this.savedColumnFavoritePresets = const [],
  });

  final List<LibraryFolderPreset> pinnedFolderPresets;
  final String? activeSmartListId;
  final String? activeSmartListName;
  final Set<LibraryWorkspacePreset> pinnedViewPresets;
  final Set<String> pinnedSortFavoriteIds;
  final Set<String> pinnedColumnFavoriteKeys;
  final List<LibraryTableColumnPreset> savedColumnFavoritePresets;

  LibrarySessionPresetState copyWith({
    List<LibraryFolderPreset>? pinnedFolderPresets,
    String? Function()? activeSmartListId,
    String? Function()? activeSmartListName,
    Set<LibraryWorkspacePreset>? pinnedViewPresets,
    Set<String>? pinnedSortFavoriteIds,
    Set<String>? pinnedColumnFavoriteKeys,
    List<LibraryTableColumnPreset>? savedColumnFavoritePresets,
  }) {
    return LibrarySessionPresetState(
      pinnedFolderPresets: pinnedFolderPresets ?? this.pinnedFolderPresets,
      activeSmartListId: activeSmartListId != null
          ? activeSmartListId()
          : this.activeSmartListId,
      activeSmartListName: activeSmartListName != null
          ? activeSmartListName()
          : this.activeSmartListName,
      pinnedViewPresets: pinnedViewPresets ?? this.pinnedViewPresets,
      pinnedSortFavoriteIds:
          pinnedSortFavoriteIds ?? this.pinnedSortFavoriteIds,
      pinnedColumnFavoriteKeys:
          pinnedColumnFavoriteKeys ?? this.pinnedColumnFavoriteKeys,
      savedColumnFavoritePresets:
          savedColumnFavoritePresets ?? this.savedColumnFavoritePresets,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibrarySessionPresetState &&
          runtimeType == other.runtimeType &&
          listEquals(pinnedFolderPresets, other.pinnedFolderPresets) &&
          activeSmartListId == other.activeSmartListId &&
          activeSmartListName == other.activeSmartListName &&
          setEquals(pinnedViewPresets, other.pinnedViewPresets) &&
          setEquals(pinnedSortFavoriteIds, other.pinnedSortFavoriteIds) &&
          setEquals(pinnedColumnFavoriteKeys, other.pinnedColumnFavoriteKeys) &&
          listEquals(
              savedColumnFavoritePresets, other.savedColumnFavoritePresets);

  @override
  int get hashCode => Object.hash(
        Object.hashAll(pinnedFolderPresets),
        activeSmartListId,
        activeSmartListName,
        Object.hashAll(pinnedViewPresets),
        Object.hashAll(pinnedSortFavoriteIds),
        Object.hashAll(pinnedColumnFavoriteKeys),
        Object.hashAll(savedColumnFavoritePresets),
      );
}

// ─── Async State Subsection ──────────────────────────────────────────────────

@immutable
final class LibrarySessionAsyncState {
  const LibrarySessionAsyncState({
    this.isLoading = false,
    this.error,
    this.detailHydrationInFlight = const {},
    this.activeLoanOwnedItemIds = const {},
  });

  final bool isLoading;
  final Object? error;
  final Set<String> detailHydrationInFlight;
  final Set<String> activeLoanOwnedItemIds;

  LibrarySessionAsyncState copyWith({
    bool? isLoading,
    Object? Function()? error,
    Set<String>? detailHydrationInFlight,
    Set<String>? activeLoanOwnedItemIds,
  }) {
    return LibrarySessionAsyncState(
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
      detailHydrationInFlight:
          detailHydrationInFlight ?? this.detailHydrationInFlight,
      activeLoanOwnedItemIds:
          activeLoanOwnedItemIds ?? this.activeLoanOwnedItemIds,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibrarySessionAsyncState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          error == other.error &&
          setEquals(detailHydrationInFlight, other.detailHydrationInFlight) &&
          setEquals(activeLoanOwnedItemIds, other.activeLoanOwnedItemIds);

  @override
  int get hashCode => Object.hash(
        isLoading,
        error,
        Object.hashAll(detailHydrationInFlight),
        Object.hashAll(activeLoanOwnedItemIds),
      );
}

// ─── Master Unified Session State ────────────────────────────────────────────

@immutable
final class LibraryWorkspaceSessionState {
  const LibraryWorkspaceSessionState({
    this.filters = const LibrarySessionFilterState(),
    this.view = const LibrarySessionViewState(),
    this.selection = const LibrarySessionSelectionState(),
    this.folder = const LibrarySessionFolderState(),
    this.presets = const LibrarySessionPresetState(),
    this.asyncState = const LibrarySessionAsyncState(),
  });

  final LibrarySessionFilterState filters;
  final LibrarySessionViewState view;
  final LibrarySessionSelectionState selection;
  final LibrarySessionFolderState folder;
  final LibrarySessionPresetState presets;
  final LibrarySessionAsyncState asyncState;

  LibraryWorkspaceSessionState copyWith({
    LibrarySessionFilterState? filters,
    LibrarySessionViewState? view,
    LibrarySessionSelectionState? selection,
    LibrarySessionFolderState? folder,
    LibrarySessionPresetState? presets,
    LibrarySessionAsyncState? asyncState,
  }) {
    return LibraryWorkspaceSessionState(
      filters: filters ?? this.filters,
      view: view ?? this.view,
      selection: selection ?? this.selection,
      folder: folder ?? this.folder,
      presets: presets ?? this.presets,
      asyncState: asyncState ?? this.asyncState,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryWorkspaceSessionState &&
          runtimeType == other.runtimeType &&
          filters == other.filters &&
          view == other.view &&
          selection == other.selection &&
          folder == other.folder &&
          presets == other.presets &&
          asyncState == other.asyncState;

  @override
  int get hashCode => Object.hash(
        filters,
        view,
        selection,
        folder,
        presets,
        asyncState,
      );
}
