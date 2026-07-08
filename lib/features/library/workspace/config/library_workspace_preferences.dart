import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_pane_widths.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LibraryWorkspacePreferenceSnapshot {
  const LibraryWorkspacePreferenceSnapshot({
    this.browserMode = LibraryWorkspaceBrowserMode.media,
    required this.viewMode,
    required this.detailsLayout,
    required this.isSidebarVisible,
    required this.sortColumn,
    required this.sortAscending,
    this.sortRules,
    required this.coverSize,
    this.densityPreset = LibraryWorkspaceDensityPreset.compact,
    required this.sidebarWidth,
    required this.detailsWidth,
    required this.detailsHeight,
    required this.visibleColumns,
    required this.columnWidths,
  });

  final LibraryWorkspaceBrowserMode browserMode;
  final LibraryViewMode viewMode;
  final LibraryDetailsLayout detailsLayout;
  final bool isSidebarVisible;
  final LibrarySortColumn sortColumn;
  final bool sortAscending;
  final List<LibrarySortRule>? sortRules;
  final double coverSize;
  final LibraryWorkspaceDensityPreset densityPreset;
  final double sidebarWidth;
  final double detailsWidth;
  final double detailsHeight;
  final Set<LibraryTableColumn> visibleColumns;
  final Map<LibraryTableColumn, double> columnWidths;

  LibraryWorkspaceChromePreferenceSnapshot get chrome =>
      LibraryWorkspaceChromePreferenceSnapshot(
        detailsLayout: detailsLayout,
        isSidebarVisible: isSidebarVisible,
        sidebarWidth: sidebarWidth,
        detailsWidth: detailsWidth,
        detailsHeight: detailsHeight,
      );
}

class LibraryWorkspaceChromePreferenceSnapshot {
  const LibraryWorkspaceChromePreferenceSnapshot({
    required this.detailsLayout,
    required this.isSidebarVisible,
    required this.sidebarWidth,
    required this.detailsWidth,
    required this.detailsHeight,
  });

  final LibraryDetailsLayout detailsLayout;
  final bool isSidebarVisible;
  final double sidebarWidth;
  final double detailsWidth;
  final double detailsHeight;
}

class LibraryWorkspacePreferences {
  const LibraryWorkspacePreferences(this.config);

  static final _cachedChromeByConfig =
      <String, LibraryWorkspaceChromePreferenceSnapshot>{};
  static final _cachedSnapshots =
      <String, LibraryWorkspacePreferenceSnapshot>{};

  final LibraryWorkspaceConfig config;

  static LibraryWorkspaceChromePreferenceSnapshot? cachedChromeFor(
    LibraryWorkspaceConfig config,
  ) =>
      _cachedChromeByConfig[config.preferenceKey('')];

  /// Returns the last loaded/written snapshot for [config], or `null` if the
  /// preferences have not been loaded yet for this media type.
  static LibraryWorkspacePreferenceSnapshot? cachedSnapshot(
    LibraryWorkspaceConfig config,
  ) =>
      _cachedSnapshots[config.preferenceKey('')];

  static void resetCachedChromeForTesting() {
    _cachedChromeByConfig.clear();
    _cachedSnapshots.clear();
  }

  Future<LibraryWorkspacePreferenceSnapshot> read({
    required double defaultCoverSize,
    LibraryWorkspaceDensityPreset defaultDensityPreset =
        LibraryWorkspaceDensityPreset.compact,
    double? minCoverSize,
    double? maxCoverSize,
    LibraryViewMode defaultViewMode = LibraryViewMode.grid,
    LibraryDetailsLayout defaultDetailsLayout = LibraryDetailsLayout.right,
    bool defaultSidebarVisible = true,
    bool defaultSortAscending = true,
    double defaultSidebarWidth = kLibrarySidebarDefaultWidth,
    double defaultDetailsWidth = kLibraryDetailsDefaultWidth,
    double defaultDetailsHeight = kLibraryDetailsDefaultHeight,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final coverSize = prefs.getDouble(_key('cover_size')) ?? defaultCoverSize;
    final sidebarWidth =
        prefs.getDouble(_key('sidebar_width')) ?? defaultSidebarWidth;
    final detailsWidth =
        prefs.getDouble(_key('details_width')) ?? defaultDetailsWidth;
    final detailsHeight =
        prefs.getDouble(_key('details_height')) ?? defaultDetailsHeight;
    final sortColumn =
        config.sortColumnFromFieldId(prefs.getString(_key('sort_column'))) ??
            config.defaultSortColumn;
    final sortRules = _decodeSortRules(prefs.getStringList(_key('sort_rules')));
    final visibleColumns = _decodeVisibleColumns(
      prefs.getStringList(_key('visible_columns')),
    );
    final columnWidths = _decodeColumnWidths(
      prefs.getStringList(_key('column_widths')),
    );
    final snapshot = LibraryWorkspacePreferenceSnapshot(
      browserMode: _enumByName(
            LibraryWorkspaceBrowserMode.values,
            prefs.getString(_key('browser_mode')),
          ) ??
          LibraryWorkspaceBrowserMode.media,
      viewMode: _enumByName(
            LibraryViewMode.values,
            prefs.getString(_key('view_mode')),
          ) ??
          defaultViewMode,
      densityPreset: _enumByName(
            config.availableDensityPresets,
            prefs.getString(_key('density_preset')),
          ) ??
          defaultDensityPreset,
      detailsLayout: _enumByName(
            LibraryDetailsLayout.values,
            prefs.getString(_key('details_layout')),
          ) ??
          defaultDetailsLayout,
      isSidebarVisible:
          prefs.getBool(_key('sidebar_visible')) ?? defaultSidebarVisible,
      sortColumn: sortColumn,
      sortAscending:
          prefs.getBool(_key('sort_ascending')) ?? defaultSortAscending,
      sortRules: sortRules,
      coverSize: _clamp(coverSize, minCoverSize, maxCoverSize),
      sidebarWidth: clampLibraryPaneWidth(
        sidebarWidth,
        minWidth: kLibrarySidebarMinWidth,
        maxWidth: kLibraryPaneStoredMaxWidth,
      ),
      detailsWidth: clampLibraryPaneWidth(
        detailsWidth,
        minWidth: kLibraryDetailsMinWidth,
        maxWidth: kLibraryPaneStoredMaxWidth,
      ),
      detailsHeight: clampLibraryPaneHeight(
        detailsHeight,
        minHeight: kLibraryDetailsMinHeight,
        maxHeight: kLibraryPaneStoredMaxWidth,
      ),
      visibleColumns: visibleColumns,
      columnWidths: columnWidths,
    );
    _cachedChromeByConfig[config.preferenceKey('')] = snapshot.chrome;
    _cachedSnapshots[config.preferenceKey('')] = snapshot;
    return snapshot;
  }

  Future<void> write(LibraryWorkspacePreferenceSnapshot snapshot) async {
    final normalizedVisibleColumns = _normalizeVisibleColumns(
      snapshot.visibleColumns,
    );
    final normalizedColumnWidths = _normalizeColumnWidths(
      snapshot.columnWidths,
    );
    final normalizedSortRules = _normalizeSortRules(snapshot.sortRules);
    final normalizedSortColumn = config.supportsSortColumn(snapshot.sortColumn)
        ? snapshot.sortColumn
        : config.defaultSortColumn;
    final normalizedSnapshot = LibraryWorkspacePreferenceSnapshot(
      browserMode: snapshot.browserMode,
      viewMode: snapshot.viewMode,
      detailsLayout: snapshot.detailsLayout,
      isSidebarVisible: snapshot.isSidebarVisible,
      sortColumn: normalizedSortColumn,
      sortAscending: snapshot.sortAscending,
      sortRules: normalizedSortRules,
      coverSize: snapshot.coverSize,
      densityPreset: config.supportsDensityPreset(snapshot.densityPreset)
          ? snapshot.densityPreset
          : config.defaultDensityPreset,
      sidebarWidth: snapshot.sidebarWidth,
      detailsWidth: snapshot.detailsWidth,
      detailsHeight: snapshot.detailsHeight,
      visibleColumns: normalizedVisibleColumns,
      columnWidths: normalizedColumnWidths,
    );
    _cachedChromeByConfig[config.preferenceKey('')] = normalizedSnapshot.chrome;
    _cachedSnapshots[config.preferenceKey('')] = normalizedSnapshot;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key('browser_mode'),
      normalizedSnapshot.browserMode.name,
    );
    await prefs.setString(_key('view_mode'), normalizedSnapshot.viewMode.name);
    await prefs.setString(
      _key('density_preset'),
      normalizedSnapshot.densityPreset.name,
    );
    await prefs.setString(
        _key('details_layout'), normalizedSnapshot.detailsLayout.name);
    await prefs.setBool(
        _key('sidebar_visible'), normalizedSnapshot.isSidebarVisible);
    await prefs.setString(
        _key('sort_column'),
        config.sortColumnFieldId(normalizedSnapshot.sortColumn),
    );
    await prefs.setBool(
        _key('sort_ascending'), normalizedSnapshot.sortAscending);
    await prefs.setStringList(
      _key('sort_rules'),
      _encodeSortRules(normalizedSnapshot.sortRules),
    );
    await prefs.setDouble(_key('cover_size'), normalizedSnapshot.coverSize);
    await prefs.setDouble(
        _key('sidebar_width'), normalizedSnapshot.sidebarWidth);
    await prefs.setDouble(
        _key('details_width'), normalizedSnapshot.detailsWidth);
    await prefs.setDouble(
        _key('details_height'), normalizedSnapshot.detailsHeight);
    await prefs.setStringList(
      _key('visible_columns'),
      normalizedSnapshot.visibleColumns
          .map((column) => config.tableColumnFieldId(column))
          .toList(growable: false),
    );
    await prefs.setStringList(
      _key('column_widths'),
      _encodeColumnWidths(normalizedSnapshot.columnWidths),
    );
  }

  String _key(String suffix) => config.preferenceKey(suffix);

  Set<LibraryTableColumn> _decodeVisibleColumns(List<String>? values) {
    if (values == null || values.isEmpty) {
      return Set.of(config.defaultVisibleColumns);
    }
    final columns = {
      for (final value in values)
        if (config.tableColumnFromFieldId(value) != null)
          config.tableColumnFromFieldId(value)!,
    };
    if (config.supportsTableColumn(LibraryTableColumn.title) &&
        !columns.contains(LibraryTableColumn.title)) {
      columns.add(LibraryTableColumn.title);
    }
    return columns.isEmpty ? Set.of(config.defaultVisibleColumns) : columns;
  }

  List<String> _encodeColumnWidths(Map<LibraryTableColumn, double> widths) {
    return [
      for (final entry in widths.entries)
        '${config.tableColumnFieldId(entry.key)}:${entry.value.round()}',
    ];
  }

  List<String> _encodeSortRules(List<LibrarySortRule>? rules) {
    if (rules == null || rules.isEmpty) {
      return const <String>[];
    }
    return [
      for (final rule in rules)
        '${config.sortColumnFieldId(rule.column)}:${rule.ascending ? 'asc' : 'desc'}',
    ];
  }

  List<LibrarySortRule>? _decodeSortRules(List<String>? values) {
    if (values == null || values.isEmpty) {
      return null;
    }
    final rules = <LibrarySortRule>[];
    for (final value in values) {
      final parts = value.split(':');
      if (parts.length != 2) {
        continue;
      }
      final column =
          config.sortColumnFromFieldId(parts.first);
      if (column == null) {
        continue;
      }
      rules.add(
        LibrarySortRule(
          column: column,
          ascending: parts[1] != 'desc',
        ),
      );
    }
    return rules.isEmpty ? null : rules;
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
      final column =
          config.tableColumnFromFieldId(parts[0]);
      final width = double.tryParse(parts[1]);
      if (column != null && width != null) {
        widths[column] = width;
      }
    }
    return widths;
  }

  Set<LibraryTableColumn> _normalizeVisibleColumns(
    Set<LibraryTableColumn> columns,
  ) {
    final normalized = {
      for (final column in columns)
        if (config.supportsTableColumn(column)) column,
    };
    if (config.supportsTableColumn(LibraryTableColumn.title)) {
      normalized.add(LibraryTableColumn.title);
    }
    return normalized.isEmpty
        ? Set.of(config.defaultVisibleColumns)
        : normalized;
  }

  Map<LibraryTableColumn, double> _normalizeColumnWidths(
    Map<LibraryTableColumn, double> widths,
  ) {
    return {
      for (final entry in widths.entries)
        if (config.supportsTableColumn(entry.key)) entry.key: entry.value,
    };
  }

  List<LibrarySortRule>? _normalizeSortRules(List<LibrarySortRule>? rules) {
    if (rules == null || rules.isEmpty) {
      return null;
    }
    final normalized = <LibrarySortRule>[];
    final seen = <LibrarySortColumn>{};
    for (final rule in rules) {
      if (!config.supportsSortColumn(rule.column) || !seen.add(rule.column)) {
        continue;
      }
      normalized.add(rule);
    }
    return normalized.isEmpty ? null : normalized;
  }

  double _clamp(double value, double? min, double? max) {
    if (min == null || max == null) {
      return value;
    }
    return value.clamp(min, max).toDouble();
  }
}

T? _enumByName<T extends Enum>(List<T> values, Object? rawValue) {
  if (rawValue is! String || rawValue.isEmpty) {
    return null;
  }
  for (final value in values) {
    if (value.name == rawValue) {
      return value;
    }
  }
  return null;
}
