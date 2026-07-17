import 'package:flutter_riverpod/legacy.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'library_workspace_key.dart';
import 'library_view_config_state.dart';

/// [StateNotifier] that owns all visual workspace configuration: view mode,
/// cover size, details layout, sidebar, column widths.
///
/// Distinct from [LibraryFilters] which owns sort/group/filter choices.
/// Both providers are scoped to the same [LibraryWorkspaceKey] so they stay
/// in sync for a single workspace context.
class LibraryViewConfig extends StateNotifier<LibraryViewConfigState> {
  LibraryViewConfig(this.key) : super(const LibraryViewConfigState());

  final LibraryWorkspaceKey key;

  void setViewMode(LibraryViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  void setDetailsLayout(LibraryDetailsLayout layout) {
    state = state.copyWith(detailsLayout: layout);
  }

  void setCoverSize(double size) {
    state = state.copyWith(coverSize: size);
  }

  void setDensityPreset(LibraryWorkspaceDensityPreset preset) {
    state = state.copyWith(densityPreset: preset);
  }

  void toggleSidebar() {
    state = state.copyWith(isSidebarVisible: !state.isSidebarVisible);
  }

  void setSidebarVisible(bool visible) {
    state = state.copyWith(isSidebarVisible: visible);
  }

  void setSidebarWidth(double width) {
    state = state.copyWith(sidebarWidth: width);
  }

  void setDetailsWidth(double width) {
    state = state.copyWith(detailsWidth: width);
  }

  void setDetailsHeight(double height) {
    state = state.copyWith(detailsHeight: height);
  }

  void setColumnWidth(String columnId, double width) {
    final next = Map<String, double>.from(state.columnWidths)
      ..[columnId] = width;
    state = state.copyWith(columnWidths: next);
  }

  void resetColumnWidths() {
    state = state.copyWith(columnWidths: const {});
  }

  /// Bulk restore from a previously persisted snapshot.
  void restoreFrom(LibraryViewConfigState saved) {
    state = saved;
  }
}

final libraryViewConfigProvider = StateNotifierProvider.family<
    LibraryViewConfig, LibraryViewConfigState, LibraryWorkspaceKey>(
  (ref, LibraryWorkspaceKey key) => LibraryViewConfig(key),
);
