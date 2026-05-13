import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/comics/comics_missing_issues.dart';
import 'package:collectarr_app/features/comics/comics_workspace_view_config.dart';
import 'package:collectarr_app/features/library/workspace/library_toolbar_stat.dart';
import 'package:collectarr_app/features/library/workspace/library_view_controls.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_chrome.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';

enum _ComicsBulkToolbarAction { edit, owned, wishlist, remove, clear }

class ComicsWorkspaceControlState {
  const ComicsWorkspaceControlState({
    required this.selection,
    required this.utility,
    required this.view,
  });

  final ComicsSelectionControlState selection;
  final ComicsWorkspaceUtilityState utility;
  final ComicsViewTableControlState view;
}

class ComicsWorkspaceControlCallbacks {
  const ComicsWorkspaceControlCallbacks({
    required this.selection,
    required this.utility,
    required this.view,
  });

  final ComicsSelectionControlCallbacks selection;
  final ComicsWorkspaceUtilityCallbacks utility;
  final ComicsViewTableControlCallbacks view;
}

class ComicsWorkspaceCounts {
  const ComicsWorkspaceCounts({
    required this.shown,
    required this.total,
  });

  final int shown;
  final int total;
}

class ComicsSelectionControlState {
  const ComicsSelectionControlState({
    required this.enabled,
    required this.selectedCount,
  });

  final bool enabled;
  final int selectedCount;
}

class ComicsSelectionControlCallbacks {
  const ComicsSelectionControlCallbacks({
    required this.onSelectionModeChanged,
    required this.onClearSelection,
    required this.onBulkEdit,
    required this.onBulkMoveToOwned,
    required this.onBulkMoveToWishlist,
    required this.onBulkRemove,
  });

  final ValueChanged<bool> onSelectionModeChanged;
  final VoidCallback onClearSelection;
  final VoidCallback onBulkEdit;
  final VoidCallback onBulkMoveToOwned;
  final VoidCallback onBulkMoveToWishlist;
  final VoidCallback onBulkRemove;
}

class ComicsWorkspaceUtilityState {
  const ComicsWorkspaceUtilityState({
    required this.selectedSeries,
    required this.hasActiveFilters,
    required this.missingIssues,
  });

  final String? selectedSeries;
  final bool hasActiveFilters;
  final List<int> missingIssues;
}

class ComicsWorkspaceUtilityCallbacks {
  const ComicsWorkspaceUtilityCallbacks({
    required this.onShowStats,
    required this.onEditFilters,
  });

  final VoidCallback onShowStats;
  final VoidCallback onEditFilters;
}

class ComicsViewTableControlState {
  const ComicsViewTableControlState({
    required this.counts,
    required this.viewMode,
    required this.detailsLayout,
    required this.coverSize,
  });

  final ComicsWorkspaceCounts counts;
  final LibraryViewMode viewMode;
  final LibraryDetailsLayout detailsLayout;
  final double coverSize;
}

class ComicsViewTableControlCallbacks {
  const ComicsViewTableControlCallbacks({
    required this.onEditColumns,
    required this.onViewModeChanged,
    required this.onDetailsLayoutChanged,
    required this.onViewPresetSelected,
    required this.onCoverSizeChanged,
  });

  final VoidCallback onEditColumns;
  final ValueChanged<LibraryViewMode> onViewModeChanged;
  final ValueChanged<LibraryDetailsLayout> onDetailsLayoutChanged;
  final ValueChanged<LibraryWorkspacePreset> onViewPresetSelected;
  final ValueChanged<double> onCoverSizeChanged;
}

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
    required this.state,
    required this.callbacks,
  });

  final ComicsWorkspaceControlState state;
  final ComicsWorkspaceControlCallbacks callbacks;

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
                state: state.selection,
                callbacks: callbacks.selection,
              ),
              const SizedBox(width: 6),
              ComicsWorkspaceUtilityControls(
                state: state.utility,
                callbacks: callbacks.utility,
              ),
              const SizedBox(width: 6),
              ComicsViewTableControls(
                state: state.view,
                callbacks: callbacks.view,
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
    required this.state,
    required this.callbacks,
  });

  final ComicsSelectionControlState state;
  final ComicsSelectionControlCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: state.enabled ? 'Exit selection' : 'Select comics',
          child: LibraryWorkspaceIconButton(
            onPressed: () => callbacks.onSelectionModeChanged(!state.enabled),
            icon: state.enabled ? Icons.close : Icons.checklist,
          ),
        ),
        if (state.enabled) ...[
          const SizedBox(width: 6),
          LibraryToolbarStat(label: 'Selected', value: state.selectedCount),
          const SizedBox(width: 6),
          ComicsBulkActionsMenu(
            state: state,
            callbacks: callbacks,
          ),
        ],
      ],
    );
  }
}

class ComicsBulkActionsMenu extends StatelessWidget {
  const ComicsBulkActionsMenu({
    super.key,
    required this.state,
    required this.callbacks,
  });

  final ComicsSelectionControlState state;
  final ComicsSelectionControlCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_ComicsBulkToolbarAction>(
      tooltip: 'Bulk actions',
      enabled: state.selectedCount > 0,
      icon: const Icon(Icons.more_vert),
      onSelected: (action) {
        switch (action) {
          case _ComicsBulkToolbarAction.edit:
            callbacks.onBulkEdit();
          case _ComicsBulkToolbarAction.owned:
            callbacks.onBulkMoveToOwned();
          case _ComicsBulkToolbarAction.wishlist:
            callbacks.onBulkMoveToWishlist();
          case _ComicsBulkToolbarAction.remove:
            callbacks.onBulkRemove();
          case _ComicsBulkToolbarAction.clear:
            callbacks.onClearSelection();
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
    required this.state,
    required this.callbacks,
  });

  final ComicsWorkspaceUtilityState state;
  final ComicsWorkspaceUtilityCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'Local statistics',
          child: LibraryWorkspaceIconButton(
            onPressed: callbacks.onShowStats,
            icon: Icons.query_stats,
          ),
        ),
        const SizedBox(width: 6),
        Tooltip(
          message: 'Missing issues',
          child: Badge(
            isLabelVisible: state.missingIssues.isNotEmpty,
            label: Text(state.missingIssues.length.toString()),
            child: LibraryWorkspaceIconButton(
              onPressed: state.missingIssues.isEmpty
                  ? null
                  : () => showComicsMissingIssuesDialog(
                        context,
                        selectedSeries: state.selectedSeries,
                        missingIssues: state.missingIssues,
                      ),
              icon: Icons.format_list_numbered,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Tooltip(
          message: 'Filters',
          child: Badge(
            isLabelVisible: state.hasActiveFilters,
            child: LibraryWorkspaceIconButton(
              onPressed: callbacks.onEditFilters,
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
    required this.state,
    required this.callbacks,
  });

  final ComicsViewTableControlState state;
  final ComicsViewTableControlCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'Select columns',
          child: LibraryWorkspaceIconButton(
            onPressed: state.viewMode == LibraryViewMode.list
                ? callbacks.onEditColumns
                : null,
            icon: Icons.view_column,
          ),
        ),
        const SizedBox(width: 6),
        LibraryToolbarStat(label: 'Shown', value: state.counts.shown),
        const SizedBox(width: 6),
        LibraryToolbarStat(label: 'Total', value: state.counts.total),
        const SizedBox(width: 6),
        LibraryViewControls(
          viewMode: state.viewMode,
          detailsLayout: state.detailsLayout,
          coverSize: state.coverSize,
          minCoverSize: kComicsMinCoverSize,
          maxCoverSize: kComicsMaxCoverSize,
          onViewModeChanged: callbacks.onViewModeChanged,
          onDetailsLayoutChanged: callbacks.onDetailsLayoutChanged,
          onCoverSizeChanged: callbacks.onCoverSizeChanged,
          onPresetSelected: callbacks.onViewPresetSelected,
        ),
      ],
    );
  }
}
