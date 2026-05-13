import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/comics/comics_missing_issues.dart';
import 'package:collectarr_app/features/comics/comics_workspace_view_config.dart';
import 'package:collectarr_app/features/library/workspace/library_toolbar_stat.dart';
import 'package:collectarr_app/features/library/workspace/library_view_controls.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_chrome.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';

enum _ComicsBulkToolbarAction { edit, owned, wishlist, remove, clear }

class ComicsToolbarPrimaryActions extends StatelessWidget {
  const ComicsToolbarPrimaryActions({
    super.key,
    required this.onAddComic,
    required this.onScanBarcode,
    required this.onRefreshMetadata,
  });

  final VoidCallback onAddComic;
  final VoidCallback onScanBarcode;
  final VoidCallback onRefreshMetadata;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 30,
          child: FilledButton.icon(
            onPressed: onAddComic,
            style: FilledButton.styleFrom(
              backgroundColor: kClzYellow,
              foregroundColor: const Color(0xFF151515),
              padding: const EdgeInsets.symmetric(horizontal: 9),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
            icon: const Icon(Icons.add, size: 17),
            label: const Text('Add Comics'),
          ),
        ),
        const SizedBox(width: 6),
        Tooltip(
          message: 'Scan barcode',
          child: LibraryWorkspaceIconButton(
            icon: Icons.qr_code_scanner,
            onPressed: onScanBarcode,
          ),
        ),
        Tooltip(
          message: 'Refresh metadata',
          child: LibraryWorkspaceIconButton(
            icon: Icons.sync,
            onPressed: onRefreshMetadata,
          ),
        ),
      ],
    );
  }
}

class ComicsToolbarSearch extends StatelessWidget {
  const ComicsToolbarSearch({
    super.key,
    required this.controller,
    required this.selectedSeries,
    required this.onSearch,
    required this.onClearSeries,
  });

  final TextEditingController controller;
  final String? selectedSeries;
  final ValueChanged<String> onSearch;
  final VoidCallback onClearSeries;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 320,
          child: SearchBar(
            controller: controller,
            constraints: const BoxConstraints.tightFor(height: 32),
            hintText: 'Search comics...',
            leading: const Icon(Icons.search),
            trailing: [
              Tooltip(
                message: 'Search',
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => onSearch(controller.text),
                  icon: const Icon(Icons.arrow_forward, size: 18),
                ),
              ),
            ],
            onSubmitted: onSearch,
          ),
        ),
        if (selectedSeries != null) ...[
          const SizedBox(width: 6),
          InputChip(
            visualDensity: VisualDensity.compact,
            backgroundColor: kClzSelection,
            label: Text(selectedSeries!),
            onDeleted: onClearSeries,
          ),
        ],
      ],
    );
  }
}

class ComicsWorkspaceControlStrip extends StatelessWidget {
  const ComicsWorkspaceControlStrip({
    super.key,
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
    required this.onEditFilters,
    required this.onEditColumns,
    required this.onShowStats,
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
  final VoidCallback onEditFilters;
  final VoidCallback onEditColumns;
  final VoidCallback onShowStats;
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
    return Expanded(
      child: Align(
        alignment: Alignment.centerRight,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ComicsSelectionControls(
                selectionMode: selectionMode,
                selectedCount: selectedCount,
                onSelectionModeChanged: onSelectionModeChanged,
                onClearSelection: onClearSelection,
                onBulkEdit: onBulkEdit,
                onBulkMoveToOwned: onBulkMoveToOwned,
                onBulkMoveToWishlist: onBulkMoveToWishlist,
                onBulkRemove: onBulkRemove,
              ),
              const SizedBox(width: 6),
              ComicsWorkspaceUtilityControls(
                selectedSeries: selectedSeries,
                hasActiveFilters: hasActiveFilters,
                missingIssues: missingIssues,
                onShowStats: onShowStats,
                onEditFilters: onEditFilters,
              ),
              const SizedBox(width: 6),
              ComicsViewTableControls(
                itemCount: itemCount,
                totalCount: totalCount,
                viewMode: viewMode,
                detailsLayout: detailsLayout,
                coverSize: coverSize,
                onEditColumns: onEditColumns,
                onViewModeChanged: onViewModeChanged,
                onDetailsLayoutChanged: onDetailsLayoutChanged,
                onViewPresetSelected: onViewPresetSelected,
                onCoverSizeChanged: onCoverSizeChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ComicsSelectionControls extends StatelessWidget {
  const ComicsSelectionControls({
    super.key,
    required this.selectionMode,
    required this.selectedCount,
    required this.onSelectionModeChanged,
    required this.onClearSelection,
    required this.onBulkEdit,
    required this.onBulkMoveToOwned,
    required this.onBulkMoveToWishlist,
    required this.onBulkRemove,
  });

  final bool selectionMode;
  final int selectedCount;
  final ValueChanged<bool> onSelectionModeChanged;
  final VoidCallback onClearSelection;
  final VoidCallback onBulkEdit;
  final VoidCallback onBulkMoveToOwned;
  final VoidCallback onBulkMoveToWishlist;
  final VoidCallback onBulkRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: selectionMode ? 'Exit selection' : 'Select comics',
          child: LibraryWorkspaceIconButton(
            onPressed: () => onSelectionModeChanged(!selectionMode),
            icon: selectionMode ? Icons.close : Icons.checklist,
          ),
        ),
        if (selectionMode) ...[
          const SizedBox(width: 6),
          LibraryToolbarStat(label: 'Selected', value: selectedCount),
          const SizedBox(width: 6),
          ComicsBulkActionsMenu(
            selectedCount: selectedCount,
            onBulkEdit: onBulkEdit,
            onBulkMoveToOwned: onBulkMoveToOwned,
            onBulkMoveToWishlist: onBulkMoveToWishlist,
            onBulkRemove: onBulkRemove,
            onClearSelection: onClearSelection,
          ),
        ],
      ],
    );
  }
}

class ComicsBulkActionsMenu extends StatelessWidget {
  const ComicsBulkActionsMenu({
    super.key,
    required this.selectedCount,
    required this.onBulkEdit,
    required this.onBulkMoveToOwned,
    required this.onBulkMoveToWishlist,
    required this.onBulkRemove,
    required this.onClearSelection,
  });

  final int selectedCount;
  final VoidCallback onBulkEdit;
  final VoidCallback onBulkMoveToOwned;
  final VoidCallback onBulkMoveToWishlist;
  final VoidCallback onBulkRemove;
  final VoidCallback onClearSelection;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_ComicsBulkToolbarAction>(
      tooltip: 'Bulk actions',
      enabled: selectedCount > 0,
      icon: const Icon(Icons.more_vert),
      onSelected: (action) {
        if (action == _ComicsBulkToolbarAction.edit) {
          onBulkEdit();
        } else if (action == _ComicsBulkToolbarAction.owned) {
          onBulkMoveToOwned();
        } else if (action == _ComicsBulkToolbarAction.wishlist) {
          onBulkMoveToWishlist();
        } else if (action == _ComicsBulkToolbarAction.remove) {
          onBulkRemove();
        } else if (action == _ComicsBulkToolbarAction.clear) {
          onClearSelection();
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: _ComicsBulkToolbarAction.edit,
          child: ListTile(
            leading: Icon(Icons.edit_note),
            title: Text('Bulk edit'),
          ),
        ),
        PopupMenuItem(
          value: _ComicsBulkToolbarAction.owned,
          child: ListTile(
            leading: Icon(Icons.inventory_2_outlined),
            title: Text('Move to owned'),
          ),
        ),
        PopupMenuItem(
          value: _ComicsBulkToolbarAction.wishlist,
          child: ListTile(
            leading: Icon(Icons.star_border),
            title: Text('Move to wishlist'),
          ),
        ),
        PopupMenuItem(
          value: _ComicsBulkToolbarAction.remove,
          child: ListTile(
            leading: Icon(Icons.delete_outline),
            title: Text('Remove selected'),
          ),
        ),
        PopupMenuItem(
          value: _ComicsBulkToolbarAction.clear,
          child: ListTile(
            leading: Icon(Icons.deselect),
            title: Text('Clear selection'),
          ),
        ),
      ],
    );
  }
}

class ComicsWorkspaceUtilityControls extends StatelessWidget {
  const ComicsWorkspaceUtilityControls({
    super.key,
    required this.selectedSeries,
    required this.hasActiveFilters,
    required this.missingIssues,
    required this.onShowStats,
    required this.onEditFilters,
  });

  final String? selectedSeries;
  final bool hasActiveFilters;
  final List<int> missingIssues;
  final VoidCallback onShowStats;
  final VoidCallback onEditFilters;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'Local statistics',
          child: LibraryWorkspaceIconButton(
            onPressed: onShowStats,
            icon: Icons.query_stats,
          ),
        ),
        const SizedBox(width: 6),
        Tooltip(
          message: 'Missing issues',
          child: Badge(
            isLabelVisible: missingIssues.isNotEmpty,
            label: Text(missingIssues.length.toString()),
            child: LibraryWorkspaceIconButton(
              onPressed: missingIssues.isEmpty
                  ? null
                  : () => showComicsMissingIssuesDialog(
                        context,
                        selectedSeries: selectedSeries,
                        missingIssues: missingIssues,
                      ),
              icon: Icons.format_list_numbered,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Tooltip(
          message: 'Filters',
          child: Badge(
            isLabelVisible: hasActiveFilters,
            child: LibraryWorkspaceIconButton(
              onPressed: onEditFilters,
              icon: Icons.filter_list,
            ),
          ),
        ),
      ],
    );
  }
}

class ComicsViewTableControls extends StatelessWidget {
  const ComicsViewTableControls({
    super.key,
    required this.itemCount,
    required this.totalCount,
    required this.viewMode,
    required this.detailsLayout,
    required this.coverSize,
    required this.onEditColumns,
    required this.onViewModeChanged,
    required this.onDetailsLayoutChanged,
    required this.onViewPresetSelected,
    required this.onCoverSizeChanged,
  });

  final int itemCount;
  final int totalCount;
  final LibraryViewMode viewMode;
  final LibraryDetailsLayout detailsLayout;
  final double coverSize;
  final VoidCallback onEditColumns;
  final ValueChanged<LibraryViewMode> onViewModeChanged;
  final ValueChanged<LibraryDetailsLayout> onDetailsLayoutChanged;
  final ValueChanged<LibraryWorkspacePreset> onViewPresetSelected;
  final ValueChanged<double> onCoverSizeChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'Select columns',
          child: LibraryWorkspaceIconButton(
            onPressed: viewMode == LibraryViewMode.list ? onEditColumns : null,
            icon: Icons.view_column,
          ),
        ),
        const SizedBox(width: 6),
        LibraryToolbarStat(label: 'Shown', value: itemCount),
        const SizedBox(width: 6),
        LibraryToolbarStat(label: 'Total', value: totalCount),
        const SizedBox(width: 6),
        LibraryViewControls(
          viewMode: viewMode,
          detailsLayout: detailsLayout,
          coverSize: coverSize,
          minCoverSize: kComicsMinCoverSize,
          maxCoverSize: kComicsMaxCoverSize,
          onViewModeChanged: onViewModeChanged,
          onDetailsLayoutChanged: onDetailsLayoutChanged,
          onCoverSizeChanged: onCoverSizeChanged,
          onPresetSelected: onViewPresetSelected,
        ),
      ],
    );
  }
}
