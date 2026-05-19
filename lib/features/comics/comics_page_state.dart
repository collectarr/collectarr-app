import 'package:collectarr_app/features/comics/comics_filters.dart';
import 'package:collectarr_app/features/comics/comics_page_selection_state.dart';
import 'package:collectarr_app/features/comics/workspace/comics_workspace_projection.dart';
import 'package:collectarr_app/features/comics/workspace/comics_workspace_state.dart';
import 'package:collectarr_app/features/comics/workspace/comics_workspace_view_config.dart';

class ComicsPageUiState {
  const ComicsPageUiState({
    required this.query,
    required this.selectedItemId,
    required this.selectedGroup,
    required this.groupMode,
    required this.workspaceViewState,
    required this.filterSelection,
    required this.selectionState,
  });

  factory ComicsPageUiState.initial() {
    return ComicsPageUiState(
      query: '',
      selectedItemId: null,
      selectedGroup: null,
      groupMode: ComicsShelfGroupMode.series,
      workspaceViewState: comicsWorkspaceViewProfile.defaults(),
      filterSelection: ComicsFilterSelection.none,
      selectionState: ComicsPageSelectionState.empty(),
    );
  }

  final String query;
  final String? selectedItemId;
  final String? selectedGroup;
  final ComicsShelfGroupMode groupMode;
  final ComicsWorkspaceViewState workspaceViewState;
  final ComicsFilterSelection filterSelection;
  final ComicsPageSelectionState selectionState;

  ComicsPageUiState copyWith({
    String? query,
    String? selectedItemId,
    bool clearSelectedItem = false,
    String? selectedGroup,
    bool clearSelectedGroup = false,
    ComicsShelfGroupMode? groupMode,
    ComicsWorkspaceViewState? workspaceViewState,
    ComicsFilterSelection? filterSelection,
    ComicsPageSelectionState? selectionState,
  }) {
    return ComicsPageUiState(
      query: query ?? this.query,
      selectedItemId:
          clearSelectedItem ? null : selectedItemId ?? this.selectedItemId,
      selectedGroup:
          clearSelectedGroup ? null : selectedGroup ?? this.selectedGroup,
      groupMode: groupMode ?? this.groupMode,
      workspaceViewState: workspaceViewState ?? this.workspaceViewState,
      filterSelection: filterSelection ?? this.filterSelection,
      selectionState: selectionState ?? this.selectionState,
    );
  }

  ComicsPageUiState withSearch(String value) {
    return copyWith(
      query: value.trim(),
      clearSelectedItem: true,
      clearSelectedGroup: true,
    );
  }

  ComicsPageUiState withSelectedItem(String itemId) {
    return copyWith(selectedItemId: itemId);
  }

  ComicsPageUiState withSelectedGroup(String group) {
    return copyWith(selectedGroup: group, clearSelectedItem: true);
  }

  ComicsPageUiState withoutSelectedGroup() {
    return copyWith(clearSelectedGroup: true);
  }

  ComicsPageUiState withBarcodeAdded(String itemId) {
    return copyWith(
      query: '',
      selectedItemId: itemId,
      clearSelectedGroup: true,
    );
  }

  ComicsPageUiState withFilterSelection(ComicsFilterSelection next) {
    return copyWith(
      filterSelection: next,
      clearSelectedItem: true,
      clearSelectedGroup: true,
      selectionState: selectionState.clear(),
    );
  }

  ComicsPageUiState withGroupMode(ComicsShelfGroupMode mode) {
    return copyWith(
      groupMode: mode,
      clearSelectedItem: true,
      clearSelectedGroup: true,
    );
  }

  ComicsPageUiState withSelectionToggled(String itemId) {
    return copyWith(selectionState: selectionState.toggle(itemId));
  }

  ComicsPageUiState withSelectionMode(bool enabled) {
    return copyWith(selectionState: selectionState.setEnabled(enabled));
  }

  ComicsPageUiState withoutSelection() {
    return copyWith(selectionState: selectionState.clear());
  }
}
