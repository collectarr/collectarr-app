import 'package:collectarr_app/features/comics/comics_library_config.dart';
import 'package:collectarr_app/features/comics/comics_workspace_view_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_preferences.dart';

class ComicsWorkspaceViewState {
  ComicsWorkspaceViewState({
    required this.viewMode,
    required this.detailsLayout,
    required this.sortColumn,
    required this.sortAscending,
    required this.coverSize,
    required Set<LibraryTableColumn> visibleColumns,
    required Map<LibraryTableColumn, double> columnWidths,
  })  : visibleColumns = Set.unmodifiable(visibleColumns),
        columnWidths = Map.unmodifiable(columnWidths);

  factory ComicsWorkspaceViewState.defaults() {
    return ComicsWorkspaceViewState(
      viewMode: LibraryViewMode.grid,
      detailsLayout: LibraryDetailsLayout.right,
      sortColumn: comicsWorkspaceConfig.defaultSortColumn,
      sortAscending: true,
      coverSize: kComicsDefaultCoverSize,
      visibleColumns: defaultComicTableColumns(),
      columnWidths: const {},
    );
  }

  factory ComicsWorkspaceViewState.fromPreferences(
    LibraryWorkspacePreferenceSnapshot preferences,
  ) {
    return ComicsWorkspaceViewState(
      viewMode: preferences.viewMode,
      detailsLayout: preferences.detailsLayout,
      sortColumn: preferences.sortColumn,
      sortAscending: preferences.sortAscending,
      coverSize: preferences.coverSize,
      visibleColumns: preferences.visibleColumns,
      columnWidths: preferences.columnWidths.map(
        (column, width) => MapEntry(
          column,
          clampComicTableColumnWidth(column, width),
        ),
      ),
    );
  }

  final LibraryViewMode viewMode;
  final LibraryDetailsLayout detailsLayout;
  final LibrarySortColumn sortColumn;
  final bool sortAscending;
  final double coverSize;
  final Set<LibraryTableColumn> visibleColumns;
  final Map<LibraryTableColumn, double> columnWidths;

  LibraryWorkspacePreferenceSnapshot toPreferenceSnapshot() {
    return LibraryWorkspacePreferenceSnapshot(
      viewMode: viewMode,
      detailsLayout: detailsLayout,
      sortColumn: sortColumn,
      sortAscending: sortAscending,
      coverSize: coverSize,
      visibleColumns: visibleColumns,
      columnWidths: columnWidths,
    );
  }

  ComicsWorkspaceViewState copyWith({
    LibraryViewMode? viewMode,
    LibraryDetailsLayout? detailsLayout,
    LibrarySortColumn? sortColumn,
    bool? sortAscending,
    double? coverSize,
    Set<LibraryTableColumn>? visibleColumns,
    Map<LibraryTableColumn, double>? columnWidths,
  }) {
    return ComicsWorkspaceViewState(
      viewMode: viewMode ?? this.viewMode,
      detailsLayout: detailsLayout ?? this.detailsLayout,
      sortColumn: sortColumn ?? this.sortColumn,
      sortAscending: sortAscending ?? this.sortAscending,
      coverSize: coverSize ?? this.coverSize,
      visibleColumns: visibleColumns ?? this.visibleColumns,
      columnWidths: columnWidths ?? this.columnWidths,
    );
  }

  ComicsWorkspaceViewState withSortColumn(LibrarySortColumn column) {
    if (sortColumn == column) {
      return copyWith(sortAscending: !sortAscending);
    }
    return copyWith(
      sortColumn: column,
      sortAscending: column == LibrarySortColumn.updated ? false : true,
    );
  }

  ComicsWorkspaceViewState withPreset(LibraryWorkspacePreset preset) {
    final config = comicsViewPresetConfig(preset);
    return copyWith(
      viewMode: config.viewMode,
      detailsLayout: config.detailsLayout,
      coverSize: config.coverSize,
      visibleColumns: Set.of(config.visibleColumns),
      columnWidths: const {},
    );
  }

  ComicsWorkspaceViewState withColumnWidth(
    LibraryTableColumn column,
    double width,
  ) {
    return copyWith(
      columnWidths: {
        ...columnWidths,
        column: clampComicTableColumnWidth(column, width),
      },
    );
  }
}

Future<ComicsWorkspaceViewState> loadComicsWorkspaceViewState() async {
  final preferences =
      await LibraryWorkspacePreferences(comicsWorkspaceConfig).read(
    defaultCoverSize: kComicsDefaultCoverSize,
    minCoverSize: kComicsMinCoverSize,
    maxCoverSize: kComicsMaxCoverSize,
  );
  return ComicsWorkspaceViewState.fromPreferences(preferences);
}

Future<void> saveComicsWorkspaceViewState(
  ComicsWorkspaceViewState state,
) async {
  await LibraryWorkspacePreferences(comicsWorkspaceConfig).write(
    state.toPreferenceSnapshot(),
  );
}
