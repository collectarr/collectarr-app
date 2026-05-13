import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/comics/comics_workspace_controls.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_chrome.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';

class ComicsToolbar extends StatelessWidget {
  const ComicsToolbar({
    super.key,
    required this.controller,
    required this.itemCount,
    required this.totalCount,
    required this.selectedSeries,
    required this.viewMode,
    required this.detailsLayout,
    required this.coverSize,
    required this.hasActiveFilters,
    required this.missingIssues,
    required this.selectionMode,
    required this.selectedCount,
    required this.onSearch,
    required this.onAddComic,
    required this.onEditFilters,
    required this.onEditColumns,
    required this.onScanBarcode,
    required this.onRefreshMetadata,
    required this.onShowStats,
    required this.onClearSeries,
    required this.onViewModeChanged,
    required this.onDetailsLayoutChanged,
    required this.onViewPresetSelected,
    required this.onCoverSizeChanged,
    required this.onSelectionModeChanged,
    required this.onClearSelection,
    required this.onBulkEdit,
    required this.onBulkMoveToOwned,
    required this.onBulkMoveToWishlist,
    required this.onBulkRemove,
  });

  final TextEditingController controller;
  final int itemCount;
  final int totalCount;
  final String? selectedSeries;
  final LibraryViewMode viewMode;
  final LibraryDetailsLayout detailsLayout;
  final double coverSize;
  final bool hasActiveFilters;
  final List<int> missingIssues;
  final bool selectionMode;
  final int selectedCount;
  final ValueChanged<String> onSearch;
  final VoidCallback onAddComic;
  final VoidCallback onEditFilters;
  final VoidCallback onEditColumns;
  final VoidCallback onScanBarcode;
  final VoidCallback onRefreshMetadata;
  final VoidCallback onShowStats;
  final VoidCallback onClearSeries;
  final ValueChanged<LibraryViewMode> onViewModeChanged;
  final ValueChanged<LibraryDetailsLayout> onDetailsLayoutChanged;
  final ValueChanged<LibraryWorkspacePreset> onViewPresetSelected;
  final ValueChanged<double> onCoverSizeChanged;
  final ValueChanged<bool> onSelectionModeChanged;
  final VoidCallback onClearSelection;
  final VoidCallback onBulkEdit;
  final VoidCallback onBulkMoveToOwned;
  final VoidCallback onBulkMoveToWishlist;
  final VoidCallback onBulkRemove;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: kClzToolbar,
        border: Border(bottom: BorderSide(color: kClzDivider)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          children: [
            ComicsToolbarPrimaryActions(
              onAddComic: onAddComic,
              onScanBarcode: onScanBarcode,
              onRefreshMetadata: onRefreshMetadata,
            ),
            const LibraryWorkspaceSeparator(color: kClzDivider),
            ComicsToolbarSearch(
              controller: controller,
              selectedSeries: selectedSeries,
              onSearch: onSearch,
              onClearSeries: onClearSeries,
            ),
            const LibraryWorkspaceSeparator(color: kClzDivider),
            ComicsWorkspaceControlStrip(
              itemCount: itemCount,
              totalCount: totalCount,
              selectedSeries: selectedSeries,
              viewMode: viewMode,
              detailsLayout: detailsLayout,
              coverSize: coverSize,
              hasActiveFilters: hasActiveFilters,
              missingIssues: missingIssues,
              selectionMode: selectionMode,
              selectedCount: selectedCount,
              onEditFilters: onEditFilters,
              onEditColumns: onEditColumns,
              onShowStats: onShowStats,
              onViewModeChanged: onViewModeChanged,
              onDetailsLayoutChanged: onDetailsLayoutChanged,
              onViewPresetSelected: onViewPresetSelected,
              onCoverSizeChanged: onCoverSizeChanged,
              onSelectionModeChanged: onSelectionModeChanged,
              onClearSelection: onClearSelection,
              onBulkEdit: onBulkEdit,
              onBulkMoveToOwned: onBulkMoveToOwned,
              onBulkMoveToWishlist: onBulkMoveToWishlist,
              onBulkRemove: onBulkRemove,
            ),
          ],
        ),
      ),
    );
  }
}
