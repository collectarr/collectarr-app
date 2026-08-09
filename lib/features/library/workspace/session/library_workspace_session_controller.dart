import 'package:flutter/foundation.dart';
import 'package:collectarr_app/features/library/selection/library_selection_state.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'library_workspace_session_state.dart';

class LibraryWorkspaceSessionController
    extends ValueNotifier<LibraryWorkspaceSessionState> {
  LibraryWorkspaceSessionController({
    LibraryWorkspaceSessionState? initialState,
  }) : super(initialState ?? LibraryWorkspaceSessionState.initial());

  void updateSearch(String query) {
    value = value.copyWith(
      filters: value.filters.copyWith(searchQuery: query),
    );
  }

  void updateSort(String sortId, {bool? ascending}) {
    value = value.copyWith(
      filters: value.filters.copyWith(
        sortId: () => sortId,
        sortAscending: ascending ?? value.filters.sortAscending,
      ),
    );
  }

  void updateGroup(String? groupMode) {
    value = value.copyWith(
      filters: value.filters.copyWith(groupId: () => groupMode),
    );
  }

  void toggleColumn(String columnId) {
    final next = Set<String>.from(value.filters.visibleColumnIds);
    if (next.contains(columnId)) {
      next.remove(columnId);
    } else {
      next.add(columnId);
    }
    value = value.copyWith(
      filters: value.filters.copyWith(visibleColumnIds: next),
    );
  }

  void selectItem(String itemId, {bool multiSelect = false}) {
    final currentSelected = Set<String>.from(value.selection.itemIds);
    if (multiSelect) {
      if (currentSelected.contains(itemId)) {
        currentSelected.remove(itemId);
      } else {
        currentSelected.add(itemId);
      }
    } else {
      currentSelected
        ..clear()
        ..add(itemId);
    }
    value = value.copyWith(
      selection: LibrarySelectionState(
        enabled: currentSelected.isNotEmpty,
        itemIds: currentSelected,
      ),
    );
  }

  void clearSelection() {
    value = value.copyWith(
      selection: LibrarySelectionState.empty(),
    );
  }

  void setFolder(String? folderId, {LibraryFolderDisplayMode? displayMode}) {
    value = value.copyWith(
      folder: value.folder.copyWith(
        selectedNodeId: () => folderId,
        displayMode: displayMode ?? value.folder.displayMode,
      ),
    );
  }

  void applyPreset(LibraryWorkspacePreset preset) {
    final viewMode = switch (preset) {
      LibraryWorkspacePreset.cover => LibraryViewMode.grid,
      LibraryWorkspacePreset.card => LibraryViewMode.card,
      LibraryWorkspacePreset.list => LibraryViewMode.list,
      LibraryWorkspacePreset.details => LibraryViewMode.grid,
    };
    value = value.copyWith(
      view: value.view.copyWith(
        viewMode: viewMode,
      ),
    );
  }

  void reload() {
    value = value.copyWith(
      asyncState: value.asyncState.copyWith(
        isLoading: true,
        error: () => null,
      ),
    );
    value = value.copyWith(
      asyncState: value.asyncState.copyWith(isLoading: false),
    );
  }

  void setError(String? error) {
    value = value.copyWith(
      asyncState: value.asyncState.copyWith(
        error: () => error,
        isLoading: false,
      ),
    );
  }

  void reset() {
    value = LibraryWorkspaceSessionState.initial();
  }
}
