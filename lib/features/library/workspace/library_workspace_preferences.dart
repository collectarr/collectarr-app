import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_pane_widths.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LibraryWorkspacePreferenceSnapshot {
  const LibraryWorkspacePreferenceSnapshot({
    required this.viewMode,
    required this.detailsLayout,
    required this.sortColumn,
    required this.sortAscending,
    required this.coverSize,
    required this.sidebarWidth,
    required this.detailsWidth,
    required this.visibleColumns,
    required this.columnWidths,
  });

  final LibraryViewMode viewMode;
  final LibraryDetailsLayout detailsLayout;
  final LibrarySortColumn sortColumn;
  final bool sortAscending;
  final double coverSize;
  final double sidebarWidth;
  final double detailsWidth;
  final Set<LibraryTableColumn> visibleColumns;
  final Map<LibraryTableColumn, double> columnWidths;

  LibraryWorkspaceChromePreferenceSnapshot get chrome =>
      LibraryWorkspaceChromePreferenceSnapshot(
        detailsLayout: detailsLayout,
        sidebarWidth: sidebarWidth,
        detailsWidth: detailsWidth,
      );
}

class LibraryWorkspaceChromePreferenceSnapshot {
  const LibraryWorkspaceChromePreferenceSnapshot({
    required this.detailsLayout,
    required this.sidebarWidth,
    required this.detailsWidth,
  });

  final LibraryDetailsLayout detailsLayout;
  final double sidebarWidth;
  final double detailsWidth;
}

class LibraryWorkspacePreferences {
  const LibraryWorkspacePreferences(this.config);

  static const _globalChromePrefix = 'collectarr.workspace.chrome';
  static LibraryWorkspaceChromePreferenceSnapshot? _cachedChrome;

  final LibraryWorkspaceConfig config;

  static LibraryWorkspaceChromePreferenceSnapshot? get cachedChrome =>
      _cachedChrome;

  static void resetCachedChromeForTesting() {
    _cachedChrome = null;
  }

  Future<LibraryWorkspacePreferenceSnapshot> read({
    required double defaultCoverSize,
    double? minCoverSize,
    double? maxCoverSize,
    LibraryViewMode defaultViewMode = LibraryViewMode.grid,
    LibraryDetailsLayout defaultDetailsLayout = LibraryDetailsLayout.right,
    bool defaultSortAscending = true,
    double defaultSidebarWidth = kLibrarySidebarDefaultWidth,
    double defaultDetailsWidth = kLibraryDetailsDefaultWidth,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final coverSize = prefs.getDouble(_key('cover_size')) ?? defaultCoverSize;
    final sidebarWidth = prefs.getDouble(_globalKey('sidebar_width')) ??
        prefs.getDouble(_key('sidebar_width')) ??
        defaultSidebarWidth;
    final detailsWidth = prefs.getDouble(_globalKey('details_width')) ??
        prefs.getDouble(_key('details_width')) ??
        defaultDetailsWidth;
    final snapshot = LibraryWorkspacePreferenceSnapshot(
      viewMode: _enumByName(
            LibraryViewMode.values,
            prefs.getString(_key('view_mode')),
          ) ??
          defaultViewMode,
      detailsLayout: _enumByName(
            LibraryDetailsLayout.values,
            prefs.getString(_globalKey('details_layout')) ??
                prefs.getString(_key('details_layout')),
          ) ??
          defaultDetailsLayout,
      sortColumn: _enumByName(
            LibrarySortColumn.values,
            prefs.getString(_key('sort_column')),
          ) ??
          config.defaultSortColumn,
      sortAscending:
          prefs.getBool(_key('sort_ascending')) ?? defaultSortAscending,
      coverSize: _clamp(coverSize, minCoverSize, maxCoverSize),
      sidebarWidth: clampLibraryPaneWidth(
        sidebarWidth,
        minWidth: kLibrarySidebarMinWidth,
        maxWidth: kLibrarySidebarMaxWidth,
      ),
      detailsWidth: clampLibraryPaneWidth(
        detailsWidth,
        minWidth: kLibraryDetailsMinWidth,
        maxWidth: kLibraryDetailsMaxWidth,
      ),
      visibleColumns: _decodeVisibleColumns(
        prefs.getStringList(_key('visible_columns')),
      ),
      columnWidths: _decodeColumnWidths(
        prefs.getStringList(_key('column_widths')),
      ),
    );
    _cachedChrome = snapshot.chrome;
    return snapshot;
  }

  Future<void> write(LibraryWorkspacePreferenceSnapshot snapshot) async {
    _cachedChrome = snapshot.chrome;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key('view_mode'), snapshot.viewMode.name);
    await prefs.setString(
      _globalKey('details_layout'),
      snapshot.detailsLayout.name,
    );
    await prefs.setString(_key('sort_column'), snapshot.sortColumn.name);
    await prefs.setBool(_key('sort_ascending'), snapshot.sortAscending);
    await prefs.setDouble(_key('cover_size'), snapshot.coverSize);
    await prefs.setDouble(_globalKey('sidebar_width'), snapshot.sidebarWidth);
    await prefs.setDouble(_globalKey('details_width'), snapshot.detailsWidth);
    await prefs.setStringList(
      _key('visible_columns'),
      snapshot.visibleColumns
          .map((column) => column.name)
          .toList(growable: false),
    );
    await prefs.setStringList(
      _key('column_widths'),
      _encodeColumnWidths(snapshot.columnWidths),
    );
  }

  String _key(String suffix) => config.preferenceKey(suffix);

  String _globalKey(String suffix) => '$_globalChromePrefix.$suffix';

  Set<LibraryTableColumn> _decodeVisibleColumns(List<String>? values) {
    if (values == null || values.isEmpty) {
      return Set.of(config.defaultVisibleColumns);
    }
    final columns = {
      for (final value in values)
        if (_enumByName(LibraryTableColumn.values, value) != null)
          _enumByName(LibraryTableColumn.values, value)!,
    };
    if (!columns.contains(LibraryTableColumn.title)) {
      columns.add(LibraryTableColumn.title);
    }
    return columns.isEmpty ? Set.of(config.defaultVisibleColumns) : columns;
  }

  List<String> _encodeColumnWidths(Map<LibraryTableColumn, double> widths) {
    return [
      for (final entry in widths.entries)
        '${entry.key.name}:${entry.value.round()}',
    ];
  }

  Map<LibraryTableColumn, double> _decodeColumnWidths(List<String>? values) {
    if (values == null || values.isEmpty) {
      return const {};
    }
    final widths = <LibraryTableColumn, double>{};
    for (final value in values) {
      final parts = value.split(':');
      if (parts.length != 2) {
        continue;
      }
      final column = _enumByName(LibraryTableColumn.values, parts[0]);
      final width = double.tryParse(parts[1]);
      if (column != null && width != null) {
        widths[column] = width;
      }
    }
    return widths;
  }

  T? _enumByName<T extends Enum>(List<T> values, String? name) {
    if (name == null) {
      return null;
    }
    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }
    return null;
  }

  double _clamp(double value, double? min, double? max) {
    if (min == null || max == null) {
      return value;
    }
    return value.clamp(min, max).toDouble();
  }
}
