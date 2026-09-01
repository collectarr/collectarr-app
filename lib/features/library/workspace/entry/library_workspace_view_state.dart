import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_pane_widths.dart';
import 'package:collectarr_app/features/library/workspace/table/library_table_layout.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_preferences.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';

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
  final Set<LibraryFieldIdRuntime> visibleColumns;
}

typedef LibraryWorkspacePresetResolver = LibraryWorkspaceViewPresetConfig
    Function(LibraryWorkspacePreset preset);

typedef LibraryTableColumnWidthClamp = double Function(
  LibraryFieldIdRuntime column,
  double width,
);

typedef LibrarySortColumnDirectionResolver = bool Function(
  LibrarySortIdRuntime column,
);

class LibraryWorkspaceViewProfile {
  const LibraryWorkspaceViewProfile({
    required this.runtimeResolver,
    required this.defaultCoverSize,
    required this.minCoverSize,
    required this.maxCoverSize,
    required this.presetConfig,
    required this.clampColumnWidth,
    this.coverGridHeightFactor = 1.53,
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

  final LibraryKindRuntime Function() runtimeResolver;
  final double defaultCoverSize;
  final double minCoverSize;
  final double maxCoverSize;
  final double coverGridHeightFactor;
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

  double clampCoverSize(double value) =>
      value.clamp(minCoverSize, maxCoverSize);

  LibraryWorkspaceViewState defaults() {
    // Use cached snapshot from a previous load/save when available so that the
    // first frame renders with the user's last-known cover size, avoiding a
    // visible pop-in when the async load completes.
    final runtime = runtimeResolver();
    final cached = LibraryWorkspacePreferences.cachedSnapshot(runtime);
    if (cached != null) {
      return fromPreferences(cached)
          .withChrome(LibraryWorkspacePreferences.cachedChromeFor(runtime));
    }
    final defaults = LibraryWorkspaceViewState(
      browserMode: LibraryWorkspaceBrowserMode.media,
      viewMode: defaultViewMode,
      detailsLayout: defaultDetailsLayout,
      isSidebarVisible: defaultSidebarVisible,
      sortId: runtime.fields.defaultSort,
      sortAscending: defaultSortAscending,
      coverSize: defaultCoverSize,
      sidebarWidth: defaultSidebarWidth,
      detailsWidth: defaultDetailsWidth,
      detailsHeight: defaultDetailsHeight,
      densityPreset: runtime.identity.defaultDensityPreset,
      visibleColumnIds: runtime.fields.defaultVisibleColumns,
      columnWidths: const {},
    );
    return defaults
        .withChrome(LibraryWorkspacePreferences.cachedChromeFor(runtime));
  }

  LibraryWorkspaceViewState fromPreferences(
    LibraryWorkspacePreferenceSnapshot preferences,
  ) {
    final runtime = runtimeResolver();
    return LibraryWorkspaceViewState(
      browserMode: preferences.browserMode,
      viewMode: preferences.viewMode,
      detailsLayout: preferences.detailsLayout,
      isSidebarVisible: preferences.isSidebarVisible,
      sortId: runtime.fields
              .findSortDefinition(
                runtime.fields.decodeSortId(preferences.sortColumn),
              )
              ?.id ??
          runtime.fields.defaultSort,
      sortAscending: preferences.sortAscending,
      sortRules: _decodeSortRules(runtime, preferences.sortRules),
      coverSize: preferences.coverSize,
      sidebarWidth: preferences.sidebarWidth,
      detailsWidth: preferences.detailsWidth,
      detailsHeight: preferences.detailsHeight,
      densityPreset: preferences.densityPreset,
      visibleColumnIds:
          _decodeVisibleColumns(runtime, preferences.visibleColumns),
      columnWidths: _decodeColumnWidths(runtime, preferences.columnWidths).map(
        (column, width) => MapEntry(column, clampColumnWidth(column, width)),
      ),
    );
  }

  Future<LibraryWorkspaceViewState> load() async {
    final runtime = runtimeResolver();
    final preferences = await LibraryWorkspacePreferences(runtime).read(
      defaultCoverSize: defaultCoverSize,
      defaultDensityPreset: runtime.identity.defaultDensityPreset,
    );
    return fromPreferenceSnapshot(preferences);
  }

  LibraryWorkspaceViewState fromPreferenceSnapshot(
    LibraryWorkspacePreferenceSnapshot snapshot,
  ) {
    return fromPreferences(snapshot).copyWith(
      coverSize: clampCoverSize(snapshot.coverSize),
    );
  }

  Future<void> save(LibraryWorkspaceViewState state) async {
    await LibraryWorkspacePreferences(runtimeResolver()).write(
      state.toPreferenceSnapshot(),
    );
  }

  bool initialSortAscending(LibrarySortIdRuntime sortId) {
    return sortAscendingForColumn?.call(sortId) ?? defaultSortAscending;
  }

  List<LibrarySortRuleRuntime> decodeSortRules(
    Iterable<LibrarySortRule> rules,
  ) {
    return _decodeSortRules(runtimeResolver(), rules);
  }

  Set<LibraryFieldIdRuntime> decodeColumnIds(Iterable<String> columns) {
    return _decodeVisibleColumns(runtimeResolver(), columns);
  }
}

class LibraryWorkspaceViewState {
  LibraryWorkspaceViewState({
    this.browserMode = LibraryWorkspaceBrowserMode.media,
    required this.viewMode,
    required this.detailsLayout,
    required this.isSidebarVisible,
    required LibrarySortIdRuntime sortId,
    required bool sortAscending,
    List<LibrarySortRuleRuntime>? sortRules,
    required this.coverSize,
    required this.sidebarWidth,
    required this.detailsWidth,
    required this.detailsHeight,
    this.densityPreset = LibraryWorkspaceDensityPreset.compact,
    required Set<LibraryFieldIdRuntime> visibleColumnIds,
    required Map<LibraryFieldIdRuntime, double> columnWidths,
  })  : _sortRules = List.unmodifiable(
          _normalizedSortRules(
            sortRules,
            fallbackSortId: sortId,
            fallbackAscending: sortAscending,
          ),
        ),
        visibleColumnIds = Set.unmodifiable(visibleColumnIds),
        columnWidths = Map.unmodifiable(columnWidths);

  final LibraryWorkspaceBrowserMode browserMode;
  final LibraryViewMode viewMode;
  final LibraryDetailsLayout detailsLayout;
  final bool isSidebarVisible;
  final List<LibrarySortRuleRuntime> _sortRules;
  final double coverSize;
  final double sidebarWidth;
  final double detailsWidth;
  final double detailsHeight;
  final LibraryWorkspaceDensityPreset densityPreset;
  final Set<LibraryFieldIdRuntime> visibleColumnIds;
  final Map<LibraryFieldIdRuntime, double> columnWidths;

  List<LibrarySortRuleRuntime> get sortRules => _sortRules;

  LibrarySortIdRuntime get sortId => _sortRules.first.sortId;

  bool get sortAscending => _sortRules.first.ascending;

  LibraryWorkspacePreferenceSnapshot toPreferenceSnapshot() {
    return LibraryWorkspacePreferenceSnapshot(
      browserMode: browserMode,
      viewMode: viewMode,
      detailsLayout: detailsLayout,
      isSidebarVisible: isSidebarVisible,
      sortColumn: sortId.value,
      sortAscending: sortAscending,
      sortRules: [
        for (final rule in sortRules)
          LibrarySortRule(
            column: rule.sortId.value,
            ascending: rule.ascending,
          ),
      ],
      coverSize: coverSize,
      sidebarWidth: sidebarWidth,
      detailsWidth: detailsWidth,
      detailsHeight: detailsHeight,
      densityPreset: densityPreset,
      visibleColumns: {
        for (final column in visibleColumnIds) column.value,
      },
      columnWidths: {
        for (final entry in columnWidths.entries) entry.key.value: entry.value,
      },
    );
  }

  LibraryWorkspaceViewState copyWith({
    LibraryWorkspaceBrowserMode? browserMode,
    LibraryViewMode? viewMode,
    LibraryDetailsLayout? detailsLayout,
    bool? isSidebarVisible,
    LibrarySortIdRuntime? sortId,
    bool? sortAscending,
    List<LibrarySortRuleRuntime>? sortRules,
    double? coverSize,
    double? sidebarWidth,
    double? detailsWidth,
    double? detailsHeight,
    LibraryWorkspaceDensityPreset? densityPreset,
    Set<LibraryFieldIdRuntime>? visibleColumnIds,
    Map<LibraryFieldIdRuntime, double>? columnWidths,
  }) {
    final nextSortRules = sortRules ??
        ((sortId != null || sortAscending != null)
            ? [
                LibrarySortRuleRuntime(
                  sortId: sortId ?? this.sortId,
                  ascending: sortAscending ?? this.sortAscending,
                ),
                for (final rule in this.sortRules)
                  if (rule.sortId != (sortId ?? this.sortId)) rule,
              ]
            : this.sortRules);
    return LibraryWorkspaceViewState(
      browserMode: browserMode ?? this.browserMode,
      viewMode: viewMode ?? this.viewMode,
      detailsLayout: detailsLayout ?? this.detailsLayout,
      isSidebarVisible: isSidebarVisible ?? this.isSidebarVisible,
      sortId: sortId ?? this.sortId,
      sortAscending: sortAscending ?? this.sortAscending,
      sortRules: nextSortRules,
      coverSize: coverSize ?? this.coverSize,
      sidebarWidth: sidebarWidth ?? this.sidebarWidth,
      detailsWidth: detailsWidth ?? this.detailsWidth,
      detailsHeight: detailsHeight ?? this.detailsHeight,
      densityPreset: densityPreset ?? this.densityPreset,
      visibleColumnIds: visibleColumnIds ?? this.visibleColumnIds,
      columnWidths: columnWidths ?? this.columnWidths,
    );
  }

  LibraryWorkspaceViewState withSortColumn(
    LibrarySortIdRuntime sortId,
    LibraryWorkspaceViewProfile profile,
  ) {
    if (sortId == this.sortId) {
      return copyWith(sortAscending: !sortAscending);
    }
    final trailingRules = [
      for (final rule in sortRules)
        if (rule.sortId != sortId) rule,
    ];
    return copyWith(
      sortId: sortId,
      sortAscending: profile.initialSortAscending(sortId),
      sortRules: [
        LibrarySortRuleRuntime(
          sortId: sortId,
          ascending: profile.initialSortAscending(sortId),
        ),
        ...trailingRules,
      ],
    );
  }

  LibraryWorkspaceViewState withSortRules(
    List<LibrarySortRuleRuntime> rules,
    LibraryWorkspaceViewProfile profile,
  ) {
    final normalized = _normalizedSortRules(
      rules,
      fallbackSortId: sortId,
      fallbackAscending: sortAscending,
    );
    return copyWith(
      sortId: normalized.first.sortId,
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
      densityPreset: densityPreset,
      visibleColumnIds: Set.of(config.visibleColumns),
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
    LibraryFieldIdRuntime column,
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
    required LibraryFieldIdRuntime column,
    required LibraryFieldIdRuntime? beforeColumn,
  }) {
    return copyWith(
      visibleColumnIds: {
        for (final column in reorderLibraryTableColumns(
          columns: visibleColumnIds,
          column: column,
          beforeColumn: beforeColumn,
        ))
          column,
      },
    );
  }
}

List<LibrarySortRuleRuntime> _normalizedSortRules(
  List<LibrarySortRuleRuntime>? rules, {
  required LibrarySortIdRuntime fallbackSortId,
  required bool fallbackAscending,
}) {
  final effective = rules == null || rules.isEmpty
      ? [
          LibrarySortRuleRuntime(
            sortId: fallbackSortId,
            ascending: fallbackAscending,
          ),
        ]
      : rules;
  final seen = <LibrarySortIdRuntime>{};
  final normalized = <LibrarySortRuleRuntime>[];
  for (final rule in effective) {
    if (seen.add(rule.sortId)) {
      normalized.add(rule);
    }
  }
  if (normalized.isEmpty) {
    normalized.add(
      LibrarySortRuleRuntime(
        sortId: fallbackSortId,
        ascending: fallbackAscending,
      ),
    );
  }
  return normalized;
}

List<LibrarySortRuleRuntime> _decodeSortRules(
  LibraryKindRuntime module,
  Iterable<LibrarySortRule>? rules,
) {
  if (rules == null) {
    return const [];
  }
  return [
    for (final rule in rules)
      if (module.fields.findSortDefinition(
        module.fields.decodeSortId(rule.column),
      )
          case final definition?)
        LibrarySortRuleRuntime(
          sortId: definition.id,
          ascending: rule.ascending,
        ),
  ];
}

Set<LibraryFieldIdRuntime> _decodeVisibleColumns(
  LibraryKindRuntime module,
  Iterable<String> columns,
) {
  final decoded = <LibraryFieldIdRuntime>{};
  for (final column in columns) {
    final definition = module.fields.findColumnDefinition(
      module.fields.decodeColumnId(column),
    );
    if (definition != null) {
      decoded.add(definition.id);
    }
  }
  return decoded.isEmpty ? module.fields.defaultVisibleColumns : decoded;
}

Map<LibraryFieldIdRuntime, double> _decodeColumnWidths(
  LibraryKindRuntime module,
  Map<String, double> widths,
) {
  final decoded = <LibraryFieldIdRuntime, double>{};
  for (final entry in widths.entries) {
    final definition = module.fields.findColumnDefinition(
      module.fields.decodeColumnId(entry.key),
    );
    if (definition != null) {
      decoded[definition.id] = entry.value;
    }
  }
  return decoded;
}
