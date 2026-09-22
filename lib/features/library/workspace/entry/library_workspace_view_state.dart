import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_pane_widths.dart';
import 'package:collectarr_app/features/library/workspace/table/library_table_layout.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_preferences.dart';
import 'package:collectarr_app/features/library/config/library_browser_navigation_policy.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_field_registry.dart';

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

enum LibraryWorkspaceCardLayout {
  standard,
  coverFocused,
}

class LibraryWorkspaceViewProfile {
  const LibraryWorkspaceViewProfile({
    required this.registrationResolver,
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
    this.cardLayout = LibraryWorkspaceCardLayout.standard,
    this.sortAscendingForColumn,
  });

  final LibraryKindRegistration Function() registrationResolver;
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
  final LibraryWorkspaceCardLayout cardLayout;
  final LibrarySortColumnDirectionResolver? sortAscendingForColumn;

  double clampCoverSize(double value) =>
      value.clamp(minCoverSize, maxCoverSize);

  LibraryWorkspaceViewState defaults() {
    // Use cached snapshot from a previous load/save when available so that the
    // first frame renders with the user's last-known cover size, avoiding a
    // visible pop-in when the async load completes.
    final registration = registrationResolver();
    final workspace = libraryKindWorkspaceForKind(registration.kind);
    final cached = LibraryWorkspacePreferences.cachedSnapshot(registration);
    if (cached != null) {
      return fromPreferences(cached).withChrome(
          LibraryWorkspacePreferences.cachedChromeFor(registration));
    }
    final defaults = LibraryWorkspaceViewState(
      browserMode: LibraryWorkspaceBrowserMode.work,
      viewMode: defaultViewMode,
      detailsLayout: defaultDetailsLayout,
      isSidebarVisible: defaultSidebarVisible,
      sortId: workspace.fields.defaultSort,
      sortAscending: defaultSortAscending,
      coverSize: defaultCoverSize,
      sidebarWidth: defaultSidebarWidth,
      detailsWidth: defaultDetailsWidth,
      detailsHeight: defaultDetailsHeight,
      densityPreset: registration.identity.defaultDensityPreset,
      visibleColumnIds: workspace.fields.defaultVisibleColumns,
      columnWidths: const {},
    );
    return defaults
        .withChrome(LibraryWorkspacePreferences.cachedChromeFor(registration));
  }

  LibraryWorkspaceViewState fromPreferences(
    LibraryWorkspacePreferenceSnapshot preferences,
  ) {
    final registration = registrationResolver();
    final workspace = libraryKindWorkspaceForKind(registration.kind);
    final fields = workspace.fieldsForScope(
      libraryBrowserNavigationPolicy.entityScopeForBrowserMode(
        preferences.browserMode,
      ),
    );
    return LibraryWorkspaceViewState(
      browserMode: preferences.browserMode,
      viewMode: preferences.viewMode,
      detailsLayout: preferences.detailsLayout,
      isSidebarVisible: preferences.isSidebarVisible,
      sortId: fields
              .findSortDefinition(fields.decodeSortId(preferences.sortColumn))
              ?.id ??
          fields.defaultSort,
      sortAscending: preferences.sortAscending,
      sortRules: _decodeSortRules(fields, preferences.sortRules),
      coverSize: preferences.coverSize,
      sidebarWidth: preferences.sidebarWidth,
      detailsWidth: preferences.detailsWidth,
      detailsHeight: preferences.detailsHeight,
      densityPreset: preferences.densityPreset,
      visibleColumnIds:
          _decodeVisibleColumns(fields, preferences.visibleColumns),
      columnWidths: _decodeColumnWidths(fields, preferences.columnWidths).map(
        (column, width) => MapEntry(column, clampColumnWidth(column, width)),
      ),
    );
  }

  Future<LibraryWorkspaceViewState> load() async {
    final registration = registrationResolver();
    final preferences = await LibraryWorkspacePreferences(registration).read(
      defaultCoverSize: defaultCoverSize,
      defaultDensityPreset: registration.identity.defaultDensityPreset,
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
    await LibraryWorkspacePreferences(registrationResolver()).write(
      state.toPreferenceSnapshot(),
    );
  }

  bool initialSortAscending(LibrarySortIdRuntime sortId) {
    return sortAscendingForColumn?.call(sortId) ?? defaultSortAscending;
  }

  List<LibrarySortRuleRuntime> decodeSortRules(
    Iterable<LibrarySortRule> rules,
  ) {
    return _decodeSortRules(
      libraryKindWorkspaceForKind(registrationResolver().kind).fields,
      rules,
    );
  }

  Set<LibraryFieldIdRuntime> decodeColumnIds(Iterable<String> columns) {
    return _decodeVisibleColumns(
      libraryKindWorkspaceForKind(registrationResolver().kind).fields,
      columns,
    );
  }
}

class LibraryWorkspaceViewState {
  LibraryWorkspaceViewState({
    this.browserMode = LibraryWorkspaceBrowserMode.work,
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
  LibraryFieldRegistry<LibraryWorkspaceDto> fields,
  Iterable<LibrarySortRule>? rules,
) {
  if (rules == null) {
    return const [];
  }
  return [
    for (final rule in rules)
      if (fields.findSortDefinition(
        fields.decodeSortId(rule.column),
      )
          case final definition?)
        LibrarySortRuleRuntime(
          sortId: definition.id,
          ascending: rule.ascending,
        ),
  ];
}

Set<LibraryFieldIdRuntime> _decodeVisibleColumns(
  LibraryFieldRegistry<LibraryWorkspaceDto> fields,
  Iterable<String> columns,
) {
  final decoded = <LibraryFieldIdRuntime>{};
  for (final column in columns) {
    final definition = fields.findColumnDefinition(
      fields.decodeColumnId(column),
    );
    if (definition != null) {
      decoded.add(definition.id);
    }
  }
  return decoded.isEmpty ? fields.defaultVisibleColumns : decoded;
}

Map<LibraryFieldIdRuntime, double> _decodeColumnWidths(
  LibraryFieldRegistry<LibraryWorkspaceDto> fields,
  Map<String, double> widths,
) {
  final decoded = <LibraryFieldIdRuntime, double>{};
  for (final entry in widths.entries) {
    final definition = fields.findColumnDefinition(
      fields.decodeColumnId(entry.key),
    );
    if (definition != null) {
      decoded[definition.id] = entry.value;
    }
  }
  return decoded;
}
