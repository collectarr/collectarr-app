import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'library_workspace_key.dart';
import 'library_filters_provider.dart';
import 'library_view_config_state.dart';
import 'library_view_config_provider.dart';

/// A single facade that the UI uses to dispatch all workspace intent.
///
/// Instead of calling [libraryFiltersProvider] and [libraryViewConfigProvider]
/// separately, widgets read this notifier via [libraryWorkspaceIntentProvider]
/// and call high-level methods. The facade owns the wiring between the two
/// underlying notifiers.
///
/// Usage:
/// ```dart
/// final intent = ref.read(libraryWorkspaceIntentProvider(key));
/// intent.setSort('music.vinyl_color', ascending: true);
/// intent.setViewMode(LibraryViewMode.table);
/// ```
class LibraryWorkspaceIntentNotifier {
  LibraryWorkspaceIntentNotifier(this._ref, this._key);

  final Ref _ref;
  final LibraryWorkspaceKey _key;

  // ── Filter intent ────────────────────────────────────────────────────────

  void setSearch(String query) =>
      _filters.updateSearch(query);

  void clearSearch() => _filters.updateSearch('');

  void setFacetValues(String facetId, Set<String> values) =>
      _filters.setFacetValues(facetId, values);

  void clearFacet(String facetId) => _filters.clearFacet(facetId);

  void clearAllFacets() {
    final current = _ref.read(libraryFiltersProvider(_key));
    for (final facetId in current.facetValues.keys.toList()) {
      _filters.clearFacet(facetId);
    }
  }

  /// Sets [sortId] (a stable string field ID from [AnyLibraryFieldRegistry]).
  /// [ascending] defaults to the sort definition's own [defaultAscending]
  /// when not specified.
  void setSort(String sortId, {bool? ascending}) =>
      _filters.setSort(sortId, ascending: ascending);

  void toggleSortDirection() {
    final current = _ref.read(libraryFiltersProvider(_key));
    _filters.setSort(
      current.sortId ?? '',
      ascending: !current.sortAscending,
    );
  }

  void setGroup(String? groupId) => _filters.setGroup(groupId);

  void setVisibleColumns(Set<String> columnIds) =>
      _filters.setVisibleColumns(columnIds);

  void toggleColumn(String columnId) {
    final current = _ref.read(libraryFiltersProvider(_key));
    final next = Set<String>.from(current.visibleColumnIds);
    if (next.contains(columnId)) {
      next.remove(columnId);
    } else {
      next.add(columnId);
    }
    _filters.setVisibleColumns(next);
  }

  void resetFilters() => _filters.reset();

  // ── View config intent ───────────────────────────────────────────────────

  void setViewMode(LibraryViewMode mode) =>
      _viewConfig.setViewMode(mode);

  void setDetailsLayout(LibraryDetailsLayout layout) =>
      _viewConfig.setDetailsLayout(layout);

  void setCoverSize(double size) =>
      _viewConfig.setCoverSize(size);

  void setDensityPreset(LibraryWorkspaceDensityPreset preset) =>
      _viewConfig.setDensityPreset(preset);

  void toggleSidebar() => _viewConfig.toggleSidebar();

  void setSidebarVisible(bool visible) =>
      _viewConfig.setSidebarVisible(visible);

  void setSidebarWidth(double width) =>
      _viewConfig.setSidebarWidth(width);

  void setDetailsWidth(double width) =>
      _viewConfig.setDetailsWidth(width);

  void setDetailsHeight(double height) =>
      _viewConfig.setDetailsHeight(height);

  void setColumnWidth(String columnId, double width) =>
      _viewConfig.setColumnWidth(columnId, width);

  void resetColumnWidths() => _viewConfig.resetColumnWidths();

  // ── Convenience ──────────────────────────────────────────────────────────

  /// Resets both filter state and view config to defaults for this workspace.
  void resetAll() {
    _filters.reset();
    _viewConfig.restoreFrom(const LibraryViewConfigState());
  }

  // ── Internals ────────────────────────────────────────────────────────────

  LibraryFilters get _filters =>
      _ref.read(libraryFiltersProvider(_key).notifier);

  LibraryViewConfig get _viewConfig =>
      _ref.read(libraryViewConfigProvider(_key).notifier);
}

/// Provider that exposes the [LibraryWorkspaceIntentNotifier] facade for a
/// given [LibraryWorkspaceKey].
///
/// Widgets should `ref.read` (not `ref.watch`) this provider since
/// [LibraryWorkspaceIntentNotifier] is a dispatcher, not a state holder.
final libraryWorkspaceIntentProvider =
    Provider.autoDispose.family<LibraryWorkspaceIntentNotifier, LibraryWorkspaceKey>(
  (ref, LibraryWorkspaceKey key) => LibraryWorkspaceIntentNotifier(ref, key),
);
