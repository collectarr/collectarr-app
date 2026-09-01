import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import '../session/library_workspace_session_controller.dart';
import 'library_workspace_key.dart';

/// Legacy intent facade delegating directly to [LibraryWorkspaceSessionController].
class LibraryWorkspaceIntentNotifier {
  LibraryWorkspaceIntentNotifier(this._ref, this._key);

  final Ref _ref;
  final LibraryWorkspaceKey _key;

  LibraryWorkspaceSessionController get _session =>
      _ref.read(libraryWorkspaceSessionProvider(_key).notifier);

  void setSearch(String query) => _session.updateSearch(query);
  void clearSearch() => _session.clearSearch();
  void setFacetValues(LibraryFacetIdRuntime facetId, Set<String> values) =>
      _session.setFacetValues(facetId, values);
  void clearFacet(LibraryFacetIdRuntime facetId) =>
      _session.clearFacet(facetId);
  void clearAllFacets() => _session.clearAllFacets();
  void setSort(LibrarySortIdRuntime sortId, {bool? ascending}) =>
      _session.setSort(sortId, ascending: ascending);
  void toggleSortDirection() => _session.toggleSortDirection();
  void setGroup(LibraryGroupIdRuntime? groupId) => _session.setGroup(groupId);
  void setVisibleColumns(Set<LibraryFieldIdRuntime> columnIds) =>
      _session.setVisibleColumns(columnIds);
  void toggleColumn(LibraryFieldIdRuntime columnId) =>
      _session.toggleColumn(columnId);
  void resetFilters() => _session.resetFilters();

  void setViewMode(LibraryViewMode mode) => _session.setViewMode(mode);
  void setDetailsLayout(LibraryDetailsLayout layout) =>
      _session.setDetailsLayout(layout);
  void setCoverSize(double size) => _session.setCoverSize(size);
  void setDensityPreset(LibraryWorkspaceDensityPreset preset) =>
      _session.setDensityPreset(preset);
  void toggleSidebar() => _session.toggleSidebar();
  void setSidebarVisible(bool visible) => _session.setSidebarVisible(visible);
  void setSidebarWidth(double width) => _session.setSidebarWidth(width);
  void setDetailsWidth(double width) => _session.setDetailsWidth(width);
  void setDetailsHeight(double height) => _session.setDetailsHeight(height);
  void setColumnWidth(LibraryFieldIdRuntime columnId, double width) =>
      _session.setColumnWidth(columnId, width);
  void resetColumnWidths() =>
      _session.setViewMode(_session.value.view.viewMode);

  void resetAll() => _session.reset();
}

/// Provider exposing [LibraryWorkspaceIntentNotifier].
final libraryWorkspaceIntentProvider = Provider.autoDispose
    .family<LibraryWorkspaceIntentNotifier, LibraryWorkspaceKey>(
  (ref, LibraryWorkspaceKey key) => LibraryWorkspaceIntentNotifier(ref, key),
);
