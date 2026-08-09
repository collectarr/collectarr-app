import 'package:flutter/foundation.dart';
import 'package:collectarr_app/features/library/workspace/state/library_filter_state.dart';
import 'package:collectarr_app/features/library/workspace/state/library_view_config_state.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/selection/library_selection_state.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';

@immutable
final class LibraryFolderState {
  const LibraryFolderState({
    this.activeFolderPreset,
    this.displayMode = LibraryFolderDisplayMode.drilldown,
    this.expandedNodeIds = const <String>{},
    this.selectedNodeId,
    this.releaseFolderTitleItemId,
  });

  final LibraryFolderPreset? activeFolderPreset;
  final LibraryFolderDisplayMode displayMode;
  final Set<String> expandedNodeIds;
  final String? selectedNodeId;
  final String? releaseFolderTitleItemId;

  LibraryFolderState copyWith({
    LibraryFolderPreset? Function()? activeFolderPreset,
    LibraryFolderDisplayMode? displayMode,
    Set<String>? expandedNodeIds,
    String? Function()? selectedNodeId,
    String? Function()? releaseFolderTitleItemId,
  }) {
    return LibraryFolderState(
      activeFolderPreset: activeFolderPreset != null
          ? activeFolderPreset()
          : this.activeFolderPreset,
      displayMode: displayMode ?? this.displayMode,
      expandedNodeIds: expandedNodeIds ?? this.expandedNodeIds,
      selectedNodeId:
          selectedNodeId != null ? selectedNodeId() : this.selectedNodeId,
      releaseFolderTitleItemId: releaseFolderTitleItemId != null
          ? releaseFolderTitleItemId()
          : this.releaseFolderTitleItemId,
    );
  }
}

@immutable
final class LibraryPresetState {
  const LibraryPresetState({
    this.pinnedFolderPresets = const [],
    this.pinnedViewPresets = const {},
    this.pinnedSortFavoriteIds = const {},
    this.pinnedColumnFavoriteKeys = const {},
    this.savedColumnFavoritePresets = const [],
  });

  final List<LibraryFolderPreset> pinnedFolderPresets;
  final Set<LibraryWorkspacePreset> pinnedViewPresets;
  final Set<String> pinnedSortFavoriteIds;
  final Set<String> pinnedColumnFavoriteKeys;
  final List<LibraryTableColumnPreset> savedColumnFavoritePresets;

  LibraryPresetState copyWith({
    List<LibraryFolderPreset>? pinnedFolderPresets,
    Set<LibraryWorkspacePreset>? pinnedViewPresets,
    Set<String>? pinnedSortFavoriteIds,
    Set<String>? pinnedColumnFavoriteKeys,
    List<LibraryTableColumnPreset>? savedColumnFavoritePresets,
  }) {
    return LibraryPresetState(
      pinnedFolderPresets: pinnedFolderPresets ?? this.pinnedFolderPresets,
      pinnedViewPresets: pinnedViewPresets ?? this.pinnedViewPresets,
      pinnedSortFavoriteIds:
          pinnedSortFavoriteIds ?? this.pinnedSortFavoriteIds,
      pinnedColumnFavoriteKeys:
          pinnedColumnFavoriteKeys ?? this.pinnedColumnFavoriteKeys,
      savedColumnFavoritePresets:
          savedColumnFavoritePresets ?? this.savedColumnFavoritePresets,
    );
  }
}

@immutable
final class LibraryAsyncState {
  const LibraryAsyncState({
    this.isLoading = false,
    this.error,
    this.detailHydrationInFlight = const <String>{},
    this.activeLoanOwnedItemIds = const <String>{},
  });

  final bool isLoading;
  final String? error;
  final Set<String> detailHydrationInFlight;
  final Set<String> activeLoanOwnedItemIds;

  LibraryAsyncState copyWith({
    bool? isLoading,
    String? Function()? error,
    Set<String>? detailHydrationInFlight,
    Set<String>? activeLoanOwnedItemIds,
  }) {
    return LibraryAsyncState(
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
      detailHydrationInFlight:
          detailHydrationInFlight ?? this.detailHydrationInFlight,
      activeLoanOwnedItemIds:
          activeLoanOwnedItemIds ?? this.activeLoanOwnedItemIds,
    );
  }
}

@immutable
final class LibraryWorkspaceSessionState {
  const LibraryWorkspaceSessionState({
    required this.filters,
    required this.view,
    required this.selection,
    required this.folder,
    required this.presets,
    required this.asyncState,
  });

  factory LibraryWorkspaceSessionState.initial() {
    return LibraryWorkspaceSessionState(
      filters: const LibraryFilterState(),
      view: const LibraryViewConfigState(),
      selection: LibrarySelectionState.empty(),
      folder: const LibraryFolderState(),
      presets: const LibraryPresetState(),
      asyncState: const LibraryAsyncState(),
    );
  }

  final LibraryFilterState filters;
  final LibraryViewConfigState view;
  final LibrarySelectionState selection;
  final LibraryFolderState folder;
  final LibraryPresetState presets;
  final LibraryAsyncState asyncState;

  LibraryWorkspaceSessionState copyWith({
    LibraryFilterState? filters,
    LibraryViewConfigState? view,
    LibrarySelectionState? selection,
    LibraryFolderState? folder,
    LibraryPresetState? presets,
    LibraryAsyncState? asyncState,
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
}
