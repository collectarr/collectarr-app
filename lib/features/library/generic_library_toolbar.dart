import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/library/generic_library_compact_toolbar.dart';
import 'package:collectarr_app/features/library/generic_library_projection.dart';
import 'package:collectarr_app/features/library/generic_library_tools_menu.dart';
import 'package:collectarr_app/features/library/library_media_adapter.dart';
import 'package:collectarr_app/features/library/library_type_config.dart';
import 'package:collectarr_app/features/library/selection/library_selection_controls.dart';
import 'package:collectarr_app/features/library/workspace/library_view_table_controls.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_chrome.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_control_models.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_view_state.dart';
import 'package:flutter/material.dart';

class GenericLibraryToolbar extends StatelessWidget {
  const GenericLibraryToolbar({
    super.key,
    required this.type,
    required this.searchController,
    required this.viewState,
    required this.adapter,
    required this.counts,
    required this.onAdd,
    required this.onScan,
    required this.onSearchChanged,
    required this.onEditColumns,
    required this.onSortChanged,
    required this.onViewModeChanged,
    required this.onDetailsLayoutChanged,
    required this.onViewPresetSelected,
    required this.onCoverSizeChanged,
    required this.selectedBucket,
    required this.onClearBucket,
    required this.onRefreshMetadata,
    required this.quickView,
    required this.onQuickViewSelected,
    required this.hasActiveFilters,
    required this.onClearFilters,
    this.onRandomPick,
    this.selectionEnabled = false,
    this.selectedCount = 0,
    this.selectionCallbacks,
  });

  final LibraryTypeConfig type;
  final TextEditingController searchController;
  final LibraryWorkspaceViewState viewState;
  final LibraryMediaAdapter adapter;
  final GenericToolbarCounts counts;
  final VoidCallback onAdd;
  final VoidCallback onScan;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onEditColumns;
  final ValueChanged<LibrarySortColumn> onSortChanged;
  final ValueChanged<LibraryViewMode> onViewModeChanged;
  final ValueChanged<LibraryDetailsLayout> onDetailsLayoutChanged;
  final ValueChanged<LibraryWorkspacePreset> onViewPresetSelected;
  final ValueChanged<double> onCoverSizeChanged;
  final String? selectedBucket;
  final VoidCallback onClearBucket;
  final VoidCallback onRefreshMetadata;
  final GenericQuickView? quickView;
  final ValueChanged<GenericQuickView> onQuickViewSelected;
  final bool hasActiveFilters;
  final VoidCallback onClearFilters;
  final VoidCallback? onRandomPick;
  final bool selectionEnabled;
  final int selectedCount;
  final LibrarySelectionCallbacks? selectionCallbacks;

  @override
  Widget build(BuildContext context) {
    return LibraryToolbarFrame(
      backgroundColor: kClzToolbar,
      dividerColor: kClzDivider,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 760) {
            return GenericCompactLibraryToolbar(
              type: type,
              searchController: searchController,
              counts: counts,
              selectedBucket: selectedBucket,
              onAdd: onAdd,
              onScan: onScan,
              onSearchChanged: onSearchChanged,
              onRefreshMetadata: onRefreshMetadata,
              onViewPresetSelected: onViewPresetSelected,
              onCoverSizeChanged: onCoverSizeChanged,
              quickView: quickView,
              onQuickViewSelected: onQuickViewSelected,
              hasActiveFilters: hasActiveFilters,
              onClearFilters: onClearFilters,
              onRandomPick: onRandomPick,
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              children: [
                LibraryToolbarPrimaryActions(
                  addLabel: 'Add ${type.pluralLabel}',
                  onAdd: onAdd,
                  onScanBarcode: onScan,
                  onRefreshMetadata: onRefreshMetadata,
                  addBackgroundColor: kClzYellow,
                  addForegroundColor: const Color(0xFF151515),
                ),
                const LibraryWorkspaceSeparator(color: kClzDivider),
                LibraryToolbarSearch(
                  controller: searchController,
                  hintText: 'Search ${type.pluralLabel.toLowerCase()}...',
                  selectedFilterLabel: selectedBucket,
                  onSearch: onSearchChanged,
                  onClearFilter: onClearBucket,
                  onChanged: onSearchChanged,
                  selectionColor: kClzSelection,
                ),
                const LibraryWorkspaceSeparator(color: kClzDivider),
                if (selectionCallbacks != null)
                  LibrarySelectionControls(
                    enabled: selectionEnabled,
                    selectedCount: selectedCount,
                    callbacks: selectionCallbacks!,
                  ),
                if (selectionCallbacks != null)
                  const LibraryWorkspaceSeparator(color: kClzDivider),
                LibraryWorkspaceControlStrip(
                  children: [
                    GenericLibraryToolsButton(
                      type: type,
                      counts: counts,
                      selectedBucket: selectedBucket,
                      quickView: quickView,
                      hasActiveFilters: hasActiveFilters,
                      onQuickViewSelected: onQuickViewSelected,
                      onClearFilters: onClearFilters,
                      onRandomPick: onRandomPick,
                    ),
                    LibraryViewTableControls(
                      state: LibraryViewTableControlState(
                        counts: LibraryWorkspaceCounts(
                          shown: counts.shown,
                          total: counts.total,
                        ),
                        viewMode: viewState.viewMode,
                        detailsLayout: viewState.detailsLayout,
                        coverSize: viewState.coverSize,
                        minCoverSize: adapter.viewProfile.minCoverSize,
                        maxCoverSize: adapter.viewProfile.maxCoverSize,
                      ),
                      callbacks: LibraryViewTableControlCallbacks(
                        onEditColumns: onEditColumns,
                        onViewModeChanged: onViewModeChanged,
                        onDetailsLayoutChanged: onDetailsLayoutChanged,
                        onViewPresetSelected: onViewPresetSelected,
                        onCoverSizeChanged: onCoverSizeChanged,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
