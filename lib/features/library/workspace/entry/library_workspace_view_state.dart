import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_pane_widths.dart';
import 'package:collectarr_app/features/library/workspace/table/library_table_layout.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_preferences.dart';

class LibraryWorkspaceViewPresetConfig {
  const LibraryWorkspaceViewPresetConfig({
    required this.viewMode,
    required this.detailsLayout,
    required this.coverSize,
    required this.visibleColumns,
  });

  final LibraryViewMode viewMode;
  final LibraryDetailsLayout detailsLayout;
  final double coverSize;
  final Set<LibraryTableColumn> visibleColumns;
}

typedef LibraryWorkspacePresetResolver = LibraryWorkspaceViewPresetConfig
    Function(LibraryWorkspacePreset preset);

typedef LibraryTableColumnWidthClamp = double Function(
  LibraryTableColumn column,
  double width,
);

typedef LibrarySortColumnDirectionResolver = bool Function(
  LibrarySortColumn column,
);

class LibraryWorkspaceViewProfile {
  const LibraryWorkspaceViewProfile({
    required this.config,
    required this.defaultCoverSize,
    required this.minCoverSize,
    required this.maxCoverSize,
    required this.presetConfig,
    required this.clampColumnWidth,
    this.defaultSidebarWidth = kLibrarySidebarDefaultWidth,
    this.defaultDetailsWidth = kLibraryDetailsDefaultWidth,
    this.defaultDetailsHeight = kLibraryDetailsDefaultHeight,
    this.defaultViewMode = LibraryViewMode.grid,
    this.defaultDetailsLayout = LibraryDetailsLayout.bottom,
    this.defaultSidebarVisible = true,
    this.defaultSortAscending = true,
    this.hideDetailsWhenSelectionEmpty = false,
    this.sortAscendingForColumn,
  });

  final LibraryWorkspaceConfig config;
  final double defaultCoverSize;
  final double minCoverSize;
  final double maxCoverSize;
  final LibraryWorkspacePresetResolver presetConfig;
  final LibraryTableColumnWidthClamp clampColumnWidth;
  final double defaultSidebarWidth;
  final double defaultDetailsWidth;
  final double defaultDetailsHeight;
  final LibraryViewMode defaultViewMode;
  final LibraryDetailsLayout defaultDetailsLayout;
  final bool defaultSidebarVisible;
  final bool defaultSortAscending;
  final bool hideDetailsWhenSelectionEmpty;
  final LibrarySortColumnDirectionResolver? sortAscendingForColumn;

  LibraryWorkspaceViewState defaults() {
    // Use cached snapshot from a previous load/save when available so that the
    // first frame renders with the user's last-known cover size, avoiding a
    // visible pop-in when the async load completes.
    final cached = LibraryWorkspacePreferences.cachedSnapshot(config);
    if (cached != null) {
      return fromPreferences(cached)
          .withChrome(LibraryWorkspacePreferences.cachedChromeFor(config));
    }
    final defaults = LibraryWorkspaceViewState(
      browserMode: LibraryWorkspaceBrowserMode.media,
      viewMode: defaultViewMode,
      detailsLayout: defaultDetailsLayout,
      isSidebarVisible: defaultSidebarVisible,
      sortColumn: config.defaultSortColumn,
      sortAscending: defaultSortAscending,
      coverSize: defaultCoverSize,
      sidebarWidth: defaultSidebarWidth,
      detailsWidth: defaultDetailsWidth,
      detailsHeight: defaultDetailsHeight,
      visibleColumns: Set.of(config.defaultVisibleColumns),
      columnWidths: const {},
    );
    return defaults.withChrome(LibraryWorkspacePreferences.cachedChromeFor(config));
  }

  LibraryWorkspaceViewState fromPreferences(
    LibraryWorkspacePreferenceSnapshot preferences,
  ) {
    return LibraryWorkspaceViewState(
      browserMode: preferences.browserMode,
      viewMode: preferences.viewMode,
      detailsLayout: preferences.detailsLayout,
      isSidebarVisible: preferences.isSidebarVisible,
      sortColumn: preferences.sortColumn,
      sortAscending: preferences.sortAscending,
      sortRules: preferences.sortRules,
      coverSize: preferences.coverSize,
      sidebarWidth: preferences.sidebarWidth,
      detailsWidth: preferences.detailsWidth,
      detailsHeight: preferences.detailsHeight,
      visibleColumns: preferences.visibleColumns,
      columnWidths: preferences.columnWidths.map(
        (column, width) => MapEntry(column, clampColumnWidth(column, width)),
      ),
    );
  }

  Future<LibraryWorkspaceViewState> load() async {
    final preferences = await LibraryWorkspacePreferences(config).read(
      defaultCoverSize: defaultCoverSize,
      minCoverSize: minCoverSize,
      maxCoverSize: maxCoverSize,
      defaultViewMode: defaultViewMode,
      defaultDetailsLayout: defaultDetailsLayout,
      defaultSidebarVisible: defaultSidebarVisible,
      defaultSortAscending: defaultSortAscending,
      defaultSidebarWidth: defaultSidebarWidth,
      defaultDetailsWidth: defaultDetailsWidth,
      defaultDetailsHeight: defaultDetailsHeight,
    );
    return fromPreferences(preferences);
  }

  Future<void> save(LibraryWorkspaceViewState state) async {
    await LibraryWorkspacePreferences(config).write(
      state.toPreferenceSnapshot(),
    );
  }

  bool initialSortAscending(LibrarySortColumn column) {
    return sortAscendingForColumn?.call(column) ?? defaultSortAscending;
  }
}

class LibraryWorkspaceViewState {
  LibraryWorkspaceViewState({
    this.browserMode = LibraryWorkspaceBrowserMode.media,
    required this.viewMode,
    required this.detailsLayout,
    required this.isSidebarVisible,
    required LibrarySortColumn sortColumn,
    required bool sortAscending,
    List<LibrarySortRule>? sortRules,
    required this.coverSize,
    required this.sidebarWidth,
    required this.detailsWidth,
    required this.detailsHeight,
    required Set<LibraryTableColumn> visibleColumns,
    required Map<LibraryTableColumn, double> columnWidths,
  })  : _sortRules = List.unmodifiable(
          _normalizedSortRules(
            sortRules,
            fallbackColumn: sortColumn,
            fallbackAscending: sortAscending,
          ),
        ),
        visibleColumns = Set.unmodifiable(visibleColumns),
        columnWidths = Map.unmodifiable(columnWidths);

  final LibraryWorkspaceBrowserMode browserMode;
  final LibraryViewMode viewMode;
  final LibraryDetailsLayout detailsLayout;
  final bool isSidebarVisible;
  final List<LibrarySortRule> _sortRules;
  final double coverSize;
  final double sidebarWidth;
  final double detailsWidth;
  final double detailsHeight;
  final Set<LibraryTableColumn> visibleColumns;
  final Map<LibraryTableColumn, double> columnWidths;

  List<LibrarySortRule> get sortRules => _sortRules;

  LibrarySortColumn get sortColumn => _sortRules.first.column;

  bool get sortAscending => _sortRules.first.ascending;

  LibraryWorkspacePreferenceSnapshot toPreferenceSnapshot() {
    return LibraryWorkspacePreferenceSnapshot(
      browserMode: browserMode,
      viewMode: viewMode,
      detailsLayout: detailsLayout,
      isSidebarVisible: isSidebarVisible,
      sortColumn: sortColumn,
      sortAscending: sortAscending,
      sortRules: sortRules,
      coverSize: coverSize,
      sidebarWidth: sidebarWidth,
      detailsWidth: detailsWidth,
      detailsHeight: detailsHeight,
      visibleColumns: visibleColumns,
      columnWidths: columnWidths,
    );
  }

  LibraryWorkspaceViewState copyWith({
    LibraryWorkspaceBrowserMode? browserMode,
    LibraryViewMode? viewMode,
    LibraryDetailsLayout? detailsLayout,
    bool? isSidebarVisible,
    LibrarySortColumn? sortColumn,
    bool? sortAscending,
    List<LibrarySortRule>? sortRules,
    double? coverSize,
    double? sidebarWidth,
    double? detailsWidth,
    double? detailsHeight,
    Set<LibraryTableColumn>? visibleColumns,
    Map<LibraryTableColumn, double>? columnWidths,
  }) {
    final nextSortRules = sortRules ??
        ((sortColumn != null || sortAscending != null)
            ? [
                LibrarySortRule(
                  column: sortColumn ?? this.sortColumn,
                  ascending: sortAscending ?? this.sortAscending,
                ),
                for (final rule in this.sortRules)
                  if (rule.column != (sortColumn ?? this.sortColumn)) rule,
              ]
            : this.sortRules);
    return LibraryWorkspaceViewState(
      browserMode: browserMode ?? this.browserMode,
      viewMode: viewMode ?? this.viewMode,
      detailsLayout: detailsLayout ?? this.detailsLayout,
      isSidebarVisible: isSidebarVisible ?? this.isSidebarVisible,
      sortColumn: sortColumn ?? this.sortColumn,
      sortAscending: sortAscending ?? this.sortAscending,
      sortRules: nextSortRules,
      coverSize: coverSize ?? this.coverSize,
      sidebarWidth: sidebarWidth ?? this.sidebarWidth,
      detailsWidth: detailsWidth ?? this.detailsWidth,
      detailsHeight: detailsHeight ?? this.detailsHeight,
      visibleColumns: visibleColumns ?? this.visibleColumns,
      columnWidths: columnWidths ?? this.columnWidths,
    );
  }

  LibraryWorkspaceViewState withSortColumn(
    LibrarySortColumn column,
    LibraryWorkspaceViewProfile profile,
  ) {
    if (sortColumn == column) {
      return copyWith(sortAscending: !sortAscending);
    }
    final trailingRules = [
      for (final rule in sortRules)
        if (rule.column != column) rule,
    ];
    return copyWith(
      sortColumn: column,
      sortAscending: profile.initialSortAscending(column),
      sortRules: [
        LibrarySortRule(
          column: column,
          ascending: profile.initialSortAscending(column),
        ),
        ...trailingRules,
      ],
    );
  }

  LibraryWorkspaceViewState withSortRules(
    List<LibrarySortRule> rules,
    LibraryWorkspaceViewProfile profile,
  ) {
    final normalized = _normalizedSortRules(
      rules,
      fallbackColumn: sortColumn,
      fallbackAscending: sortAscending,
    );
    return copyWith(
      sortColumn: normalized.first.column,
      sortAscending: normalized.first.ascending,
      sortRules: normalized,
    );
  }

  LibraryWorkspaceViewState withPreset(
    LibraryWorkspacePreset preset,
    LibraryWorkspaceViewProfile profile,
  ) {
    final config = profile.presetConfig(preset);
    return copyWith(
      viewMode: config.viewMode,
      detailsLayout: config.detailsLayout,
      coverSize: config.coverSize,
      visibleColumns: Set.of(config.visibleColumns),
      columnWidths: const {},
    );
  }

  LibraryWorkspaceViewState withChrome(
    LibraryWorkspaceChromePreferenceSnapshot? chrome,
  ) {
    if (chrome == null) {
      return this;
    }
    return copyWith(
      detailsLayout: chrome.detailsLayout,
      isSidebarVisible: chrome.isSidebarVisible,
      sidebarWidth: chrome.sidebarWidth,
      detailsWidth: chrome.detailsWidth,
      detailsHeight: chrome.detailsHeight,
    );
  }

  LibraryWorkspaceViewState withColumnWidth(
    LibraryTableColumn column,
    double width,
    LibraryWorkspaceViewProfile profile,
  ) {
    return copyWith(
      columnWidths: {
        ...columnWidths,
        column: profile.clampColumnWidth(column, width),
      },
    );
  }

  LibraryWorkspaceViewState withReorderedColumn({
    required LibraryTableColumn column,
    required LibraryTableColumn? beforeColumn,
  }) {
    return copyWith(
      visibleColumns: {
        for (final column in reorderLibraryTableColumns(
          columns: visibleColumns,
          column: column,
          beforeColumn: beforeColumn,
        ))
          column,
      },
    );
  }
}

List<LibrarySortRule> _normalizedSortRules(
  List<LibrarySortRule>? rules, {
  required LibrarySortColumn fallbackColumn,
  required bool fallbackAscending,
}) {
  final effective = rules == null || rules.isEmpty
      ? [LibrarySortRule(column: fallbackColumn, ascending: fallbackAscending)]
      : rules;
  final seen = <LibrarySortColumn>{};
  final normalized = <LibrarySortRule>[];
  for (final rule in effective) {
    if (seen.add(rule.column)) {
      normalized.add(rule);
    }
  }
  if (normalized.isEmpty) {
    normalized.add(
      LibrarySortRule(
        column: fallbackColumn,
        ascending: fallbackAscending,
      ),
    );
  }
  return normalized;
}
