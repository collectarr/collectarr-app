import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_pane_widths.dart';
import 'package:collectarr_app/features/library/workspace/library_table_layout.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_preferences.dart';

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
    this.defaultViewMode = LibraryViewMode.grid,
    this.defaultDetailsLayout = LibraryDetailsLayout.right,
    this.defaultSortAscending = true,
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
  final LibraryViewMode defaultViewMode;
  final LibraryDetailsLayout defaultDetailsLayout;
  final bool defaultSortAscending;
  final LibrarySortColumnDirectionResolver? sortAscendingForColumn;

  LibraryWorkspaceViewState defaults() {
    final defaults = LibraryWorkspaceViewState(
      viewMode: defaultViewMode,
      detailsLayout: defaultDetailsLayout,
      sortColumn: config.defaultSortColumn,
      sortAscending: defaultSortAscending,
      coverSize: defaultCoverSize,
      sidebarWidth: defaultSidebarWidth,
      detailsWidth: defaultDetailsWidth,
      visibleColumns: Set.of(config.defaultVisibleColumns),
      columnWidths: const {},
    );
    return defaults.withChrome(LibraryWorkspacePreferences.cachedChrome);
  }

  LibraryWorkspaceViewState fromPreferences(
    LibraryWorkspacePreferenceSnapshot preferences,
  ) {
    return LibraryWorkspaceViewState(
      viewMode: preferences.viewMode,
      detailsLayout: preferences.detailsLayout,
      sortColumn: preferences.sortColumn,
      sortAscending: preferences.sortAscending,
      coverSize: preferences.coverSize,
      sidebarWidth: preferences.sidebarWidth,
      detailsWidth: preferences.detailsWidth,
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
      defaultSortAscending: defaultSortAscending,
      defaultSidebarWidth: defaultSidebarWidth,
      defaultDetailsWidth: defaultDetailsWidth,
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
    required this.viewMode,
    required this.detailsLayout,
    required this.sortColumn,
    required this.sortAscending,
    required this.coverSize,
    required this.sidebarWidth,
    required this.detailsWidth,
    required Set<LibraryTableColumn> visibleColumns,
    required Map<LibraryTableColumn, double> columnWidths,
  })  : visibleColumns = Set.unmodifiable(visibleColumns),
        columnWidths = Map.unmodifiable(columnWidths);

  final LibraryViewMode viewMode;
  final LibraryDetailsLayout detailsLayout;
  final LibrarySortColumn sortColumn;
  final bool sortAscending;
  final double coverSize;
  final double sidebarWidth;
  final double detailsWidth;
  final Set<LibraryTableColumn> visibleColumns;
  final Map<LibraryTableColumn, double> columnWidths;

  LibraryWorkspacePreferenceSnapshot toPreferenceSnapshot() {
    return LibraryWorkspacePreferenceSnapshot(
      viewMode: viewMode,
      detailsLayout: detailsLayout,
      sortColumn: sortColumn,
      sortAscending: sortAscending,
      coverSize: coverSize,
      sidebarWidth: sidebarWidth,
      detailsWidth: detailsWidth,
      visibleColumns: visibleColumns,
      columnWidths: columnWidths,
    );
  }

  LibraryWorkspaceViewState copyWith({
    LibraryViewMode? viewMode,
    LibraryDetailsLayout? detailsLayout,
    LibrarySortColumn? sortColumn,
    bool? sortAscending,
    double? coverSize,
    double? sidebarWidth,
    double? detailsWidth,
    Set<LibraryTableColumn>? visibleColumns,
    Map<LibraryTableColumn, double>? columnWidths,
  }) {
    return LibraryWorkspaceViewState(
      viewMode: viewMode ?? this.viewMode,
      detailsLayout: detailsLayout ?? this.detailsLayout,
      sortColumn: sortColumn ?? this.sortColumn,
      sortAscending: sortAscending ?? this.sortAscending,
      coverSize: coverSize ?? this.coverSize,
      sidebarWidth: sidebarWidth ?? this.sidebarWidth,
      detailsWidth: detailsWidth ?? this.detailsWidth,
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
    return copyWith(
      sortColumn: column,
      sortAscending: profile.initialSortAscending(column),
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
      sidebarWidth: chrome.sidebarWidth,
      detailsWidth: chrome.detailsWidth,
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
