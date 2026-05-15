import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/library/library_media_adapter.dart';
import 'package:collectarr_app/features/library/generic_library_projection.dart';
import 'package:collectarr_app/features/library/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_utility_menu.dart';
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

  @override
  Widget build(BuildContext context) {
    return LibraryToolbarFrame(
      backgroundColor: kClzToolbar,
      dividerColor: kClzDivider,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 760) {
            return _GenericCompactToolbar(
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
                LibraryWorkspaceControlStrip(
                  children: [
                    _GenericLibraryToolsButton(
                      type: type,
                      counts: counts,
                      selectedBucket: selectedBucket,
                      quickView: quickView,
                      hasActiveFilters: hasActiveFilters,
                      onQuickViewSelected: onQuickViewSelected,
                      onClearFilters: onClearFilters,
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

class _GenericLibraryToolsButton extends StatelessWidget {
  const _GenericLibraryToolsButton({
    required this.type,
    required this.counts,
    required this.selectedBucket,
    required this.quickView,
    required this.hasActiveFilters,
    required this.onQuickViewSelected,
    required this.onClearFilters,
  });

  final LibraryTypeConfig type;
  final GenericToolbarCounts counts;
  final String? selectedBucket;
  final GenericQuickView? quickView;
  final bool hasActiveFilters;
  final ValueChanged<GenericQuickView> onQuickViewSelected;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return LibraryUtilityMenu<GenericQuickView>(
      quickViews: [
        for (final view in GenericQuickView.values)
          LibraryUtilityQuickView(
            value: view,
            label: view.label,
            icon: view.icon,
          ),
      ],
      selectedQuickView: quickView,
      onQuickViewSelected: onQuickViewSelected,
      badgeCount: _utilityBadgeCount,
      actions: [
        LibraryUtilityMenuAction(
          icon: Icons.query_stats,
          label: 'Statistics',
          onSelected: () => _showGenericStatsDialog(context, type, counts),
        ),
        LibraryUtilityMenuAction(
          icon: Icons.filter_alt_off_outlined,
          label: 'Clear filters',
          enabled: hasActiveFilters,
          onSelected: onClearFilters,
        ),
        LibraryUtilityMenuAction(
          icon: Icons.image_not_supported_outlined,
          label: 'Missing covers',
          enabled: false,
          trailing: Text(counts.missingCover.toString()),
        ),
        LibraryUtilityMenuAction(
          icon: Icons.manage_search,
          label: 'Missing metadata',
          enabled: false,
          trailing: Text(counts.missingMetadata.toString()),
        ),
      ],
    );
  }

  int get _utilityBadgeCount {
    return (selectedBucket != null ? 1 : 0) + (quickView != null ? 1 : 0);
  }
}

class _GenericCompactToolbar extends StatelessWidget {
  const _GenericCompactToolbar({
    required this.type,
    required this.searchController,
    required this.counts,
    required this.selectedBucket,
    required this.onAdd,
    required this.onScan,
    required this.onSearchChanged,
    required this.onRefreshMetadata,
    required this.onViewPresetSelected,
    required this.onCoverSizeChanged,
    required this.quickView,
    required this.onQuickViewSelected,
    required this.hasActiveFilters,
    required this.onClearFilters,
  });

  final LibraryTypeConfig type;
  final TextEditingController searchController;
  final GenericToolbarCounts counts;
  final String? selectedBucket;
  final VoidCallback onAdd;
  final VoidCallback onScan;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onRefreshMetadata;
  final ValueChanged<LibraryWorkspacePreset> onViewPresetSelected;
  final ValueChanged<double> onCoverSizeChanged;
  final GenericQuickView? quickView;
  final ValueChanged<GenericQuickView> onQuickViewSelected;
  final bool hasActiveFilters;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Tooltip(
            message: 'Add ${type.pluralLabel}',
            child: IconButton.filled(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SearchBar(
              controller: searchController,
              constraints: const BoxConstraints.tightFor(height: 32),
              hintText: 'Search ${type.pluralLabel.toLowerCase()}...',
              leading: const Icon(Icons.search),
              onChanged: onSearchChanged,
              onSubmitted: onSearchChanged,
            ),
          ),
          const SizedBox(width: 8),
          _GenericLibraryToolsButton(
            type: type,
            counts: counts,
            selectedBucket: selectedBucket,
            quickView: quickView,
            hasActiveFilters: hasActiveFilters,
            onQuickViewSelected: onQuickViewSelected,
            onClearFilters: onClearFilters,
          ),
          Tooltip(
            message: 'Cover size',
            child: IconButton.filledTonal(
              onPressed: () => _showCompactCoverSizeSheet(
                context,
                onViewPresetSelected,
                onCoverSizeChanged,
              ),
              icon: const Icon(Icons.photo_size_select_large_outlined),
            ),
          ),
          Tooltip(
            message: 'Scan barcode',
            child: IconButton.filledTonal(
              onPressed: onScan,
              icon: const Icon(Icons.qr_code_scanner),
            ),
          ),
          Tooltip(
            message: 'Refresh metadata',
            child: IconButton.filledTonal(
              onPressed: onRefreshMetadata,
              icon: const Icon(Icons.sync),
            ),
          ),
        ],
      ),
    );
  }
}

void _showCompactCoverSizeSheet(
  BuildContext context,
  ValueChanged<LibraryWorkspacePreset> onViewPresetSelected,
  ValueChanged<double> onCoverSizeChanged,
) {
  showModalBottomSheet<void>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.grid_view),
            title: const Text('Cover view'),
            onTap: () {
              Navigator.of(context).pop();
              onViewPresetSelected(LibraryWorkspacePreset.cover);
            },
          ),
          ListTile(
            leading: const Icon(Icons.view_module),
            title: const Text('Card view'),
            onTap: () {
              Navigator.of(context).pop();
              onViewPresetSelected(LibraryWorkspacePreset.card);
            },
          ),
          ListTile(
            leading: const Icon(Icons.view_list),
            title: const Text('List view'),
            onTap: () {
              Navigator.of(context).pop();
              onViewPresetSelected(LibraryWorkspacePreset.list);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.photo_size_select_small),
            title: const Text('Small covers'),
            onTap: () {
              Navigator.of(context).pop();
              onCoverSizeChanged(96);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_size_select_large),
            title: const Text('Large covers'),
            onTap: () {
              Navigator.of(context).pop();
              onCoverSizeChanged(188);
            },
          ),
        ],
      ),
    ),
  );
}

void _showGenericStatsDialog(
  BuildContext context,
  LibraryTypeConfig type,
  GenericToolbarCounts counts,
) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('${type.pluralLabel} statistics'),
      content: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _StatsChip('Shown', counts.shown),
          _StatsChip('Total', counts.total),
          _StatsChip('Owned', counts.owned),
          _StatsChip('Wishlist', counts.wishlist),
          _StatsChip('Missing covers', counts.missingCover),
          _StatsChip('Missing metadata', counts.missingMetadata),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    ),
  );
}

class _StatsChip extends StatelessWidget {
  const _StatsChip(this.label, this.value);

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label $value'),
      avatar: const Icon(Icons.query_stats, size: 16),
    );
  }
}
